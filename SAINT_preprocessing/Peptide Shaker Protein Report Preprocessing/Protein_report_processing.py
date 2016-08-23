import sys
import os
from time import sleep

files = sys.argv[1] # read in a string of file names seperated by ", "
print files
# e.g. "Default_Protein_Report.txt, Default_Protein_Report_2.txt"
#bait = sys.argv[2] # SAINT formatted bait file
# still need a way to match files to bait identifiers
# or they can just be required to be put in the order of the bait file
quant_type = sys.argv[3] # what metric to use for quantification
print quant_type
# "#Validated Peptides", "#Peptides", "#Unique", "#Validated PSMs", "#PSMs"
db = sys.argv[4] # fasta database used in SearchGUI and PeptideShaker
print db
prey = sys.argv[5]
print prey
tool_path = sys.argv[7]
print tool_path
if db == "None":
    db = str(tool_path)  + "/SwissProt_HUMAN_2015_12.fasta"
make_bait = sys.argv[6]
print make_bait
bait_bool = sys.argv[8]
print bait_bool

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
        bait_cache.append(str(bait_line))
        i = i + 3

    for cache_line in bait_cache:
        bait_file_tmp.write(cache_line)

    bait_file_tmp.close()

if bait_bool == 'false':
    bait_create(make_bait, infile)
    bait = "bait.txt"
else:
    bait_temp_file = open(sys.argv[9], 'r')
    bait_cache = bait_temp_file.readlines()
    bait_file_tmp = open("bait.txt", "wr")
    for cache_line in bait_cache:
        bait_file_tmp.write(cache_line)
    bait_file_tmp.close()
    bait = "bait.txt"

class ReturnValue1(object):
    def __init__(self, sequence, gene):
        self.seqlength = sequence
        self.genename = gene

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
def concatenate_files(file_list_string, bait_file):
    file_list = file_list_string.split(",")
    bait = read_tab(bait_file)
    master_table = []
    header_check = 0
    file_cnt = 0
    table_cnt = 0
    for i in file_list:
        table = read_tab(i)
        for j in table:
            if table_cnt == 0:
                if header_check == 0:
                    header_check +=1
                    j.append("Replicate")
                    j.append("Bait_Grouping")
                    master_table.append(j)
            if table_cnt > 0:
                j.append(bait[file_cnt][0])
                j.append(bait[file_cnt][1])
                master_table.append(j)
            table_cnt +=1
        file_cnt+=1
        table_cnt = 0
    if len(master_table[0]) < len(master_table[1]):
        master_table[0] = ["#"] + master_table[0]
    with open("merged_PeptideShaker.txt","w") as x:
        for i in master_table:
            x.write("\t".join(i))
            x.write("\n")
    return master_table
def make_inter(master_table,quant_type):
    if len(master_table[0]) < len(master_table[1]):
        master_table[0] = ["#"] + master_table[0]
    replicate_index = master_table[0].index("Replicate")
    grouping_index = master_table[0].index("Bait_Grouping")
    accession_index = master_table[0].index("Main Accession")
    quant_type = quant_type.replace("_", " ")
    quant_type = r"#" + quant_type
    Quant_index = master_table[0].index(quant_type)
    inter_file = ""
    for i in master_table[1:]:
        line = []
        line.append(i[replicate_index])
        line.append(i[grouping_index])
        line.append(i[accession_index])
        line.append(i[Quant_index])
        inter_file = inter_file + "\t".join(line) + "\n"
    with open("inter.txt","w") as x:
        x.write(inter_file)
    
def make_prey(concat_table,fasta_db):
    input_data = concat_table
    if len(input_data[0]) < len(input_data[1]):
        input_data[0] = ["#"] + input_data[0]
    accession_index = input_data[0].index("Main Accession")
    proteins = []
    for i in input_data[1:]:
        proteins.append(i[accession_index])
    output_file = open("prey.txt", 'w')
    start = 0
    end = len(proteins)

    # Initial call to print 0% progress
    printProgress(start, end, prefix = 'Progress:', suffix = 'Complete', barLength = 50)

    for protein in proteins:
        seq = get_info(protein,fasta_db).seqlength
        GN = get_info(protein,fasta_db).genename
        if seq != 'NA':
            output_file.write(protein + "\t" + str(seq) + "\t" + str(GN) + "\n")
        start+=1
        printProgress(start, end, prefix = 'Progress:', suffix = 'Complete', barLength = 50)
    output_file.close()
data = concatenate_files(files,bait)
make_inter(data, quant_type)
if prey == "true":
    make_prey(data,db)

os.rename("bait.txt", sys.argv[2])
os.rename("inter.txt", sys.argv[10])
os.rename("prey.txt", sys.argv[11])