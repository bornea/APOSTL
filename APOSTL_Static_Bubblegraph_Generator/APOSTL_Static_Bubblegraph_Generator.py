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
color = sys.argv[4]
label = sys.argv[5]
cutoff = sys.argv[6]
mq_sc = sys.argv[7]
inc_file = sys.argv[8]
exc_file = sys.argv[9]
output_file_name = sys.argv[10]
bub_zoom_NSAF = sys.argv[11]
bub_zoom_SAINT =sys.argv[12]
bub_SAINT = sys.argv[13]
bub_NSAF = sys.argv[14]

if crapome == "None":
	crapome = "FALSE"


if label == "false":
	label = "FALSE"
elif label == "true":
	label = "TRUE" 

cmd = r"Rscript /galaxy-apostl-docker/tools/Moffitt_Tools/bubblebeam/bubbles_v9_NSAF_natural_log.R " + str(list_file) + r" " + str(prey_file) + r" " + str(crapome) + r" " + str(color) + r" " + str(label) + r" " + str(cutoff) + r" " + str(mq_sc) + r" " + str(inc_file) + r" " + str(exc_file)
os.system(cmd)
time.sleep(3)

open('./output.txt')
os.rename('output.txt', str(output_file_name))

open('./bubble_zoom_NSAF.png')
os.rename('bubble_zoom_NSAF.png', str(bub_zoom_NSAF))

open('./bubble_zoom_SAINT.png')
os.rename('bubble_zoom_SAINT.png', str(bub_zoom_SAINT))

open('./bubble_SAINT.png')
os.rename('bubble_SAINT.png', str(bub_SAINT))

open('./bubble_NSAF.png')
os.rename('bubble_NSAF.png', str(bub_NSAF))

