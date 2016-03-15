#######################################################################################
# R-code: Protein Name and Tukey's Normalization
# Author: Adam L Borne
# Contributers: Paul A Stewart, Brent Kuenzi
#######################################################################################
# Assigns uniprot id from MaxQuant peptides file. Filters and normalizes the
# intensities of each proteins. Resulting in a one to one list of intensities to 
# uniprot id.
#######################################################################################
# Copyright (C)  Adam Borne.
# Permission is granted to copy, distribute and/or modify this document
# under the terms of the GNU Free Documentation License, Version 1.3
# or any later version published by the Free Software Foundation;
# with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
# A copy of the license is included in the section entitled "GNU
# Free Documentation License".
#######################################################################################
## REQUIRED INPUT ##

# 1) peptides_file: MaxQuant peptides file. 
#######################################################################################


ins_check_run <- function() {
  if ("affy" %in% rownames(installed.packages())){}
  else {
    source("https://bioconductor.org/biocLite.R")
    biocLite(c('mygene','affy'))
  }
  if ('data.table' %in% rownames(installed.packages())){}
  else {
    install.packages('data.table', repos='http://cran.us.r-project.org')
  }
  if ('stringr' %in% rownames(installed.packages())){}
  else {
    install.packages('stringr', repos='http://cran.us.r-project.org')
  }
  if ('VennDiagram' %in% rownames(installed.packages())){}
  else {
    install.packages('VennDiagram', repos='http://cran.us.r-project.org')
  }
}

ins_check_run()
library(data.table)
library(affy)
library(stringr)
library(mygene)
library(VennDiagram)


main <- function(peptides_file, db_path) {
	peptides_file = read.delim(peptides_file,header=TRUE,stringsAsFactors=FALSE,fill=TRUE)
  peptides_txt = peptides_file
	intensity_columns = names(peptides_txt[,str_detect(names(peptides_txt),"Intensity\\.*")])
  # Pulls out all lines with Intensity in them.
	intensity_columns = intensity_columns[2:length(intensity_columns)]
  # Removes the first column that does not have a bait. 
	peptides_txt_mapped = as.data.frame(map_peptides_proteins(peptides_txt))
  # This function as below sets every line to a 1 to 1 intensity to each possible protein.
	peptides_txt_mapped$Uniprot = str_extract(peptides_txt_mapped$mapped_protein, "[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}") #Pulls out just Uniprot id from the script.
	peptides_txt_mapped = subset(peptides_txt_mapped,!is.na(Uniprot))
  # Removes reverse sequences and any that didn't match a uniprot accession.
	columns_comb = c("Uniprot", intensity_columns) 
	peptides_mapped_intensity = subset(peptides_txt_mapped, select = columns_comb)
  # Subsets out only the needed cloumns for Tukeys (Uniprot IDS and baited intensities)/
	swissprot_fasta = scan(db_path, what="character")
	peptides_txt_mapped_log2 = peptides_mapped_intensity
  # Takes the log2 of the intensities. 
	for (i in intensity_columns) { 
		peptides_txt_mapped_log2[,i] = log2(subset(peptides_txt_mapped_log2, select = i))
	}
  # Get the minimum from each column while ignoring the -Inf; get the min of these mins for the 
  # global min; breaks when there's only one intensity column.
	global_min = min(apply(peptides_txt_mapped_log2[,2:ncol(peptides_txt_mapped_log2)],2,function(x) {
	  min(x[x != -Inf])
	}))
	peptides_txt_mapped_log2[peptides_txt_mapped_log2 == -Inf] <- 0
  #uniprot accessions WITHOUT isoforms; it looks like only contaminants contain isoforms anyways.
	mapped_protein_uniprotonly = str_extract(peptides_txt_mapped_log2$Uniprot,"[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}") 
	mapped_protein_uniprot_accession = str_extract(peptides_txt_mapped_log2$Uniprot,"[OPQ][0-9][A-Z0-9]{3}[0-9](-[0-9]+)?|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}(-[0-9]+)?|[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}")
	peptides_txt_mapped_log2$mapped_protein = mapped_protein_uniprotonly
  # Runs the Tukey function returning completed table.
  peptides_txt_mapped_log2 = subset(peptides_txt_mapped_log2,mapped_protein %in% swissprot_fasta)
	protein_intensities_tukeys = get_protein_values(peptides_txt_mapped_log2,intensity_columns)
  protein_intensities_tukeys[protein_intensities_tukeys == 1] <- 0
  write.table(protein_intensities_tukeys, "./tukeys_output.txt", row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")	

}

map_peptides_proteins = function(peptides_in) {
    peptides_in = subset(peptides_in,peptides_in$Proteins != "")
    results_list = list()
    k = 1
    for (i in 1:nrow(peptides_in)) {
        protein_names = peptides_in[i,"Proteins"]
        protein_names_split = unlist(strsplit(protein_names,";"))
        for (j in 1:length(protein_names_split)) {
            peptides_mapped_proteins = data.frame(peptides_in[i,],mapped_protein=protein_names_split[j],stringsAsFactors=FALSE)
            results_list[[k]] = peptides_mapped_proteins
            k = k+1
            
        }
    }
    return(rbindlist(results_list))
}

get_protein_values = function(mapped_peptides_in,intensity_columns_list) {
  unique_mapped_proteins_list = unique(mapped_peptides_in$mapped_protein) 
  # Gets list of all peptides listed.
  # Generates a blank data frame with clomns of Intensities and rows of Uniprots.
  Tukeys_df = data.frame(mapped_protein = unique_mapped_proteins_list, stringsAsFactors = FALSE ) 
  for (q in intensity_columns_list) {Tukeys_df[,q] = NA}
  for (i in 1:length(unique_mapped_proteins_list)) {
    mapped_peptides_unique_subset = subset(mapped_peptides_in, mapped_protein == unique_mapped_proteins_list[i])
    # Calculate Tukey's Biweight from library(affy); returns a single numeric.
    # Results_list[[i]] = data.frame(Protein=unique_mapped_proteins_list[i],Peptides_per_protein=nrow(mapped_peptides_unique_subset)).
    for (j in intensity_columns_list) {
      # Populates with new Tukeys values.
      Tukeys_df[i,j] = 2^(tukey.biweight(mapped_peptides_unique_subset[,j]))
    }
  }
  return(Tukeys_df)
}


args <- commandArgs(trailingOnly = TRUE)
main(args[1], args[2])
