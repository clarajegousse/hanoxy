#!/bin/bash
# 03-retrieve-tara-info-ncbi.sh

# tmux
# ssh slogin2

# load  modules
ml use /hpcapps/lib-tools/modules/all 
ml load NCBI/EDirect 

# to insure work with python3
source /users/home/cat3/.bashrc

WD=$HOME/projects/hanoxy
cd $WD/data/info


# # search for all TARA shotgun bioprojects focusing on prokaryotes
esearch -db BioProject -query TARA |\
 efetch -format docsum |\
 xtract -pattern DocumentSummary -element Project_Acc,Project_Name,Project_Title |\
  grep Shotgun | grep prokaryotes
# PRJEB9740 PRJEB1787

#-block Attributes -subset Attribute -if @attribute_name -equals "sample material label" -element Attribute \
esearch -db sra -query 'PRJEB41565[BioProject]' |\
efetch -format docsum |\
xtract -pattern DocumentSummary -element Biosample | while read -r smp ;
 do
	  esearch -db biosample -query $smp  </dev/null |\
	  efetch -format docsum |\
	  xtract -pattern DocumentSummary \
	  -block SampleData -element BioSample@accession \
	  -block Description -element Title,Organism@taxonomy_id \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Sampling Station" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Event Date/Time End" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Latitude Start" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Longitude Start" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Depth" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "temperature" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Salinity Sensor" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Nitrate Sensor" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Oxygen Sensor" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Chlorophyll Sensor" -element Attribute \
	  -block Attributes -subset Attribute -if @attribute_name -equals "Size Fraction Lower Threshold" -element Attribute
done > biosamples.txt

# cat biosamples.txt | awk 'BEGIN {FS="\t"}; NF>=12 && $NF!=""' > biosamples.txt

cat biosamples.txt | grep -P '\tTARA_[0-9]{3}\t'

#echo -e "biosample_accession\tplatform\trun_accession\ttotal-reads\ttotal_bases" > runs.txt
esearch -db sra -query 'PRJEB9740[BioProject] OR PRJEB1787[BioProject]' |\
efetch -format docsum |\
xtract -pattern DocumentSummary -element Biosample | while read -r smp ;
do
	  #echo 'blabla'$smp
	  esearch -db sra -query $smp </dev/null |\
	  efetch -format docsum |\
	  xtract -pattern DocumentSummary -element Biosample,Title \
	  -block Summary -element Platform@instrument_model \
	  -block Run -element Run@acc,Run@total_spots,Run@total_bases \
	  -block Library_descriptor -element LIBRARY_STRATEGY
 done > runs.txt

cat runs.txt | grep 'WGS' | grep 'paired' | cut -f 1,3,4,5,6,7 | sed 's/Illumina HiSeq /Illumina-HiSeq-/i' | grep 'Illumina-HiSeq-2*' > wgs-runs.txt

sort wgs-runs.txt > sorted-wgs-runs.txt

# select biosamples from the surface seawater (above 10m deep) and
# with lower size fractions of 0.22um to target prokaryotes
cat biosamples.txt | awk '$8 < 10 && $14 == 0.22' > srf-biosamples.txt
cat biosamples.txt | grep '5 m\|5m' | grep '0.22' > srf-biosamples.txt
sort srf-biosamples.txt | uniq > sorted-srf-biosamples.txt

join sorted-wgs-runs.txt sorted-srf-biosamples.txt | sed -e 's/5 m/5m/i' | sed -e 's/ /\t/g' > run-biosamples-infos.txt


# select biosamples without missing data (99999) and at latitude above 10 degree north
# cat run-biosamples-infos.txt | grep -v 99999 |  awk '$11 > 10' > selected-run-biosamples-infos.txt

echo -e """SAMEA7725442	Illumina HiSeq 4000	ERR5001722	33490414	5023562100	WGS	20170521_SI8_313_0m	408172	MIME_001	2017-05-21	68.0094	−18.8325	0	2.700	34.914	NA	NA	NA 0.22
SAMEA7725446	Illumina HiSeq 4000	ERR5006263	33065000	4959750000	WGS	20170530_SB5_429_0m	408172	MIME_002	2017-05-30	62.9878	-21.48	0	8.477	34.761	NA	NA	NA 0.22""" > mime-samples.txt

# all samples worldwide
cat run-biosamples-infos.txt mime-samples.txt | grep -v 99999 > selected-run-biosamples-infos.txt

# generate the list of sra accession numbers
cat selected-run-biosamples-infos.txt | cut -f 3 | sort | uniq > sra-accessions.txt

# generate the corresponding samples.txt file
cat selected-run-biosamples-infos.txt | cut -f 3,10 | awk 'BEGIN{print "sample\tr1\tr2"}{print $2 "\t" $1"_1.fastq.gz\t" $1"_2.fastq.gz"}' | sort | uniq > samples.txt
#cat samples.txt