# Jake Reske
# Michigan State University
# June 2019

##########################################
# functions for automation of taxize annotation from taxonomer raw data
# e.g. supplying a list of NCBI IDs (ids)
##########################################

library(taxize)

taxAnnoSuperKingdom <- function(ids = NA) {
  anno.out <- data.frame(ids)
  colnames(anno.out) <- "ncbi.id"
  anno.out$superkingdom <- NA
  # loop to annotate
  for ( i in 1:length(anno.out$ncbi.id ) ) {
    j <- anno.out$ncbi.id[i]
    anno.j <- classification(j, db="ncbi")[[1]]
    # if ID cannot be classified (e.g. '1' for unclassified...)
    if ( any(is.na(anno.j)) ) { next } else {
      # else, check that superkingdom is annotated
      if ( !identical(anno.j$name[anno.j$rank=="superkingdom"], character(0)) ) {
        # add superkingdom annotation to output data frame
        anno.out$superkingdom[i] <- anno.j$name[anno.j$rank=="superkingdom"]
      }
    }
  }
  return(anno.out)
}

taxAnnoOrder <- function(ids = NA) {
  anno.out <- data.frame(ids)
  colnames(anno.out) <- "ncbi.id"
  anno.out$order <- NA
  # loop to annotate
  for ( i in 1:length(anno.out$ncbi.id ) ) {
    j <- anno.out$ncbi.id[i]
    anno.j <- classification(j, db="ncbi")[[1]]
    # if ID cannot be classified (e.g. '1' for unclassified...)
    if ( any(is.na(anno.j)) ) { next } else {
      # else, check that order is annotated
      if ( !identical(anno.j$name[anno.j$rank=="order"], character(0)) ) {
        # add order annotation to output data frame
        anno.out$order[i] <- anno.j$name[anno.j$rank=="order"]
      }
    }
  }
  return(anno.out)
}

taxAnnoFamily <- function(ids = NA) {
  anno.out <- data.frame(ids)
  colnames(anno.out) <- "ncbi.id"
  anno.out$family <- NA
  # loop to annotate
  for ( i in 1:length(anno.out$ncbi.id ) ) {
    j <- anno.out$ncbi.id[i]
    anno.j <- classification(j, db="ncbi")[[1]]
    # if ID cannot be classified (e.g. '1' for unclassified...)
    if ( any(is.na(anno.j)) ) { next } else {
      # else, check that family is annotated
      if ( !identical(anno.j$name[anno.j$rank=="family"], character(0)) ) {
        # add family annotation to output data frame
        anno.out$family[i] <- anno.j$name[anno.j$rank=="family"]
      }
    }
  }
  return(anno.out)
}

taxAnnoSubfamily <- function(ids = NA) {
  anno.out <- data.frame(ids)
  colnames(anno.out) <- "ncbi.id"
  anno.out$subfamily <- NA
  # loop to annotate
  for ( i in 1:length(anno.out$ncbi.id ) ) {
    j <- anno.out$ncbi.id[i]
    anno.j <- classification(j, db="ncbi")[[1]]
    # if ID cannot be classified (e.g. '1' for unclassified...)
    if ( any(is.na(anno.j)) ) { next } else {
      # else, check that subfamily is annotated
      if ( !identical(anno.j$name[anno.j$rank=="subfamily"], character(0)) ) {
        # add subfamily annotation to output data frame
        anno.out$subfamily[i] <- anno.j$name[anno.j$rank=="subfamily"]
      }
    }
  }
  return(anno.out)
}

taxAnnoGenus <- function(ids = NA) {
  anno.out <- data.frame(ids)
  colnames(anno.out) <- "ncbi.id"
  anno.out$genus <- NA
  # loop to annotate
  for ( i in 1:length(anno.out$ncbi.id ) ) {
    j <- anno.out$ncbi.id[i]
    anno.j <- classification(j, db="ncbi")[[1]]
    # if ID cannot be classified (e.g. '1' for unclassified...)
    if ( any(is.na(anno.j)) ) { next } else {
      # else, check that genus is annotated
      if ( !identical(anno.j$name[anno.j$rank=="genus"], character(0)) ) {
        # add genus annotation to output data frame
        anno.out$genus[i] <- anno.j$name[anno.j$rank=="genus"]
      }
    }
  }
  return(anno.out)
}

taxAnnoSpecies <- function(ids = NA) {
  anno.out <- data.frame(ids)
  colnames(anno.out) <- "ncbi.id"
  anno.out$species <- NA
  # loop to annotate
  for ( i in 1:length(anno.out$ncbi.id ) ) {
    j <- anno.out$ncbi.id[i]
    anno.j <- classification(j, db="ncbi")[[1]]
    # if ID cannot be classified (e.g. '1' for unclassified...)
    if ( any(is.na(anno.j)) ) { next } else {
      # else, check that species is annotated
      if ( !identical(anno.j$name[anno.j$rank=="species"], character(0)) ) {
        # add species annotation to output data frame
        anno.out$species[i] <- anno.j$name[anno.j$rank=="species"]
      }
    }
  }
  return(anno.out)
}
