#!/bin/bash
# 02-download-tara-oceans-mg-ena.sh

# tmux
# ssh slogin2

# load  modules
ml use /hpcapps/lib-tools/modules/all 
ml load NCBI/EDirect 

echo $HOSTNAME

# to insure work with python3
source $HOME/.bashrc

WD=$HOME/projects/hanoxy
cd $WD/data/raw

# ENA sra structure

# ftp://ftp.sra.ebi.ac.uk/vol1/fastq/<accession-prefix>/<full-accession>/
# ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR358/000/ERR3589559/ERR3589559_1.fastq.gz
# ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR599/ERR599077/ERR599077_1.fastq.gz
# https://ftp.sra.ebi.ac.uk/vol1/fastq/ERR358/006/ERR3589556/ERR3589556_1.fastq.gz
# https://ftp.sra.ebi.ac.uk/vol1/fastq/ERR315/ERR315863/ERR315863_1.fastq.gz

# ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR358/006/ERR3589556/ERR3589556_1.fastq.gz

# cat $WD/data/info/sra-accessions.txt | while read -r acc
cat $WD/data/info/sra-accessions.txt | while read -r acc
do
	echo $acc
	echo"""
	wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/"${acc:0:6}"/"$acc"/"$acc"_1.fastq.gz"
	wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/"${acc:0:6}"/"$acc"/"$acc"_2.fastq.gz"
	"""
done

mv $WD/data/raw/* /hpcdata/Mimir/cat3/raw
