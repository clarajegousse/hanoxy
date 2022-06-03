import helpers as hlp

configfile: "config.yaml"
FILE = config['scratch_dir'] + config['samples_file_info']

SAMPLE = 'TARA_030'
RUNS = hlp.sample2runs(SAMPLE, FILE)
print(RUNS)
#RUNS = ['ERR599054', 'ERR599158']
NUM = ['1', '2']


rule all:
    input:
        expand("{dir}/{run}_{num}.fastq.gz", dir = 'data/raw', run = RUNS, num = NUM)
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
        ftp = lambda wc: hlp.run2url(wc),
        outdir = 'data/raw'
    output:
        "data/raw/{run}_{num}.fastq.gz"
    shell:
     """
     echo {params.ftp}
     cd {params.outdir}
     wget {params.ftp}
     """
