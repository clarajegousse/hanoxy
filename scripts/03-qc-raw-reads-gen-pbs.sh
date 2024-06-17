#!/bin/bash
# 03-qc-raw-reads-gen-pbs.sh
# prepare files for quality control of the raw metagenomics reads 
# and generate pbs scripts for scheduler.

source ~/.bashrc

# activate environment
ml use /hpcapps/lib-tools/modules/all
ml load Anaconda3/2023.09-0 # load Anaconda
conda activate /hpcapps/env/conda/SNIC # activate conda environment

# go to working directory
WD=$HOME/projects/hanoxy
RAW_DIR=/hpcdata/Mimir/cat3/raw
OUT_DIR=$WD/results/qc

cat $WD/data/info/samples.txt | sed 's+"++g' | sed 's+ERR+/hpcdata/Mimir/cat3/raw/ERR+g' > $WD/data/info/samples-paths.txt

iu-gen-configs $WD/data/info/samples-paths.txt -o $OUT_DIR

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
#SBATCH --error=03-qc-'$sample'.%j.err

echo $HOSTNAME

ml use /hpcapps/lib-tools/modules/all
ml load Anaconda3/2023.09-0 # load Anaconda
conda activate /hpcapps/env/conda/SNIC # activate conda environment
source ~/.bashrc

# iu-filter-quality-minoche /hpchome/cat3/projects/hanoxy/results/qc/TARA_030.ini --ignore-deflines
iu-filter-quality-minoche /hpchome/cat3/projects/hanoxy/results/qc/'$sample'.ini --ignore-deflines
gzip /hpchome/cat3/projects/hanoxy/results/qc/'$sample'-QUALITY_PASSED_R1.fastq
gzip /hpchome/cat3/projects/hanoxy/results/qc/'$sample'-QUALITY_PASSED_R2.fastq

''' > $WD/scripts/03-qc-$sample-pbs.sh
done