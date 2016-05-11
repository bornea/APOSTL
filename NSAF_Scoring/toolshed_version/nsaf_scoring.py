#######################################################################################
# Python-code: NSAF scoring wrapper
# Author: Adam L Borne
# Contributers: Paul A Stewart, Brent Kuenzi
#######################################################################################
# This program runs the R script that generates a nsaf scoring table. Python script simply 
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

# 1) listfile: SaintExpress output file.
# 2) preyfile: Prey file listing gene name, sequence legnth, and gene id.
# 3) crapfile: Crapome file can be created at http://crapome.org. (default = "None")
# 4) interfile: inter file from preprocessing script.
#######################################################################################
import os 
import sys
import time


listfile = sys.argv[1]
preyfile = sys.argv[2]
crapfile = sys.argv[3]
interfile = sys.argv[4]
ins_path = sys.argv[6]


cmd = (r"Rscript "+ str(ins_path) + r"/nsaf_scoring.R " + str(listfile) + r" "
    + str(preyfile) + r" " + str(crapfile) + r" " + str(interfile))
os.system(cmd)

os.rename("SaintTable.txt", sys.argv[5])
