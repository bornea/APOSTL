#######################################################################################
# Python-code: Dotplot Runner
# Author: Adam L Borne
# Contributers: Paul A Stewart, Brent Kuenzi
#######################################################################################
# This runs SAINTexpress found at http://saint-apms.sourceforge.net/Main.html in
# galaxy. 
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
import sys


inter_file = sys.argv[1]
prey_file = sys.argv[2]
bait_file = sys.argv[3]
num_of_rep = sys.argv[4]
vc_bool = sys.argv[5]
vc_num = sys.argv[6]
go_bool = sys.argv[7]
go_file = sys.argv[8]
output_file = sys.argv[9]
ins_path = sys.argv[10]


def first_run_check():
    dirs_list = []
    for (dirpath, dirnames, filename) in os.walk(str(ins_path)):
        dirs_list.extend(dirnames)
        break
    if r"SAINTexpress_v3.6.1__2015-05-03" in dirs_list:
        pass
    else:
        cmd = r"unzip " + str(ins_path) + "/SAINTexpress_v3.6.1__2015-05-03.zip -d " + str(ins_path)
        os.system(cmd)
        os.chdir(str(ins_path) + "/SAINTexpress_v3.6.1__2015-05-03")
        cmd1 = r"make -j"
        os.system(cmd1)


def default_run(inter_file1, prey_file1, bait_file1, output_file1, num_of_rep1):
    # Default is no virtual controls through purification and set replicates number.
    cmd = (str(ins_path) + r"/SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc " + r"-R"
           + str(num_of_rep1) + " " + str(inter_file1) + " " + str(prey_file1) +
           " " + str(bait_file1))
    os.system(cmd) 
    open('list.txt')
    os.rename('list.txt', str(output_file1)) 


def with_L(inter_file1, prey_file1, bait_file1, output_file1, vc_num1, num_of_rep1):
    # L is the flag for Virtual Controls through Purification.
    cmd = (str(ins_path) + r"/SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc "+ r"-R"
           + str(num_of_rep1) + " " + r"-L" + str(vc_num1) + " " + str(inter_file1) + " " +
           str(prey_file1) + " " + str(bait_file1))
    os.system(cmd) 
    open('list.txt')
    os.rename('list.txt', str(output_file1)) 


def external_data_no_L(inter_file1, prey_file1, bait_file1, output_file1, go_file1, num_of_rep1):
    # Uses external data in the GO file format and no Virtual Controls.
    cmd = (str(ins_path) + r"/SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc "+ r"-R"
           + str(num_of_rep1) + " " + str(inter_file1) + " " + str(prey_file1) + " " +
           str(bait_file1) + " " + str(go_file1))
    os.system(cmd) 
    open('list.txt')
    os.rename('list.txt', str(output_file1)) 


def external_data_with_L(inter_file1, prey_file1, bait_file1, output_file1, go_file1, num_of_rep1, vc_num1):
    # Uses external data in the GO file format and Virtual Controls.
    cmd = (str(ins_path) + r"/SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc "+ r"-R"
           + str(num_of_rep1) + " " + r"-L" + str(vc_num1) + " " + str(inter_file1) + " " +
           str(prey_file1) + " " + str(bait_file1) + " " + str(go_file1))
    os.system(cmd) 
    open('list.txt')
    os.rename('list.txt', str(output_file1)) 


first_run_check()
if vc_bool == "true":
    if go_bool == "false":
        with_L(inter_file, prey_file, bait_file, output_file, vc_num, num_of_rep)
    elif go_bool == "true":
        external_data_with_L(inter_file, prey_file, bait_file, output_file, go_file, num_of_rep, vc_num)
elif vc_bool == "false":
    if go_bool == "false":
        default_run(inter_file, prey_file, bait_file, output_file, num_of_rep)
    elif go_bool == "true":
        external_data_no_L(inter_file, prey_file, bait_file, output_file, go_file, num_of_rep)
