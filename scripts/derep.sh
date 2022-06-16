#!/bin/bash
#SBATCH --job-name=haliea-gen-derep
#SBATCH -p normal
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cat3@hi.is
#SBATCH -N 1
#SBATCH --ntasks-per-node=1

# to insure work with python3
source /users/home/cat3/.bashrc

WD=/users/home/cat3/projects/hanoxy/data/genomes
OUTDIR=/users/home/cat3/projects/hanoxy/results/derep-genomes

coverm cluster --ani 95 --genome-fasta-directory $WD/ --output-representative-fasta-directory $OUTDIR
