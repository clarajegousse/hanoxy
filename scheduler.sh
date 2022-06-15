#! /bin/bash
#SBATCH -J scheduler
#SBATCH -t 7-00:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -p normal
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cat3@hi.is

cd /users/home/cat3/projects/hanoxy

mkdir -p logs_slurm
snakemake --cluster-config cluster.yaml --cluster 'sbatch -t {cluster.time} -c {cluster.cpus} -o {cluster.output} -e {cluster.error} --mail-type {cluster.email_type} --mail-user {cluster.email}' -j 10
