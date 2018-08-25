# Jake Reske
# Michigan State University
# 8-24-2018

##############################
# format_write_gct.R

# functions to automate Broad GCT format generation, in R
# for downstream use with Broad GSEA functions via GenePattern, etc.
# for more details: http://software.broadinstitute.org/cancer/software/genepattern/file-formats-guide

# input is a matrix with genes as rownames and samples as colnames

##############################
format.gct <- function(x){
  x <- cbind(rownames(x),
             "NA",
             x)
  rbind(c("#1.2", 
          rep("", ncol(x)-1)),
        c(nrow(x), 
          ncol(x)-2, 
          rep("", ncol(x)-2)),
        colnames(x),
        x)
}
# output variable can be exported via write.table (sep="\t", quote=F, row.names=F, col.names=F

##############################
# expand this function to further automate subsequent write.table export
write.gct <- function(x, y=NULL){
  if(is.null(y)) y = paste0(deparse(substitute(x)),".gct") # deparse(substitute(x)) assigns "x", i.e. name of input variable
  x <- cbind(rownames(x),
             "NA",
             x)
  x <- rbind(c("#1.2", 
               rep("", ncol(x)-1)),
             c(nrow(x), 
               ncol(x)-2, 
               rep("", ncol(x)-2)),
             colnames(x),
             x)
  write.table(x,
              file=y, 
              sep="\t", quote=F, row.names=F, col.names=F)
}
