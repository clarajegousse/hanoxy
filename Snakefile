import helpers as hlp

configfile: "config.yaml"

FILE = config['scratch_dir'] + config['samples_file_info']
RAW_DATA_DIR = config['scratch_dir'] + config['raw_data_dir']
QC_RES_DIR = config['scratch_dir'] + config['qc_res_dir']

SAMPLE = 'TARA_030'
RUNS = hlp.sample2runs(SAMPLE, FILE)
print(RUNS)
#RUNS = ['ERR599054', 'ERR599158']
NUM = ['1', '2']

ruleorder: download_ena > qc_ini

rule all:
    input:
        expand('{raw_dir}/{run}_{num}.fastq.gz', raw_dir = RAW_DATA_DIR, run = RUNS, num = NUM),
        #expand('{qc_res_dir}/{sample}-QUALITY_PASSED_R1.fastq.gz', qc_res_dir = QC_RES_DIR, sample = SAMPLE)
        #"data/raw/{run}_{num}.fastq.gz"

# rule compress_fastq:
#     input:
#         "data/raw/{run}_{num}.fastq"
#     output:
#         "data/raw/{run}_{num}.fastq.gz"
#     shell:
#      """
#      gzip {input}
#      """

# rule decompress_fastq:
#     input:
#         "data/raw/{run}_{num}.fastq.gz"
#     output:
#         "data/raw/{run}_{num}.fastq"
#     shell:
#      """
#      gunzip {input}
#      """

rule download_ena:
    params:
        ftp = lambda wildcard: hlp.run2url(wildcard),
        outdir = RAW_DATA_DIR
    output:
        "{raw_dir}/{run}_{num}.fastq.gz"
    shell:
     """
     echo {params.ftp}
     cd {params.outdir}
     wget {params.ftp}
     """

rule qc_ini:
    input:
        info = hlp.ui_config(SAMPLE, RUNS, RAW_DATA_DIR),
        file = '{raw_dir}/{run}_{num}.fastq.gz'
    params:
        outdir = 'results/qc',
        sample = SAMPLE
    output:
        r1 = '{qc_res_dir}/{sample}-QUALITY_PASSED_R1.fastq.gz',
        r2 = '{qc_res_dir}/{sample}-QUALITY_PASSED_R2.fastq.gz',
        stats = '{qc_res_dir}/{sample}-STATS'
    shell:
        """
        # to insure work with python3
        source /users/home/cat3/.bashrc
        # activate environment
        conda activate anvio-master
        iu-gen-configs {input.info} -o {params.outdir}
        iu-filter-quality-minoche {params.outdir}/{params.sample}.ini --ignore-deflines
        """
