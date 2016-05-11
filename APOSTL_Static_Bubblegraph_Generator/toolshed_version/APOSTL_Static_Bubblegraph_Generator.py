#######################################################################################
# Python-code: Bubblebeam wrapper
# Author: Adam L Borne
# Contributers: Paul A Stewart, Brent Kuenzi
#######################################################################################
# This program runs the R script that generates a bubble plot. Python script simply 
# handles arguments and interacts with Galaxy.
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

# 1) list_file: SaintExpress output file.
# 2) prey_file: Prey file listing gene name, sequence legnth, and gene id.
# 3) crapome: Crapome file can be created at http://crapome.org. (default = "None")
# 4) color: Fill color of the bubbles, if set to crapome it shades based on crapome
# potential. (default = "Red")
# 5) cutoff: Lower limit saint score for generating bubble plot. (default = 0.8)
# 6) mq_sc: MQ for MaxQuant data and SC for Scaffold data.
# 7) inc_file: List of uniprot ids to be used exclusively. (default = "None")
# 8) exc_file: List of uniprot ids to be excluded from plot. (default = "None")
#######################################################################################

import os 
import sys
import time


list_file = sys.argv[1]
prey_file = sys.argv[2]
crapome = sys.argv[3]
inter_file = sys.argv[4]
main_x = sys.argv[5]
main_y = sys.argv[6]
size_id = sys.argv[7]
color = sys.argv[8]
SS_cutoff = sys.argv[9]
FC_cutoff = sys.argv[10]
NS_cutoff = sys.argv[11]
theme = sys.argv[12]
label = sys.argv[13]
label_color = sys.argv[14]
bubble_color = sys.argv[15]
outline_color = sys.argv[16]
filt_color = sys.argv[17]
outfile = sys.argv[18]
ins_path = sys.argv[19]

if crapome == "None":
	crapome = "FALSE"

if color == "None":
	color = "Tan"

if theme == "None":
	theme = "Default"

if label_color == "None":
	label_color = "black"

if bubble_color == "None":
	bubble_color = "Alizarin crimson"

if outline_color == "None":
	outline_color = "black"

if filt_color == "None":
	filt_color = "tan"

if main_x == "lnNSAF":
	main_x = "\"ln(NSAF)\""
if main_y == "lnNSAF":
	main_y = "\"ln(NSAF)\""
if size_id == "lnNSAF":
	size_id = "\"ln(NSAF)\""

if main_x == "log2FoldChange":
	main_x = "\"log2(FoldChange)\""
if main_y == "log2FoldChange":
	main_y = "\"log2(FoldChange)\""
if size_id == "log2FoldChange":
	size_id = "\"log2(FoldChange)\""

if main_x == "logOddsScore":
	main_x = "\"log(OddsScore)\""
if main_y == "logOddsScore":
	main_y = "\"log(OddsScore)\""
if size_id == "logOddsScore":
	size_id = "\"log(OddsScore)\""


cmd = (r"Rscript "+ str(ins_path) + r"/Static_Bubble_Plot_Cmdln.R " + str(list_file) + r" "
    + str(prey_file) + r" " + str(crapome) + r" " + str(inter_file) + r" " + str(main_x) + r" " + str(main_y) + r" "
    + str(size_id) + r" " + str(color) + r" " + str(SS_cutoff) + r" " + str(FC_cutoff) + r" " + str(NS_cutoff)
    + r" " + str(theme) + r" " + str(label) + r" " + str(label_color) + r" " + str(bubble_color) + r" " + str(outline_color)
    + r" " + str(filt_color))
os.system(cmd)


open('./BubbleGraph.png')
os.rename('BubbleGraph.png', str(outfile))