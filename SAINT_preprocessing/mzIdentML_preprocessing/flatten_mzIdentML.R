#! /usr/bin/Rscript
args <- commandArgs(trailingOnly = TRUE)
#source("https://bioconductor.org/biocLite.R")
#biocLite("mzID")
library(mzID)
library(dplyr)
mzResults <- mzID(args[1])
flatresults <- flatten(mzResults)
write.table(flatresults,"flat_mzIdentML.txt",sep="\t",quote=FALSE,row.names=FALSE)