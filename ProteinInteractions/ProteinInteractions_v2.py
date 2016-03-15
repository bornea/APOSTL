################################################################################
# This program will read in a SAINT 'list.txt' file and the interactions from
# the consensus path db database and return all the interactions that we saw in
# our experiment in a format suitable for cytoscape. This allows us to filter
# before getting PPIs so that it doesn't affect our SAINT score or include
# interactions that don't score well
################################################################################
# Copyright (C)  Brent Kuenzi.
# Permission is granted to copy, distribute and/or modify this document
# under the terms of the GNU Free Documentation License, Version 1.3
# or any later version published by the Free Software Foundation;
# with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
# A copy of the license is included in the section entitled "GNU
# Free Documentation License".
################################################################################
## REQUIRED INPUT ##

# 1) listfile: SAINTexpress output
# 2) SAINT_cutoff: Saint score cutoff for import (between 0 and 1)
# 3) Int_conf: Confidence of PPI from CPDB to include
#       - low: no filtering
#       - medium: >0.5
#       - high: >0.7
#       - very high: >0.9
# 4) Species: Human, Yeast, or Mouse
################################################################################


import urllib2
import itertools
import sys
import os


listfile = sys.argv[1]
SAINT_cutoff = sys.argv[2]
Int_conf = sys.argv[3]
Species = sys.argv[4]
cyto_file = sys.argv[5]
db_path = r"/galaxy-apostl-docker/tools/Moffitt_Tools/"

class ReturnValue1(object):
    def __init__(self, uniprot_acc, gene, swissprot):
        self.up = uniprot_acc
        self.gn = gene
        self.sp = swissprot
class ReturnValue2(object):
    def __init__(self, getdata, getproteins, getheader):
        self.data = getdata
        self.proteins = getproteins
        self.header = getheader


def main(listfile, SAINT_cutoff, Int_conf, Species):
    cytoscape(dd_network(listfile, SAINT_cutoff, Int_conf), listfile, SAINT_cutoff)


def readtab(infile):
    with open(infile, 'r') as file_to_read:
    # Read in tab-delim text.
        output = []
        for line in file_to_read:
            line = line.strip()
            temp = line.split('\t')
            output.append(temp)
    return output


def read_listfile(listfile): 
    # Get data, proteins and header from scaffold output
    dupes = readtab(listfile)
    header = dupes[0]
    prot_start = header.index("PreyGene")-1
    data = dupes[1:]
    # Cut off blank line and END OF FILE.
    proteins = []
    for protein in data:
        proteins.append(protein[prot_start])
    return ReturnValue2(data, proteins, header)


def get_info(uniprot_accession_in): 
    # Get aa lengths and gene name.
    error = open('error proteins.txt', 'a+')
    i = 0
    while i == 0:
        try:
            data = urllib2.urlopen("http://www.uniprot.org/uniprot/" + uniprot_accession_in
                + ".fasta")
            break
        except urllib2.HTTPError, err:
            i = i + 1
            if i == 50:
                sys.exit("More than 50 errors. Check your file or try again later.")
            if err.code == 404:
                error.write(uniprot_accession_in + '\t' + "Invalid URL. Check protein" + '\n')
                seqlength = 'NA'
                genename = 'NA'
                return ReturnValue1(seqlength, genename)
            elif err.code == 302:
                sys.exit("Request timed out. Check connection and try again.")
            else:
                sys.exit("Uniprot had some other error")
    lines = data.readlines()
    header = lines[0]
    lst = header.split('|')
    lst2 = lst[2].split(' ')
    swissprot = lst2[0]
    uniprot_acc = lst[1]
    if lines == []:
        error.write(uniprot_accession_in + '\t' + "Blank Fasta" + '\n')
        error.close
        uniprot_acc = 'NA'
        genename = 'NA'
        return ReturnValue1(uniprot_acc, genename, swissprot)
    if lines != []:
        seqlength = 0
        header = lines[0]
        if 'GN=' in header:
            lst = header.split('GN=')
            lst2 = lst[1].split(' ')
            genename = lst2[0]
            error.close
            return ReturnValue1(uniprot_acc, genename, swissprot)
        if 'GN=' not in header:
            genename = 'NA'
            error.close
            return ReturnValue1(uniprot_acc, genename, swissprot)


def dd_network(listfile, SAINTscore, CPDB_filter): 
    # Filter by SS and CPDB.
    data = read_listfile(listfile).data
    # Change to filtered list.
    SS = (read_listfile(listfile).header).index("SaintScore")
    filt_data = []
    for i in data:
        if i[SS] >= SAINTscore:
            filt_data.append(i)
    accessions = []
    for i in filt_data:
        accessions.append(get_info(i[1]).sp)
    GO = []
    for i in CPDB[2:]:
        if i[3] >= CPDB_filter:
        # Filter interaction confidence.
            GO.append(i[2])
            # All known interactions.
    GO2 = []
    for i in GO:
        GO2.append(i.split(','))
        # Make interactions list friendly.
    unfiltered_network = {}
    for i in accessions:
        interactions = []
        for j in GO2:
            if i in j:
            # Find the interactions.
                if j not in interactions:
                # Dont add duplicate interactions.
                    interactions.append(j)
        merged = list(itertools.chain(*interactions))
        # Flatten list of lists.
        unfiltered_network[i] = merged
        # Assign all possible interactions to protein in a dictionary.
    dd_network = {}
    # Data dependent network.
    for i in unfiltered_network:
        temp = []
        for j in unfiltered_network[i]:
            if j in accessions:
                if j not in temp:
                    if j != i:
                        temp.append(j)
        dd_network[i] = temp
    return dd_network


def cytoscape(dd_network, listfile, SAINTscore):
    with open('network.sif', 'wt') as y:
        data = read_listfile(listfile).data
        SS = (read_listfile(listfile).header).index("SaintScore")
        filt_data = []
        for i in data:
            if i[SS] >= SAINTscore:
                filt_data.append(get_info(i[1]).sp)
        for i in filt_data:
            if dd_network[i] != []:
                lst = []
                for j in dd_network[i]:
                    lst.append(j)
                for j in lst:
                    y.write(i+'\t'+'pp'+'\t' + j+'\n')


if Species == "Human":
    CPDB = readtab(str(db_path) + 'ConsensusPathDB_human_PPI.txt')
if Species == "Yeast":
    CPDB = readtab(str(db_path) + 'ConsensusPathDB_yeast_PPI.txt')
if Species == "Mouse":
    CPDB = readtab(str(db_path) +'ConsensusPathDB_mouse_PPI.txt')
if __name__ == '__main__':
    main(listfile, SAINT_cutoff, Int_conf, Species)
    os.rename('network.sif', str(cyto_file))
