import helpers as hlp

configfile: "config.yaml"

#FILE = '/Users/jegoussc/Repositories/hanoxy/data/info/samples.txt'
FILE = config['scratch_dir'] + config['samples_file_info']
RAW_DATA_DIR = config['scratch_dir'] + config['raw_data_dir']
QC_RES_DIR = config['scratch_dir'] + config['qc_res_dir']

SAMPLE = 'TARA_030'
RUNS = hlp.sample2runs(SAMPLE, FILE)
NUM = ['1', '2']

ruleorder: download_ena > qc_ini > qc_minoche > compress > count

rule all:
    input:
        expand(RAW_DATA_DIR + '/{sample}/{run}_{num}.fastq.gz', sample = SAMPLE, run = RUNS, num = NUM),
        expand(RAW_DATA_DIR + '/{sample}.ini', sample = SAMPLE),
        expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R{num}.fastq', sample = SAMPLE, num = NUM),
        expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R{num}.fastq.gz', sample = SAMPLE, num = NUM),
        expand('/users/home/cat3/projects/hanoxy/results/counts/{sample}.tsv', sample = SAMPLE)

rule download_ena:
    params:
        ftp = lambda wildcard: hlp.run2url(wildcard),
        outdir = RAW_DATA_DIR + '/{sample}'
    output:
        # /users/home/cat3/projects/hanoxy/data/raw/TARA_030/ERR315862_1.fastq.gz
        RAW_DATA_DIR + '/{sample}/{run}_{num}.fastq.gz'
    shell:
     """
     echo {params.ftp}
     mkdir -p {params.outdir}
     cd {params.outdir}
     wget {params.ftp}
     """

rule qc_ini:
    input:
        # /users/home/cat3/projects/hanoxy/data/raw/TARA_030/ERR315862_1.fastq.gz
        expand(RAW_DATA_DIR + '/{sample}/{run}_{num}.fastq.gz', sample = SAMPLE, run = RUNS, num = NUM)
    params:
        info = hlp.ui_config(SAMPLE, RUNS, RAW_DATA_DIR),
        outdir = QC_RES_DIR
    output:
        expand(QC_RES_DIR + '/{sample}.ini', sample = SAMPLE)
    shell:
        """
        iu-gen-configs {params.info} -o {params.outdir}
        """

rule qc_minoche:
    input:
        expand(QC_RES_DIR + '/{sample}.ini', sample = SAMPLE)
    output:
        expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R{num}.fastq', sample = SAMPLE, num = NUM)
    shell:
        'iu-filter-quality-minoche {input} --ignore-deflines'

rule compress:
    input:
        expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R{num}.fastq', sample = SAMPLE, num = NUM)
    output:
        expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R{num}.fastq.gz', sample = SAMPLE, num = NUM)
    shell:
        'gzip {input}'

rule count:
    input:
        r1 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R1.fastq', sample = SAMPLE),
        r2 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R2.fastq', sample = SAMPLE),
        derep_dir = "/users/home/cat3/projects/hanoxy/results/derep-genomes"
    output:
        counts = expand('/users/home/cat3/projects/hanoxy/results/counts/{sample}.tsv', sample = SAMPLE)
    shell:
        """
        coverm genome -1 {input.r1} \
        -2 {input.r2} \
        --genome-fasta-directory {input.derep_dir} \
        --genome-fasta-extension "fna" \
        --dereplicate \
        --methods "count" --min-covered-fraction 0 \
        -o {output.counts}
        """
