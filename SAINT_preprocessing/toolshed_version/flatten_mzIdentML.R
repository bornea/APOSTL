#! /usr/bin/Rscript
ins_check_run <- function() {
  if ("mzID" %in% rownames(installed.packages())){}
  else {
    source("https://bioconductor.org/biocLite.R")
    biocLite('mzID')
  }
  if ('dplyr' %in% rownames(installed.packages())){}
  else {
    install.packages('dplyr', repos='http://cran.us.r-project.org')
  }
}

ins_check_run()
args <- commandArgs(trailingOnly = TRUE)
#source("https://bioconductor.org/biocLite.R")
#biocLite("mzID")
library(mzID)
library(dplyr)
mzResults <- mzID(args[1])
flatresults <- flatten(mzResults)
write.table(flatresults,"flat_mzIdentML.txt",sep="\t",quote=FALSE,row.names=FALSE)