
"""
Python-code: Merge Scaffold Samples Report files
@author = Brent Kuenzi
@email = Brent.Kuenzi@moffitt.org
"""
#######################################################################################
## Description: ##
#    This program will filter a fasta file using a data file
#    containing an "Accession" or "Accession Number" column
## Required input: ##
# 1) fasta file to be filtered
# 2) data file containing a "Accession" or "Accession Number" column


import sys
import os
def readtab(infile): # read in tab-delim text
    with open(infile,'r') as x:
        output = []
        for line in x:
            line = line.strip()
            temp = line.split('\t')
            output.append(temp)
    return output
def getAccessions(infile): # get list of protein accessions from your data
    data = readtab(infile)
    cnt = 0
    header_start = 0
    prot_start = 0
    for i in data:
        if "Accession Number" in i: # finds the start of header
            header_start = cnt
            break
        cnt += 1
    header = data[header_start]
    for i in header:
        if i == "Accession":
            prot_start = header.index("Accession")
        if i == "Accession Number":
            prot_start = header.index("Accession Number")
        if i == "Main Accession":
            prot_start = header.index("Main Accession")
    proteins = []
    for protein in data[header_start:]:
        if len(protein) > prot_start:
            proteins.append(protein[prot_start])
    return proteins
def FilterFastaSeq(infile,accession): # fasta file and UniprotID/SwissprotID
    input_data = readtab(infile)
    seq=[]
    header=[]
    temp=[]
    flag = 0
    cnt = 0
    for i in input_data:
        cnt+=1
        if flag == 1: # once we have a hit, start adding the sequences
            if ">" not in i[0]: # don't add the headers to the sequence
                temp.append(i[0])
        if i[0].startswith(">"): # is it a fasta header?    
            if temp != []: # if it is a continued fasta header, add old sequences to the sequence list
            # will this cutoff the last on of the file?
                merged = "\n".join(temp)
                if merged!="":
                    seq.append(merged)
                    temp=[]
            lst = i[0].split('|')
            ID1 = lst[1]
            lst2 = lst[2].split(' ')
            ID2 = lst2[0]
            flag = 0
            if ID1 in accession: # are the IDs part of your data?
                flag+=1
                header.append(i[0]) # if it is then append it
            if ID2 in accession: # are the IDs part of your data?
                flag+=1
                header.append(i[0]) # if it is then append it
        if cnt == len(input_data): # account for last fasta sequence in file
            if temp != []:
                merged = "\n".join(temp)
                if merged!="":
                    seq.append(merged)
    cnt=0
    x = open("output.txt","w")
    for i in header:
        x.write(i+'\n'+seq[cnt]+'\n')
        cnt+=1
    x.close()
fasta = sys.argv[1] # fasta file to filter
data = sys.argv[2] # scaffold report #2 -- filename

FilterFastaSeq(fasta,getAccessions(data))
os.rename("output.txt", sys.argv[3])