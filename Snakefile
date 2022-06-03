import helpers as hlp

configfile: "config.yaml"

FILE = config['scratch_dir'] + config['samples_file_info']
RAW_DATA = config['scratch_dir'] + config['raw_data_dir']

SAMPLE = 'TARA_030'
RUNS = hlp.sample2runs(SAMPLE, FILE)
print(RUNS)
#RUNS = ['ERR599054', 'ERR599158']
NUM = ['1', '2']


rule all:
    input:
        expand("{raw_dir}/{run}_{num}.fastq.gz",
        raw_dir = RAW_DATA,
        run = RUNS,
        num = NUM)
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
        outdir = '{raw_dir}'
    output:
        "{raw_dir}/{run}_{num}.fastq.gz"
    shell:
     """
     echo {params.ftp}
     cd {params.outdir}
     wget {params.ftp}
     """

rule qc_ini:
    input: hlp.ui_config(SAMPLE, RUNS, RAW_DATA)
    params:
        outdir = 'results/qc'
    shell:
        """
        # to insure work with python3
        source /users/home/cat3/.bashrc
        # activate environment
        conda activate anvio-master
        iu-gen-configs {input} -o {params.outdir}
        """
