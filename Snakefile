import helpers as hlp

configfile: "config.yaml"

#FILE = '/Users/jegoussc/Repositories/hanoxy/data/info/samples.txt'
FILE = config['scratch_dir'] + config['samples_file_info']
RAW_DATA_DIR = config['scratch_dir'] + config['raw_data_dir']
QC_RES_DIR = config['scratch_dir'] + config['qc_res_dir']

SAMPLE = 'TARA_030'
RUNS = hlp.sample2runs(SAMPLE, FILE)
NUM = ['1', '2']

ruleorder: download_ena > qc_ini

rule all:
    input:
        expand('{raw_dir}/{sample}/{run}_{num}.fastq.gz', raw_dir = RAW_DATA_DIR, sample = SAMPLE, run = RUNS, num = NUM),
        #expand('{qc_res_dir}/{sample}-QUALITY_PASSED_R{num}.fastq.gz', qc_res_dir = QC_RES_DIR, sample = SAMPLE, num = NUM)
        #"data/raw/{run}_{num}.fastq.gz"

# rule compress_fastq:
#     input:
#         "{raw_dir}/{run}_{num}.fastq"
#     output:
#         "{raw_dir}/{run}_{num}.fastq.gz"
#     shell:
#      """
#      gzip {input}
#      """


rule download_ena:
    params:
        ftp = lambda wildcard: hlp.run2url(wildcard),
        outdir = RAW_DATA_DIR
    output:
        '{raw_dir}/{sample}/{run}_{num}.fastq.gz'
    shell:
     """
     echo {params.ftp}
     cd {params.outdir}
     wget {params.ftp}
     """

rule qc_ini:
    input:
        '{raw_dir}/{sample}/{run}_{num}.fastq.gz'
    params:
        info = hlp.ui_config(SAMPLE, RUNS, RAW_DATA_DIR),
        outdir = QC_RES_DIR,
        sample = SAMPLE
    output:
        '{qc_res_dir}/{sample}-QUALITY_PASSED_R{num}.fastq.gz',
    shell:
        """
        iu-gen-configs {params.info} -o {params.outdir}
        iu-filter-quality-minoche {params.outdir}/{params.sample}.ini --ignore-deflines
        """
