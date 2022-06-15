import helpers as hlp

configfile: "config.yaml"

#FILE = '/Users/jegoussc/Repositories/hanoxy/data/info/samples.txt'
FILE = config['scratch_dir'] + config['samples_file_info']
RAW_DATA_DIR = config['scratch_dir'] + config['raw_data_dir']
QC_RES_DIR = config['scratch_dir'] + config['qc_res_dir']

SAMPLE = 'TARA_032'
RUNS = hlp.sample2runs(SAMPLE, FILE)
NUM = ['1', '2']

rule all:
    input:
        expand('{raw_dir}/{sample}/{run}_{num}.fastq.gz', raw_dir = RAW_DATA_DIR, sample = SAMPLE, run = RUNS, num = NUM),
        expand('{qc_res_dir}/{sample}.ini', qc_res_dir = QC_RES_DIR, sample = SAMPLE),
        expand('{qc_res_dir}/{sample}-QUALITY_PASSED_R{num}.fastq', qc_res_dir = QC_RES_DIR, sample = SAMPLE, num = NUM),
        expand('{qc_res_dir}/{sample}-QUALITY_PASSED_R{num}.fastq.gz', qc_res_dir = QC_RES_DIR, sample = SAMPLE, num = NUM)

rule download_ena:
    params:
        ftp = lambda wildcard: hlp.run2url(wildcard),
        outdir = '{raw_dir}/{sample}'
    output:
        # /users/home/cat3/projects/hanoxy/data/raw/TARA_030/ERR315862_1.fastq.gz
        '{raw_dir}/{sample}/{run}_{num}.fastq.gz'
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
        expand('{raw_dir}/{sample}/{run}_{num}.fastq.gz', raw_dir = RAW_DATA_DIR, sample = SAMPLE, run = RUNS, num = NUM)
    params:
        info = hlp.ui_config(SAMPLE, RUNS, RAW_DATA_DIR),
        outdir = QC_RES_DIR
    output:
        expand('{qc_res_dir}/{sample}.ini', qc_res_dir = QC_RES_DIR, sample = SAMPLE)
    shell:
        'iu-gen-configs {params.info} -o {params.outdir}'

rule qc_minoche:
    input:
        expand('{qc_res_dir}/{sample}.ini', qc_res_dir = QC_RES_DIR, sample = SAMPLE)
    output:
        expand('{qc_res_dir}/{sample}-QUALITY_PASSED_R{num}.fastq', qc_res_dir = QC_RES_DIR, sample = SAMPLE, num = NUM)
    shell:
        'iu-filter-quality-minoche {input} --ignore-deflines'

rule compress:
    input:
        expand('{qc_res_dir}/{sample}-QUALITY_PASSED_R{num}.fastq', qc_res_dir = QC_RES_DIR, sample = SAMPLE, num = NUM)
    output:
        expand('{qc_res_dir}/{sample}-QUALITY_PASSED_R{num}.fastq.gz', qc_res_dir = QC_RES_DIR, sample = SAMPLE, num = NUM)
    shell:
        'gzip {input}'
