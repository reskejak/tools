
# ChromHMM_binarization_normalization.R
# Jake Reske
# Michigan State University (2020)

########################################

# Consider an experimental hg38 data set of chromatin features, "MyChromatinData", measured in two cell types and used to build a ChromHMM model.
# The following example ChromHMM command could be used to initially binarize e.g. paired-end signal and control ChIP-seq BAM files into the concatenated format:

# java -mx8000M -jar ~/bin/ChromHMM/ChromHMM.jar BinarizeBam -paired -o MyChromatinData_PE_control -t MyChromatinData_PE_signal \
# ~/bin/ChromHMM/CHROMSIZES/hg38.txt ~ MyChromatinData_bam_file.txt MyChromatinData_PE_binarization

# The purpose of this script is to normalize the number of binary presence calls for each feature across the measured cell types, from the initial binarization.
# It does so by ranking genomic bins by their (control-subtracted) signal values, then retaining only the top n 1-regions,
# where n is the lesser of the two binary presence calls between the two cell types, for a given feature on a given chromosome.
# The resulting normalized binarizations should be more directly comparable between the two cell types e.g. for differential chromatin state analysis.

# This idea was originally described by Fiziev et al. 2017 "Systematic Epigenomic Analysis Reveals Chromatin States Associated with Melanoma Progression" Cell Reports. (PMID: 28445736)
# See SI methods: https://www.cell.com/cms/10.1016/j.celrep.2017.03.078/attachment/91338c77-7d59-4215-8318-02a9ce43f9a4/mmc1

# Here, this script performs the following procedure for each chromosome and for e.g. both single-end and paired-end data sources:
# 1. Binarization, mark signal, and input control signal calls are imported for both cell types
# 2. Mark signal values are input-subtracted from respective control signals when available (e.g. for ChIP, does not occur for ATAC)
#     - This intermediate is saved for record
# 3. For each mark, input-subtracted signal values are ranked.
#     - This rank is used to select the top n binarization calls, where n is the lower value of calls between the two cell types
#         - e.g. if chr1 H3K18ac called 27,000 regions in control and 35,000 in treatment, then the top 27,000 are retained in both cell types
# 4. The new normalized binarization is saved, where each mark has the same number of 1-region calls in both cell types, per chromosome

# The resulting binarizationNormalized/*_binary.txt files can be merged and used for typical model learning downstream.

########################################
########################################
########################################

prefix <- "MyChromatinData" # identifier used before all file names
reads <- c("SE", "PE") # implement loop for both SE and PE data sources
conditions <- c("control", "treatment") # loop over both cell types i.e. conditions
chrs <- paste0("chr", c(seq(1:22),"X","Y","M")) # loop over all standard chromosomes
sink(paste0(prefix, "binarized_normalization_log.txt"), split=TRUE) # save output log
for (q in 1:length(reads)) {
  # for each read type (SE and PE)...
  for (i in 1:length(chrs)) {
    # for each chromosome (chr)...
    cat(paste("\n\nNow processing", reads[q], chrs[i]))
    # import binary calls and signal values (both mark and control read counts per bin) for first condition
    binary1 <-  read.table(paste0(prefix,"_",reads[q],"_binarization/",conditions[1],"_",chrs[i],"_binary.txt"),        sep="\t", skip=1, header=TRUE)
    signal1 <-  read.table(paste0(prefix,"_",reads[q],"_signal/",      conditions[1],"_",chrs[i],"_signal.txt"),        sep="\t", skip=1, header=TRUE)
    control1 <- read.table(paste0(prefix,"_",reads[q],"_control/",     conditions[1],"_",chrs[i],"_controlsignal.txt"), sep="\t", skip=1, header=TRUE)
    # repeat for second condition
    binary2 <-  read.table(paste0(prefix,"_",reads[q],"_binarization/",conditions[2],"_",chrs[i],"_binary.txt"),        sep="\t", skip=1, header=TRUE)
    signal2 <-  read.table(paste0(prefix,"_",reads[q],"_signal/",      conditions[2],"_",chrs[i],"_signal.txt"),        sep="\t", skip=1, header=TRUE)
    control2 <- read.table(paste0(prefix,"_",reads[q],"_control/",     conditions[2],"_",chrs[i],"_controlsignal.txt"), sep="\t", skip=1, header=TRUE)
    # sanity checks
    if ( nrow(binary1) == nrow(binary2) && nrow(signal1) == nrow(signal2) && nrow(control1) == nrow(control2) && 
         all(colnames(binary1) == colnames(binary2)) && all(colnames(signal1) == colnames(signal2)) && all(colnames(control1) == colnames(control2)) ) {
      cat("\nInput data are correctly matched") } else { cat("\nError: input data do not appear matched! Check data!") }
    # subtract respective input control signal for each mark
    signal1.sub <- signal1 # duplicate data
    signal2.sub <- signal2 # duplicate data
    for (z in 1:ncol(signal1)){
      mark.z <- colnames(signal1)[z]
      if (mark.z %in% colnames(control1)) {
        signal1.sub[,mark.z] <- signal1[,mark.z] - control1[,mark.z]
        signal2.sub[,mark.z] <- signal2[,mark.z] - control2[,mark.z]
      }
    }
    # write input-subtracted signal data to new table (as record)
    suppressWarnings(dir.create(paste0(prefix,"_",reads[q],"_subtractedSignal")))
    write.table(rbind(c(conditions[1], chrs[i], rep("", ncol(signal1.sub)-2)), colnames(signal1.sub), signal1.sub),
                file=paste0(prefix,"_",reads[q],"_subtractedSignal/",conditions[1],"_",chrs[i],"_subtractedSignal.txt"), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    write.table(rbind(c(conditions[2], chrs[i], rep("", ncol(signal2.sub)-2)), colnames(signal2.sub), signal2.sub),
                file=paste0(prefix,"_",reads[q],"_subtractedSignal/",conditions[2],"_",chrs[i],"_subtractedSignal.txt"), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    # for each mark, determine the lower # of 1-calls between the two conditions
    binary1new <- binary1 # duplicate data
    binary2new <- binary2 # duplicate data
    for (z in 1:ncol(binary1)){
      mark.z <- colnames(binary1)[z]
      binary1zn <- table(binary1[,mark.z]==1)["TRUE"]
      binary2zn <- table(binary2[,mark.z]==1)["TRUE"]
      # retain only the top n signal-input regions as presence, where n is the lower # of binary presence calls between the two conditions
      # THIS IS THE MAGIC OF THE SCRIPT!
      if (is.na(binary1zn) | is.na(binary2zn)) { 
        binary1new[,mark.z] <- 0
        binary2new[,mark.z] <- 0
      } else if (binary1zn < binary2zn) {
        z2.rnk <- order(signal2.sub[,mark.z], decreasing=TRUE)
        binary2new[z2.rnk, mark.z][binary2new[z2.rnk, mark.z]==1][(binary1zn+1):binary2zn] <- 0
      } else if (binary2zn < binary1zn) {
        z1.rnk <- order(signal1.sub[,mark.z], decreasing=TRUE)
        binary1new[z1.rnk, mark.z][binary1new[z1.rnk, mark.z]==1][(binary2zn+1):binary1zn] <- 0
      }
      # sanity check that lengths are same for 1-calls
      if (is.na(binary1zn) | is.na(binary2zn) && table(binary1new[,mark.z]==0)["TRUE"] == nrow(binary1new) && table(binary2new[,mark.z]==0)["TRUE"] == nrow(binary2new)) {
        cat(paste0("\n", mark.z, " was successfully normalized to 0 calls for ", chrs[i]))
      } else if ( table(binary1new[,mark.z]==1)["TRUE"] == table(binary2new[,mark.z]==1)["TRUE"] ) {
        cat(paste0("\n", mark.z, " was successfully normalized to ", min(binary1zn, binary2zn), " calls for ", chrs[i]))
      } else { cat(paste("\nError! Number of", mark.z, "calls is not equivalent.")) }
    }
    suppressWarnings(dir.create(paste0(prefix,"_",reads[q],"_binarizationNormalized")))
    # write new normalized binarization, where each cell type contains the same number of binary presence calls
    write.table(rbind(c(conditions[1], chrs[i], rep("", ncol(binary1new)-2)), colnames(binary1new), binary1new),
                file=paste0(prefix,"_",reads[q],"_binarizationNormalized/",conditions[1],"_",chrs[i],"_binary.txt"), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    write.table(rbind(c(conditions[2], chrs[i], rep("", ncol(binary2new)-2)), colnames(binary2new), binary2new),
                file=paste0(prefix,"_",reads[q],"_binarizationNormalized/",conditions[2],"_",chrs[i],"_binary.txt"), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
  }
}
