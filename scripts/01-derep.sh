#!/bin/bash
#SBATCH --job-name=haliea-gen-derep
#SBATCH -p normal
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cat3@hi.is
#SBATCH -N 1
#SBATCH --ntasks-per-node=1

ml use /hpcapps/lib-tools/modules/all
ml load Anaconda3/2023.09-0 # load Anaconda
conda activate /hpcapps/env/conda/SNIC # activate conda environment

WD=$HOME/projects/hanoxy/data/genomes
OUTDIR=$HOME/projects/hanoxy/results/derep-genomes

# just checking if program runs. 
coverm -h 

# coverm cluster --ani 95 --genome-fasta-directory $WD/ --output-representative-fasta-directory $OUTDIR

# --- dereplication ----

#checkm -h
#checkm data setRoot /users/work/cat3/db/gtdbk
#dRep dereplicate $WD/DREP -g $WD/*.fna.gz -d


# /users/home/cat3/miniconda3/lib/python3.8/site-packages/statsmodels/tools/_testing.py:19: FutureWarning: pandas.util.testing is deprecated. Use the functions in the public API at pandas.testing instead.
#   import pandas.util.testing as tm
# ***************************************************
#     ..:: dRep dereplicate Step 1. Filter ::..
# ***************************************************
#
# Will filter the genome list
# 117 genomes were input to dRep
# Calculating genome info of genomes
