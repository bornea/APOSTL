#######################################################################################
# Python-code: SAINT pre-processing from Scaffold "Samples Report" output
# Author: Brent Kuenzi
#######################################################################################
# This program reads in a raw Scaffold "Samples Report" output and a user generated
# bait file and autoformats it into prey and interaction files for SAINTexpress
# analysis
#######################################################################################
# Copyright (C)  Brent Kuenzi.
# Permission is granted to copy, distribute and/or modify this document
# under the terms of the GNU Free Documentation License, Version 1.3
# or any later version published by the Free Software Foundation;
# with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
# A copy of the license is included in the section entitled "GNU
# Free Documentation License".
#######################################################################################
## REQUIRED INPUT ##

# 1) infile: Scaffold "Samples Report" output
# 2) baitfile: SAINT formatted bait file generated in Galaxy
# 3) fasta_db: fasta database for use (defaults to SwissProt_HUMAN_2014_08.fasta)
# 4) prey: Y or N for generating a prey file
# 5) make_bait: String of bait names, assignment, and test or control boolean
#######################################################################################

import sys
import os.path


infile = sys.argv[1] 
#Scaffold "Samples Report" output.
prey = sys.argv[2] 
# Y or N boolean from Galaxy.
fasta_db = sys.argv[3]
tool_path = r"/galaxy-apostl-docker/tools/Moffitt_Tools/"
if fasta_db == "None":
    fasta_db = str(tool_path)  + "/SwissProt_HUMAN_2014_08.fasta"
make_bait = sys.argv[6]
bait_bool = sys.argv[9]


def bait_create(baits, infile):
    # Verifies the Baits are valid in the Scaffold file and writes the Bait.txt.
    baits = make_bait.split()
    i = 0
    bait_file_tmp = open("bait.txt", "w")
    order = []
    bait_cache = []
    while i < len(baits):
        if baits[i+2] == "true":
            T_C = "C"
        else:
            T_C = "T"
        bait_line = baits[i] + "\t" + baits[i+1] + "\t" + T_C + "\n"
        read_infile = open(infile, "r")
        for input_line in read_infile:
            input_line = input_line.strip()
            temp = input_line.split('\t')
            if "Quantitative Variance" in str(temp):
                if baits[i] in temp:                    
                    number_bait = temp.index(str(baits[i]))
                    number_bait = number_bait - 9
                    bait_cache.append((number_bait, str(bait_line)))
                    # Locates the Bait names in the column names and then sets the Baits in the 
                    # correct order in the cache thus the - 9 because the baits start at the 9th
                    # column.
                else:
                    print "Error: bad bait " + str(baits[i])
                    sys.exit()
            else:
                pass
        i = i + 3

    bait_cache.sort()
    for cache_line in bait_cache:
        bait_file_tmp.write(cache_line[1])

    bait_file_tmp.close()

if bait_bool == 'false':
    bait_create(make_bait, infile)
    baitfile = "bait.txt"
else:
    bait_temp_file = open(sys.argv[10], 'r')
    bait_cache = bait_temp_file.readlines()
    bait_file_tmp = open("bait.txt", "wr")
    for cache_line in bait_cache:
        bait_file_tmp.write(cache_line)
    bait_file_tmp.close()
    baitfile = "bait.txt"


class ReturnValue1(object):
    def __init__(self, sequence, gene):
        self.seqlength = sequence
        self.genename = gene


class ReturnValue2(object):
    def __init__(self, getdata, getproteins, getheader):
        self.data = getdata
        self.proteins = getproteins
        self.header = getheader


def main(Scaffold_input, baits):
    bait_check(baitfile, Scaffold_input)
    make_inter(Scaffold_input)
    if prey == 'true':
        make_prey(Scaffold_input)
        no_error_inter(Scaffold_input)
        os.rename('prey.txt', sys.argv[5])
    elif prey == 'false':
        if os.path.isfile('error proteins.txt') == True:
            no_error_inter(Scaffold_input)
        pass
    elif prey != 'true' or 'false':
        sys.exit("Invalid Prey Argument: Y or N")


def get_info(uniprot_accession_in): 
    # Get aminoacid lengths and gene name.
    error = open('error proteins.txt', 'a+')
    data = open(fasta_db, 'r')
    data_lines = data.readlines()
    db_len = len(data_lines)
    seqlength = 0
    count = 0
    for data_line in data_lines:
        if ">sp" in data_line:
            namer = data_line.split("|")[2]
            if uniprot_accession_in == data_line.split("|")[1]:
                match = count + 1
                if 'GN=' in data_line:
                    lst = data_linedata_line.split('GN=')
                    lst2 = lst[1].split(' ')
                    genename = lst2[0]
                if 'GN=' not in data_line:
                    genename = 'NA'
                while ">sp" not in data_lines[match]:
                    if match <= db_len:
                        seqlength = seqlength + len(data_lines[match].strip())
                        match = match + 1
                    else:
                        break
                return ReturnValue1(seqlength, genename)
        elif uniprot_accession_in == namer.split(" ")[0]:
            match = count + 1
            # Ensures consistent spacing throughout.
            if 'GN=' in data_line:
                lst = data_line.split('GN=')
                lst2 = lst[1].split(' ')
                genename = lst2[0]
            if 'GN=' not in data_line:
                genename = 'NA'
            while ">sp" not in data_lines[match]:
                if match <= db_len:
                    seqlength = seqlength + len(data_lines[match].strip())
                    match = match + 1
                else:
                    break
            return ReturnValue1(seqlength, genename)
        count = count + 1
    if seqlength == 0:
        error.write(uniprot_accession_in + '\t' + "Uniprot not in Fasta" + '\n')
        error.close
        seqlength = 'NA'
        genename = 'NA'
        return ReturnValue1(seqlength, genename)


def readtab(infile):
    with open(infile, 'r') as input_file: 
    # read in tab-delim text
        output = []
        for input_line in input_file:
            input_line = input_line.strip()
            temp = input_line.split('\t')
            output.append(temp)
    return output


def read_Scaffold(Scaffold_input): 
    # Get data, proteins and header from Scaffold output
    dupes = readtab(Scaffold_input)
    cnt = 0
    for Scaffold_line in dupes:
        cnt += 1
        if Scaffold_line[0] == '#': 
        # Finds the start of second header.
            header_start = cnt-1
    header = dupes[header_start]
    prot_start = header.index("Accession Number")
    data = dupes[header_start+1:len(dupes)-2] 
    # Cut off blank line and END OF FILE.
    proteins = []
    for Scaffold_line in data:
        Scaffold_line[4] = Scaffold_line[4].split()[0]
        # Removes the (+##) that sometimes is attached.
    for protein in data:
        proteins.append(protein[prot_start])
    return ReturnValue2(data, proteins, header)


def make_inter(Scaffold_input):
    bait = readtab(baitfile)
    data = read_Scaffold(Scaffold_input).data
    header = read_Scaffold(Scaffold_input).header
    proteins = read_Scaffold(Scaffold_input).proteins
    bait_index = []
    for bait_line in bait:
        bait_index.append(header.index(bait_line[0]))
        # Find just the baits defined in bait file.
    with open('inter.txt', 'w') as inter_file:
        a = 0; l = 0
        for bb in bait:
            for lst in data:
                inter_file.write(header[bait_index[l]] + '\t' + bb[1] + '\t' + proteins[a] + '\t'
                        + lst[bait_index[l]] + '\n')
                a += 1
                if a == len(proteins):
                    a = 0; l += 1


def make_prey(Scaffold_input):
    proteins = read_Scaffold(Scaffold_input).proteins
    output_file = open("prey.txt", 'w')
    for protein in proteins:
        protein = protein.replace("\n", "")
        # Remove \n for input into function.
        protein = protein.replace("\r", "")
        # Ditto for \r.
        seq = get_info(protein).seqlength
        GN = get_info(protein).genename
        if seq != 'NA':
            output_file.write(protein + "\t" + str(seq) + "\t" + str(GN) + "\n")
    output_file.close()


def no_error_inter(Scaffold_input):
    # Remake inter file without protein errors from Uniprot.
    err = readtab("error proteins.txt")
    bait = readtab(baitfile)
    data = read_Scaffold(Scaffold_input).data
    header = read_Scaffold(Scaffold_input).header
    bait_index = []
    for bait_line in bait:
        bait_index.append(header.index(bait_line[0]))
    proteins = read_Scaffold(Scaffold_input).proteins
    errors = []
    for e in err:
        errors.append(e[0])
    with open('inter.txt', 'w') as y:
        l = 0; a = 0
        for bb in bait:
            for lst in data:
                if proteins[a] not in errors:
                    y.write(header[bait_index[l]] + '\t' + bb[1] + '\t' + proteins[a] + '\t'
                            + lst[bait_index[l]] + '\n')
                a += 1
                if a == len(proteins):
                    l += 1; a = 0


def bait_check(bait, Scaffold_input): 
    # Check that bait names share Scaffold header titles.
    bait_in = readtab(bait)
    header = read_Scaffold(Scaffold_input).header
    for i in bait_in:
        if i[0] not in header:
            sys.exit("Bait must share header titles with Scaffold output")

if __name__ == '__main__':
    main(infile, baitfile)

os.rename("inter.txt", sys.argv[4])
os.rename("bait.txt", sys.argv[7])
