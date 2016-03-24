#######################################################################################
# Python-code: Shiny Bubblebeam wrapper
# Author: Adam L Borne
# Contributers: Paul A Stewart, Brent Kuenzi
#######################################################################################
# This program runs the R script that generates a bubble plot in shiny. Generates
# a unique app for each run of the tool for galaxy integration.
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
#######################################################################################
import os
import sys
import time

input_list = open(sys.argv[1], 'r')
prey_input = open(sys.argv[2], 'r')
inter_input = open(sys.argv[4], 'r')
stamped_app = r"shiny_bubble" + str(time.strftime('_%d_%m_%Y_%H_%M'))

cmd = r"mkdir /srv/shiny-server/" + str(stamped_app)
os.system(cmd)

cmd1 = r"cp -r /srv/shiny-server/shiny_bubble/. /srv/shiny-server/" + str(stamped_app)
os.system(cmd1)

if sys.argv[3] == 'None':
    glob_manip = open('/srv/shiny-server/shiny_bubble/global.R', 'r')
    glob_write = open('/srv/shiny-server/'+ str(stamped_app) + '/global.R', 'w')
    for code_line in glob_manip:
        if r"working <- as.data.frame" in code_line:
            glob_write.write("working <- as.data.frame(merge_files(\"EGFR_list.txt\", \"EGFR_prey.txt\", FALSE))")
        else:
            glob_write.write(code_line)
else: 
    crapome = open(sys.argv[3], 'r')
    crap_file = open('/srv/shiny-server/'+ str(stamped_app) + '/EGFR_crap.txt', 'w')
    for line in crapome:
        crap_file.write(line)
    crapome.close()

input_file = open('/srv/shiny-server/'+ str(stamped_app) + '/EGFR_list.txt', 'w')
for line in input_list:
	input_file.write(line)
prey_file = open('/srv/shiny-server/'+ str(stamped_app) + '/EGFR_prey.txt', 'w')
for line in prey_input:
	prey_file.write(line)
inter_file = open('/srv/shiny-server/'+ str(stamped_app) + '/inter.txt', 'w')
for line in inter_input:
    inter_file.write(line)
#crapome = open(sys.argv[3], 'r')
#crap_file = open('/srv/shiny-server/'+ str(stamped_app) + '/EGFR_crap.txt', 'w')
#for line in crapome:
#    crap_file.write(line)
#crapome.close()




input_file.close()
prey_file.close()
inter_file.close()


#cmd1 = r"touch '/srv/shiny-server/" + str(stamped_app) + r"/restart.txt"
#os.system(cmd1)

with open("shiny.txt", "wt") as x:
    x.write("<html><body> Open <a href=\"http://54.213.221.126:3838/" +
            str(stamped_app) + "\">APOSTL Interactive Analysis</a> in your browser to view shiny app. If there are issues with the sizing within galaxy you can right" 
            + " click and open in a new tab or window.</body></html>")

os.rename('shiny.txt', str(sys.argv[5]))
