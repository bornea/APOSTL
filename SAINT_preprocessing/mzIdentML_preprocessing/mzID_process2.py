# -*- coding: utf-8 -*-
"""
Python-code: Preprocess mzIdentML
@author = Brent Kuenzi
@email = Brent.Kuenzi@moffitt.org
"""
#######################################################################################
## Description: ##
#    This program will create inter, prey, and bait files from mzIdentML files
## Required input: ##
# 1) mzIdentML file to be reformatted
# 2) minimum PSM for quantification


import sys
import os

ins_path = sys.argv[5]

class ReturnValue1(object):
    def __init__(self, sequence, gene):
        self.seqlength = sequence
        self.genename = gene
class ReturnValue2(object):
    def __init__(self, inter, accessions):
        self.inter = inter
        self.accessions = accessions
def read_tab(infile):
    with open(infile,'r') as x:
        output = []
        for line in x:
            line = line.strip()
            temp = line.split('\t')
            output.append(temp)
    return output
def printProgress (iteration, total, prefix = '', suffix = '', decimals = 1, barLength = 100):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        barLength   - Optional  : character length of bar (Int)
    """
    formatStr       = "{0:." + str(decimals) + "f}"
    percents        = formatStr.format(100 * (iteration / float(total)))
    filledLength    = int(round(barLength * iteration / float(total)))
    bar             = '=' * filledLength + '-' * (barLength - filledLength)
    sys.stdout.write('\r%s |%s| %s%s %s' % (prefix, bar, percents, '%', suffix)),
    sys.stdout.flush()
    if iteration == total:
        sys.stdout.write('\n')
        sys.stdout.flush()
def get_info(uniprot_accession_in,fasta_db): 
    # Get aminoacid lengths and gene name.
    error = open('error proteins.txt', 'a+')
    data = open(fasta_db, 'r')
    data_lines = data.readlines()
    db_len = len(data_lines)
    seqlength = 0
    count = 0
    last_line = data_lines[-1]
    for data_line in data_lines:
        if ">sp" in data_line:
            namer = data_line.split("|")[2]
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
                        if data_lines[match] == last_line:
                            break
                        match = match + 1
                    else:
                        break
                return ReturnValue1(seqlength, genename)
        if uniprot_accession_in == namer.split(" ")[0]:
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
                    if data_lines[match] == last_line:
                        break
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
def make_inter(mzIdentML,replicate,grouping):
	accession_index = mzIdentML[0].index("accession")
	PSMs = {}
	accessions = []
	cnt = 0
	unique_lines = [mzIdentML[1:]]
	for i in mzIdentML[1:]:
		PSMs[i[accession_index]] = 0
		if i[accession_index] not in accessions:
			accessions.append(i[accession_index])
		if i not in unique_lines:
			unique_lines.append(i)
	for i in accessions:
		for j in unique_lines[1:]:
			if j[accession_index] == i:
				PSMs[j[accession_index]] +=1
	inter = ""
	for i in accessions:
		inter = inter + replicate + "\t" + grouping + "\t" + i + "\t" + str(PSMs[i]) + "\n"
	return ReturnValue2(inter,accessions)


files = sys.argv[1]
file_list = files.split(",")
bait = read_tab(sys.argv[2])
make_prey = sys.argv[3]
db = sys.argv[4]
if db == "None":
    db = str(ins_path)  + "/SwissProt_HUMAN_2015_12.fasta"
make_bait = sys.argv[6]
bait_bool = sys.argv[7]
prey_file = sys.argv[8]
bait_out = sys.argv[9]
inter_out = sys.argv[10]

def bait_create(baits):
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
        bait_cache.append(str(bait_line))
        i = i + 3

    for cache_line in bait_cache:
        bait_file_tmp.write(cache_line)

    bait_file_tmp.close()

if bait_bool == 'false':
    bait_create(make_bait)
    bait = "bait.txt"
else:
    bait_temp_file = open(sys.argv[2], 'r')
    bait_cache = bait_temp_file.readlines()
    bait_file_tmp = open("bait.txt", "wr")
    for cache_line in bait_cache:
        bait_file_tmp.write(cache_line)
    bait_file_tmp.close()
    bait = "bait.txt"

inter = ""
cnt = 0
accessions = []
for i in file_list:
	cmd = (r"Rscript "+ str(ins_path) +"flatten_mzIdentML.R " + i)
	os.system(cmd)
	mzIdentML = read_tab("flat_mzIdentML.txt")
	inter = inter + make_inter(mzIdentML,bait[cnt][0],bait[cnt][1]).inter
	accessions.append(make_inter(mzIdentML,bait[cnt][0],bait[cnt][1]).accessions)
	cnt+=1

with open("inter.txt","w") as x:
	x.write(inter)
if make_prey == "Y":
	unique_accessions = []
	prey = ""
	for i in accessions:
		for j in i:
			if j not in unique_accessions:
				unique_accessions.append(j)
	start = 0
	end = len(unique_accessions)
	printProgress(start,end,prefix = "Making Prey File:",suffix = "Complete",barLength=50)

	for i in unique_accessions:
		prey = prey + i + "\t" + str(get_info(i,db).seqlength) + "\t" + get_info(i,db).genename + "\n"
		start+=1
        printProgress(start, end)
	with open("prey.txt","w") as x:
		x.write(prey)

os.rename("bait.txt", sys.argv[2])
os.rename("inter.txt", sys.argv[10])
if str(prey) != "None": 
    os.rename("prey.txt", sys.argv[11])
