#!/bin/bash
# 03-qc-raw-reads-gen-pbs.sh
# prepare files for quality control of the raw metagenomics reads 
# and generate pbs scripts for scheduler.

# to insure work with python3
source /users/home/cat3/.bashrc

# activate environment
ml use /hpcapps/lib-tools/modules/all
ml load Anaconda3/2023.09-0 # load Anaconda
conda activate /hpcapps/env/conda/SNIC # activate conda environment

# go to working directory
WD=$HOME/projects/hanoxy
RAW_DIR=/hpcdata/Mimir/cat3/raw

iu-gen-configs $WD/data/info/samples.txt -o $WD/results/qc

for sample in `awk '{print $1}' $WD/data/info/samples.txt`
do
    if [ "$sample" == "sample" ]; then continue; fi
	echo $sample
	echo '''#!/bin/bash
#SBATCH --job-name=03-qc-'$sample'
#SBATCH -p mimir
#SBATCH --time=3-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cat3@hi.is
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --output=03-qc-'$sample'.%j.out
#SBATCH --error==03-qc-'$sample'.%j.err

echo $HOSTNAME

. ~/.bashrc

ml use /hpcapps/lib-tools/modules/all
ml load Anaconda3/2023.09-0 # load Anaconda
conda activate /hpcapps/env/conda/SNIC # activate conda environment

. ~/.bashrc

WD=$HOME/projects/hanoxy
cd /hpcdata/Mimir/cat3/raw
iu-filter-quality-minoche $WD/results/qc/'$sample'.ini --ignore-deflines
''' > $WD/scripts/$sample'-qc-pbs.sh'
done