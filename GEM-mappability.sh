#!/bin/bash

# generating genome.fa mappability track
# see https://www.biostars.org/p/181014/ for explanation

# wigToBigWig executable located at /mnt/usr/bin/wigToBigWig
# note: mm10.fa genome from UCSC is softmasked by default, corresponding to lowercase letters
# softmasking corresponds to masking repeats that are still mappable with confidence

set -o nounset # Treat unset variables as an error

#GEM and bin should be exported to path prior to command execution
export PATH=/mnt/usr/bin/gemtools-1.7.1-i3:$PATH
export PATH=/mnt/usr/bin:$PATH

pref="mm10.softmask.all" # should be changed
reference="mm10.fa" # should be changed
idxpref="${pref}_index"
thr=22 # number of cores
outmappa="mm10.mappa.tsv" # should be changed
#make index for the genome
gem-indexer -T ${thr} --content-type dna -i ${reference} -o ${idxpref}
#indexing mm10.fa took <3 hours on 16 cores and 64gb RAM

# Calculate index and create mappability tracks with various kmer lengths
# kmer corresponds to mappability with a given read length; adjust as needed
for kmer in 45 50 75;
# compute mappability data
do gem-mappability -T ${thr} \
-I ${idxpref}.gem \
-l ${kmer} \
-o ${pref}_${kmer};
mpc=$(gawk '{c+=gsub(s,s)}END{print c}' s='!' ${pref}_${kmer}.mappability);
echo ${pref}_${kmer}"\t"$mpc >> $outmappa;
# convert results to wig and bigwig
gem-2-wig -I ${idxpref}.gem \
-i ${pref}_${kmer}.mappability \
-o ${pref}_${kmer};
wigToBigWig ${pref}_${kmer}.wig ${pref}.sizes ${pref}_${kmer}.bw;
done
# kmer=45 took <12 hours to compute with 22 cores and 64gb ram
