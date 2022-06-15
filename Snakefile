import helpers as hlp

configfile: "config.yaml"

#FILE = '/Users/jegoussc/Repositories/hanoxy/data/info/samples.txt'
FILE = config['scratch_dir'] + config['samples_file_info']
RAW_DATA_DIR = config['scratch_dir'] + config['raw_data_dir']
QC_RES_DIR = config['scratch_dir'] + config['qc_res_dir']

SAMPLE = 'TARA_030'
RUNS = hlp.sample2runs(SAMPLE, FILE)
NUM = ['1', '2']

rule all:
    input:
        expand('{raw_dir}/{sample}/{run}_{num}.fastq.gz', raw_dir = RAW_DATA_DIR, sample = SAMPLE, run = RUNS, num = NUM)
        expand('{qc_res_dir}/{sample}.ini', qc_res_dir = QC_RES_DIR, sample = SAMPLE)


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
        QC_RES_DIR + '/{sample}/{run}_{num}.fastq.gz'
    params:
        info = hlp.ui_config(SAMPLE, RUNS, RAW_DATA_DIR),
        outdir = QC_RES_DIR
    output:
        expand('{qc_res_dir}/{sample}.ini', qc_res_dir = QC_RES_DIR, sample = SAMPLE)
    shell:
        'iu-gen-configs {params.info} -o {params.outdir}'
