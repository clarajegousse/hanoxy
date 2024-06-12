#!/bin/bash
#SBATCH --job-name=01-derep
#SBATCH -p mimir
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cat3@hi.is
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --output=%j-%x.out
#SBATCH --error=%j-%x.out

. ~/.bashrc

ml use /hpcapps/lib-tools/modules/all
ml load Anaconda3/2023.09-0 # load Anaconda
conda activate /hpcapps/env/conda/SNIC # activate conda environment

WD=$HOME/projects/hanoxy/data/genomes
OUTDIR=$HOME/projects/hanoxy/results/derep-genomes

gzip -d $WD/*.gz

coverm cluster --ani 90 --genome-fasta-directory $WD/ --output-representative-fasta-directory $OUTDIR

# gtdb = 155
# if --ani 95 = 150 genomes
