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
# 2) Int_conf: Confidence of PPI from CPDB to include
#	   - low: no filtering
#	   - medium: >0.5
#	   - high: >0.7
#	   - very high: >0.9
# 3) Species: Human, Yeast, or Mouse
################################################################################


import urllib2
import itertools
import sys
import os


listfile = sys.argv[1]
Int_conf = sys.argv[2]
Species = sys.argv[3]
cyto_file = sys.argv[4]
db_path = sys.argv[5]

class ReturnValue1(object):
	def __init__(self, uniprot_acc, gene, swissprot):
		self.up = uniprot_acc
		self.gn = gene
		self.sp = swissprot
def main(listfile, Int_conf):
	network, accessions = dd_network(listfile,Int_conf)
	cytoscape(network, accessions)
def readtab(infile):
	with open(infile, 'r') as file_to_read:
	# Read in tab-delim text.
		output = []
		for line in file_to_read:
			line = line.strip()
			temp = line.split('\t')
			output.append(temp)
	return output
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
				return ReturnValue1(seqlength, genename, genename)
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
def dd_network(listfile, CPDB_filter):
	# Filter by SS and CPDB.
	data = readtab(listfile)
	accessions = []
	print "Converting identifiers..."
	for i in data:
		accessions.append(get_info(i[0]).sp)
	GO = {}
	print "Indexing all interactions..."
	for i in accessions: # create index table of all possible interactions
		GO[i] = []
		cnt=2
		for j in CPDB[2:]:
			if i in j[2]:
				GO[i].append(cnt)
			cnt+=1
	print "Filtering on interaction confidence..."
	for i in accessions: # filter interaction indices on confidence
		temp = []
		for j in GO[i]:
			if CPDB_filter != "NA":
				if CPDB[j][3] != "NA":
					if float(CPDB[j][3]) >= float(CPDB_filter):
						temp.append(j)
			if CPDB_filter == "NA":
				temp.append(j)
		GO[i] = temp
	GO2 = {}
	for i in accessions: # make interactions list friendly
		GO2[i] = []
		for j in GO[i]:
			GO2[i].append(CPDB[j][2].split(','))
	unfiltered_network = {}
	for i in accessions:
		interactions = []
		for j in GO2[i]:
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
	print "Creating data dependent network..."
	for i in accessions:
		temp = []
		for j in unfiltered_network[i]:
			if j in accessions: # must be in dataset
				if j not in temp: # no duplicates
					if j != i: # no self loops
						temp.append(j)
		dd_network[i] = temp
	return dd_network, accessions
def cytoscape(dd_network,accessions):
	print "Writing file..."
	with open('network.sif', 'wt') as y:
		for i in accessions:
			if dd_network[i] != []:
				lst = []
				for j in dd_network[i]:
					lst.append(j)
				for j in lst:
					y.write(i+'\t' + j+'\n')

if Species == "Human":
	CPDB = readtab(str(db_path) + 'ConsensusPathDB_human_PPI.txt')
if Species == "Yeast":
	CPDB = readtab(str(db_path) + 'ConsensusPathDB_yeast_PPI.txt')
if Species == "Mouse":
	CPDB = readtab(str(db_path) +'ConsensusPathDB_mouse_PPI.txt')
if __name__ == '__main__':
	main(listfile, Int_conf)
	os.rename('network.sif', str(cyto_file))
