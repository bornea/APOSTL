#######################################################################################
# Python-code: SAINT pre-processing from MaxQuant "Samples Report" output
# Author: Brent Kuenzi
#######################################################################################
# This program reads in a raw MaxQuant "Samples Report" output and a user generated
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

# 1) infile: MaxQuant "Samples Report" output
# 2) baitfile: SAINT formatted bait file generated in Galaxy
# 3) fasta_db: fasta database for use (defaults to SwissProt_HUMAN_2014_08.fasta)
# 4) prey: Y or N for generating a prey file
# 5) make_bait: String of bait names, assignment, and test or control boolean
#######################################################################################


import sys
import os


mq_file = sys.argv[1]
ins_path = "/galaxy-apostl-docker/tools/Moffitt_Tools/"
names_path = str(ins_path) + r"uniprot_names.txt"
cmd = (r"Rscript "+ str(ins_path) +"pre_process_protein_name_set.R " + str(mq_file) +
       " " + str(names_path))
os.system(cmd)

infile = "./tukeys_output.txt" 
# The MaxQuant "Samples Report" output.
prey = sys.argv[2] 
# Y or N boolean from Galaxy.
fasta_db = sys.argv[3]
if fasta_db == "None":
    fasta_db = str(ins_path)  + "SwissProt_HUMAN_2014_08.fasta"
make_bait = sys.argv[6]
bait_bool = sys.argv[9]

def bait_create(baits, infile):
    # Takes the Bait specified by the user and makes them into a Bait file and includes a
    # check to make sure they are using valid baits.
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
        for input_line in read_infile :
            input_line = input_line.replace("\"", "")
            input_line = input_line.replace(r"Intensity.", "")
            # R coerces "-" into "." changes them back and remove Intensity from the Bait names.
            input_line = input_line.replace(r".", r"-")
            temp = input_line.split()
            if "mapped_protein" in str(temp):
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
    # Writes cache to Bait file.
    bait_cache.sort()
    for line in bait_cache:
        bait_file_tmp.write(line[1])

    bait_file_tmp.close()


if bait_bool == 'false':
    bait_create(make_bait, infile)
    baitfile = "bait.txt"
else:
    bait_temp_file = open(sys.argv[10], 'r')
    bait_cache = bait_temp_file.readlines()
    bait_file_tmp = open("bait.txt", "wr")
    for line in bait_cache:
        bait_file_tmp.write(line)
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


def main(MaxQuant_input, make_bait):
    #bait_check(baitfile, MaxQuant_input)
    make_inter(MaxQuant_input)
    if prey == 'true':
        make_prey(MaxQuant_input)
        no_error_inter(MaxQuant_input)
        os.rename('prey.txt', sys.argv[5])
    elif prey == 'false':
        if os.path.isfile('error proteins.txt') == True:
            no_error_inter(MaxQuant_input)
        pass
    elif prey != 'true' or 'false':
        sys.exit("Invalid Prey Argument: Y or N")
    os.rename('inter.txt', sys.argv[4])
    os.rename("bait.txt", sys.argv[7])


def get_info(uniprot_accession_in): 
    # Get aa lengths and gene name.
    error = open('error proteins.txt', 'a+')
    data = open(fasta_db, 'r')
    data_lines = data.readlines()
    db_len = len(data_lines)
    seqlength = 0
    count = 0
    for data_line in data_lines:
        if ">sp" in data_line:
            if uniprot_accession_in == data_line.split("|")[1]:
                match = count + 1
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
    # Read in tab-delim text file.
        output = []
        for input_line in input_file:
            input_line = input_line.strip()
            temp = input_line.split('\t')
            output.append(temp)
    return output


def read_MaxQuant(MaxQuant_input):
    # Get data, proteins and header from MaxQuant output.
    dupes = readtab(MaxQuant_input)
    header_start = 0
    header = dupes[header_start]
    for var_MQ in header:
        var_MQ = var_MQ.replace(r"\"", "")
        var_MQ = var_MQ.replace(r"Intensity.", r"")
        var_MQ = var_MQ.replace(r".", r"-")
    data = dupes[header_start+1:len(dupes)]
    # Cut off blank line and END OF FILE.
    proteins = []
    for protein in data:
        proteins.append(protein[0])
    return ReturnValue2(data, proteins, header)


def make_inter(MaxQuant_input):
    bait = readtab(baitfile)
    data = read_MaxQuant(MaxQuant_input).data
    header = read_MaxQuant(MaxQuant_input).header
    proteins = read_MaxQuant(MaxQuant_input).proteins
    bait_index = []
    for bait_item in bait:
        bait_index.append(header.index("mapped_protein") + 1)
        # Find just the baits defined in bait file.
    with open('inter.txt', 'w') as y:
        a = 0; l = 0
        for bb in bait:
            for lst in data:
                y.write(header[bait_index[l]] + '\t' + bb[1] + '\t' + proteins[a] + '\t'
                        + lst[bait_index[l]] + '\n')
                a += 1
                if a == len(proteins):
                    a = 0; l += 1


def make_prey(MaxQuant_input):
    proteins = read_MaxQuant(MaxQuant_input).proteins
    output_file = open("prey.txt", 'w')
    for a in proteins:
        a = a.replace("\n", "")
        # Remove \n for input into function.
        a = a.replace("\r", "")
        # Ditto for \r.
        seq = get_info(a).seqlength
        GN = get_info(a).genename
        if seq != 'NA':
            output_file.write(a+"\t"+str(seq)+ "\t" + str(GN) + "\n")
    output_file.close()


def no_error_inter(MaxQuant_input):
    # Remake inter file without protein errors from Uniprot.
    err = readtab("error proteins.txt")
    bait = readtab(baitfile)
    data = read_MaxQuant(MaxQuant_input).data
    header = read_MaxQuant(MaxQuant_input).header
    header = [MQ_var.replace(r"\"", "") for MQ_var in header]
    header = [MQ_var.replace(r"Intensity.", r"") for MQ_var in header]
    header = [MQ_var.replace(r".", r"-") for MQ_var in header]
    bait_index = []
    for bait_item in bait:
        bait_index.append(header.index(bait_item[0]))
    proteins = read_MaxQuant(MaxQuant_input).proteins
    errors = []
    for e in err:
        errors.append(e[0])
    with open('inter.txt', 'w') as input_file:
        l = 0; a = 0
        for bb in bait:
            for lst in data:
                if proteins[a] not in errors:
                    input_file.write(header[bait_index[l]] + '\t' + bb[1] + '\t' + proteins[a] + '\t' 
                            + lst[bait_index[l]] + '\n')
                a += 1
                if a == len(proteins):
                    l += 1; a = 0


def bait_check(bait, MaxQuant_input):
    # Check that bait names share header titles.
    bait_in = readtab(bait)
    header = read_MaxQuant(MaxQuant_input).header
    for bait in bait_in:
        if bait[0] not in header:
            sys.exit("Bait must share header titles with MaxQuant output")

if __name__ == '__main__':
    main(infile, make_bait)
