import helpers as hlp


RUNS = ['ERR598959']
NUM = ['1', '2']

rule all:
    input:
        expand("data/test/{run}_{num}.fastq.gz", run = RUNS, num = NUM)

rule compress_fastq:
    input:
        "data/raw/{run}_{num}.fastq"
    output:
        "data/raw/{run}_{num}.fastq.gz"
    shell:
     """
     gzip {input}
     """

rule decompress_fastq:
    input:
        "data/raw/{run}_{num}.fastq.gz"
    output:
        "data/raw/{run}_{num}.fastq"
    shell:
     """
     gunzip {input}
     """

rule download_ena:
    params:
        ftp = hlp.run2url('{run}', '{num}')
    output:
        "data/test/{run}_{num}.fastq.gz"
    shell:
     """
     cd data/test/
     echo '{params.ftp}'
     #wget {params.ftp}
     """
