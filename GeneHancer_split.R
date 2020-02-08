###################################
# Jake Reske
# reskejak@msu.edu
# Michigan State University, 2020

# GeneHancer_split.R
# script to manipulate GeneCards GeneHancer database in R for efficient querying

# Base data contains an "attributes" column which contains varying lengths of associated genes for each enhancer locus
# Here, we will create a GRanges object containing multiple rows per enhancer locus, each corresponding to 1 associated gene link.
###################################

# in R

# import GeneHancer (v4.4) database
# download database via GeneCards: https://www.genecards.org/GeneHancer_version_4-4
genehancer <- read.table("~/GeneHancer_version_4-4.txt", sep="\t", header=T)
 
genehancer.split <- data.frame(chrom=NA, source=NA, feature.name=NA, start=NA, end=NA, score=NA, strand=NA, frame=NA,
                               genehancer_id=NA, connected_gene=NA, connected_gene_score=NA)
for (i in 1:nrow(genehancer)) {
  atts <- strsplit(as.character(genehancer$attributes[i][[1]]), split=";")[[1]]
  for (j in 1:(length(atts[-1])/2)) {
    genehancer.split <- rbind(genehancer.split,
                              cbind(genehancer[i,c(1:8)],
                                    genehancer_id=strsplit(atts[1], split="=")[[1]][2], 
                                    connected_gene=strsplit(atts[-1][(1+((j-1)*2))], split="=")[[1]][2],
                                    connected_gene_score=strsplit(atts[-1][(2+((j-1)*2))], split="=")[[1]][2]))
  }
}
genehancer.split <- genehancer.split[-1,] # remove initilization row
# write.table(genehancer.split, file="GeneHancer_version_4-4_split.txt")
 
genehancer.split <- GRanges(genehancer.split) # make GRanges object
# genehancer.split[!duplicated(genehancer.split)] # gut check: X unique ranges
 
 ###############
# test interrogation: get genes associated with enhancers which intersect with H3K27ac ChIP-seq
genehancer.H3K27ac.ChIP <- subsetByOverlaps(genehancer.split, H3K27ac.ChIP)
unique(genehancer.H3K27ac.ChIP$connected_gene) # unique enhancer-associated genes
genehancer.H3K27ac.ChIP[!duplicated(genehancer.H3K27ac.ChIP)] # unique enhancers
