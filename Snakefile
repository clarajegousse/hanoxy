import helpers as hlp

configfile: "config.yaml"

SAMPLE = 'TARA_030'

FILE = config['scratch_dir'] + config['samples_file_info']
RUNS = hlp.sample2runs(SAMPLE, FILE)
NUM = ['1', '2']

RAW_DATA_DIR = config['scratch_dir'] + config['raw_data_dir']
RES_DIR = config['scratch_dir'] + '/results'
QC_RES_DIR = config['scratch_dir'] + config['qc_res_dir']

ruleorder: download_ena > qc_ini > qc_minoche > compress > count

rule all:
    input:
        expand(RAW_DATA_DIR + '/{sample}/{run}_{num}.fastq.gz', sample = SAMPLE, run = RUNS, num = NUM),
        expand(QC_RES_DIR + '/{sample}.ini', sample = SAMPLE),
        expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R{num}.fastq', sample = SAMPLE, num = NUM),
        #expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R{num}.fastq.gz', sample = SAMPLE, num = NUM),
        #expand(RES_DIR + '/counts/{sample}.tsv', sample = SAMPLE),
        #expand(RES_DIR + '/abundance/{sample}.tsv', sample = SAMPLE),
        #expand(RES_DIR + '/tpm/{sample}.tsv', sample = SAMPLE)

rule download_ena:
    params:
        ftp = lambda wildcard: hlp.run2url(wildcard),
        outdir = RAW_DATA_DIR + '/{sample}'
    output:
        # /hpchome/cat3/projects/hanoxy/data/raw/TARA_030/ERR315862_1.fastq.gz
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
        # /hpchome/cat3/projects/hanoxy/data/raw/TARA_030/ERR315862_1.fastq.gz
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
        r1 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R1.fastq.gz', sample = SAMPLE),
        r2 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R2.fastq.gz', sample = SAMPLE),
        derep_dir = "/users/home/cat3/projects/hanoxy/results/derep-genomes"
    output:
        counts = expand('/users/home/cat3/projects/hanoxy/results/counts/{sample}.tsv', sample = SAMPLE)
    shell:
        """
        coverm genome -1 {input.r1} \
        -2 {input.r2} --threads 4 \
        --genome-fasta-directory {input.derep_dir} \
        --genome-fasta-extension "fna" \
        --methods count --min-covered-fraction 0 \
        --min-read-percent-identity 90 \
        -o {output.counts}
        """

rule abundance:
    input:
        r1 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R1.fastq.gz', sample = SAMPLE),
        r2 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R2.fastq.gz', sample = SAMPLE),
        derep_dir = "/hpchome/cat3/projects/hanoxy/results/derep-genomes"
    output:
        abundance = expand('/hpchome/cat3/projects/hanoxy/results/abundance/{sample}.tsv', sample = SAMPLE)
    shell:
        """
        coverm genome -1 {input.r1} \
        -2 {input.r2} --threads 4 \
        --genome-fasta-directory {input.derep_dir} \
        --genome-fasta-extension "fna" \
        --methods relative_abundance --min-covered-fraction 10 \
        --min-read-percent-identity 90 \
        -o {output.abundance}
        """

rule tpm:
    input:
        r1 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R1.fastq.gz', sample = SAMPLE),
        r2 = expand(QC_RES_DIR + '/{sample}-QUALITY_PASSED_R2.fastq.gz', sample = SAMPLE),
        derep_dir = "/hpchome/cat3/projects/hanoxy/results/derep-genomes"
    output:
        tpm = expand('/hpchome/cat3/projects/hanoxy/results/tpm/{sample}.tsv', sample = SAMPLE)
    shell:
        """
        coverm genome -1 {input.r1} \
        -2 {input.r2} --threads 4 \
        --genome-fasta-directory {input.derep_dir} \
        --genome-fasta-extension "fna" \
        --methods tpm --min-covered-fraction 10 \
        --min-read-percent-identity 90 \
        -o {output.tpm}
        """
