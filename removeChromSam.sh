#!/bin/bash

##########################

# removeChrom
# April 2018
# Jake Reske
# Michigan State University
# reskejak@msu.edu
# https://github.com/reskejak

# simple script to remove chromosomal reads from bam file (output as sam)
# usage: removeChromSam chr10 input.bam

# command idea based on https://www.biostars.org/p/128967/
# script format based on https://gist.github.com/taoliu/2469050

###########################

# check commands: samtools

which samtools &>/dev/null || { echo "samtools not found!"; exit 1; }

# end of checking

if [ $# -lt 2 ];then
    echo "Need 2 parameters! <chrom> <input.bam>"
    exit
fi

chr=$1
file=$2

samtools view -h ${file} | awk -v rem="$chr" '($3 != rem)' > ${file%.*}_${chr}filtered.sam
