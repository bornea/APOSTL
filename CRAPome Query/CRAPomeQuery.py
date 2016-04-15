# -*- coding: utf-8 -*-
"""
Created on Thu Apr 14 16:58:05 2016

@author: brentkuenzi
"""
import urllib2
import sys
import numpy

crappyData = sys.argv[1] # Prey file or File with single column of accessions
species = sys.argv[2] # HUMAN or YEAST
if species == "HUMAN":
    database = "Human_CRAPome_v1-1.txt"
if species == "YEAST":
    database = "Yeast_CRAPome_v1-1.txt"

class ReturnValue1(object):
    def __init__(self, uniprot_acc, gene, swissprot):
        self.up = uniprot_acc
        self.gn = gene
        self.sp = swissprot
def get_info(uniprot_accession_in): #get aa lengths and gene name
    error = open('error proteins.txt', 'a+')
    i=0
    while i==0:
        try:
            data = urllib2.urlopen("http://www.uniprot.org/uniprot/" + uniprot_accession_in + ".fasta")
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
def readtab(infile):
    with open(infile,'r') as x: # read in tab-delim text
        output = []
        for line in x:
            line = line.strip()
            temp = line.split('\t')
            output.append(temp)
    return output
def crapome(infile):
    data = readtab(infile)
    crapome = readtab(database)
    filt = []
    for i in data: # Filter crapome database
        flag = 0
        ac_flag = 0
        unique = 0
        if "_"+species in i[0]:
            ac = i[0]
        else:
            ac = get_info(i[0]).sp
            ac_flag +=1
        for j in crapome:
            if ac == j[2]:
                if ac_flag == 0:
                    if unique == 0:
                        filt.append(j)
                        flag+=1
                        unique+=1
                if ac_flag != 0:
                    if unique == 0:
                        unique+=1
                        j[2] = i[0]
                        filt.append(j)
                        flag +=1
        if flag == 0:
            filt.append(["\t", "\t", i[0], "Invalid identifier / gene not available"])
    total = 0
    query = []
    for i in filt: # Create crapome file
        temp=[]
        if len(i) > 5:
            cnt=0
            temp.append(i[2])
            temp.append(i[0])
            ave = []
            total = len(i[3:])
            for j in i[3:]:
                if j != '0':
                    ave.append(int(j))
                    cnt+=1
            temp.append(str(cnt) + " / "+str(total))
            if ave != []:
                temp.append(str(round(numpy.mean(ave),1)))
                temp.append(str(max(ave)))
            else:
                temp.append(0)
                temp.append(0)
        else:
            temp.append(i[2])
            temp.append(i[3])
        query.append(temp)
    header = ["User Input","Mapped Gene Symbol","Num of Expt. (found/total)","Ave SC","Max SC"]
    with open("Crappy Data.txt","wt") as x:
        x.write("\t".join(header) + "\n")
        for i in query:
            x.write("\t".join(i) + "\n")
if __name__ == '__main__':
    crapome(crappyData)