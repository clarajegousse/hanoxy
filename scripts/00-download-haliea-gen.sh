#!/bin/bash
# 00-download-haliea-gen.sh

# tmux
# ssh slogin2

# load  modules
ml use /hpcapps/lib-tools/modules/all 
ml load NCBI/EDirect 

# set up directories
WD=$HOME/projects/hanoxy
mkdir -p $WD
cd $WD

GENOME_DIR=$WD/data/genomes
mkdir -p $GENOME_DIR

# get the list of genomes
# that belongs to the Halieaceae family in the GTDB
# query "GTDB Taxonomy" CONTAINS "f__Halieaceae"
# https://gtdb.ecogenomic.org

LIST=$WD/data/info/gtdb_halieaceae.tsv

# --- Download the genomes ----

cat $LIST | cut -f 1 | grep -v "organism_name" | while read -r acc ; do
  echo $acc
  esearch -db assembly -query $acc </dev/null \
    | esummary \
    | xtract -pattern DocumentSummary -element FtpPath_GenBank \
    | while read -r url ;
      do
	  # build the url
      # echo "$url/$fname"
      fname=$(echo $url | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/') ;

	  # download file from url
	   echo $fname
     wget --directory-prefix=$GENOME_DIR "$url/$fname"
    done
done

