#######################################################################################
# Python-code: Dotplot Runner
# Author: Adam L Borne
# Contributers: Paul A Stewart, Brent Kuenzi
#######################################################################################
# This script runs the dotplot program found at http://prohitstools.mshri.on.ca/.
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
# 2) FDR1: Primary false discovery rate. (default = 0.01)
# 3) FDR2: Secondary false discovery rate. (default = 0.025)
# 4) spec_max: Maximum spectral count. (default = 50)
#######################################################################################
import os 
import os
import sys


FDR1 = sys.argv[2]
FDR2 = sys.argv[3]
spec_max = sys.argv[4]
os.rename(sys.argv[1], "saint_input.txt")
ins_path = sys.argv[9]

dirs_list = []
for (dirpath, dirnames, filename) in os.walk(str(ins_path)):
    dirs_list.extend(dirnames)
    break
if r"Dotplot_Release" in dirs_list:
    pass
else:
    cmd = r"tar -xvf /Dotplot_Release.tar.gz " + str(ins_path) + "/Dotplot_Release.tar.gz" 
    os.system(cmd)


cmd = (str(ins_path) + r"Dotplot_Release/dotplot.bash -f saint_input.txt" + r" -c b -s " + str(FDR1) +
    r" -t " + str(FDR2) + " -m " + str(spec_max))
os.system(cmd)

cmd1 = r"cp -a ./Output_saint_input/. ."
os.system(cmd1)

os.rename("saint_input.txt", str(sys.argv[1]))
os.rename('dotplot.pdf', str(sys.argv[5])) 
os.rename('bait2bait.pdf', str(sys.argv[6])) 
os.rename('estimated.pdf', str(sys.argv[7])) 
os.rename('stats.pdf', str(sys.argv[8]))