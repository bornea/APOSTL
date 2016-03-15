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

def default_run(inter_file1,prey_file1,bait_file1,output_file1,num_of_rep1):
	cmd = r"/SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc " + r"-R" + str(num_of_rep1) + " " + str(inter_file1) + " " + str(prey_file1) + " " + str(bait_file1) 
	os.system(cmd) 
	open('list.txt')
	os.rename('list.txt', str(output_file1)) 

def with_L(inter_file1,prey_file1,bait_file1,output_file1,vc_num1,num_of_rep1):
	cmd = r"/SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc "+ r"-R" + str(num_of_rep1) + " " + r"-L" + str(vc_num1) + " " + str(inter_file1) + " " + str(prey_file1) + " " + str(bait_file1) 
	os.system(cmd) 
	open('list.txt')
	os.rename('list.txt', str(output_file1)) 

def external_data_no_L(inter_file1,prey_file1,bait_file1,output_file1,go_file1,num_of_rep1):
	cmd = r"/SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc "+ r"-R" + str(num_of_rep1) + " " + str(inter_file1) + " " + str(prey_file1) + " " + str(bait_file1) + " " + str(go_file1)
	os.system(cmd) 
	open('list.txt')
	os.rename('list.txt', str(output_file1)) 

def external_data_with_L(inter_file1,prey_file1,bait_file1,output_file1,go_file1,num_of_rep1,vc_num1):
	cmd = r"SAINTexpress_v3.6.1__2015-05-03/bin/SAINTexpress-spc "+ r"-R" + str(num_of_rep1) + " " + r"-L" + str(vc_num1) + " " + str(inter_file1) + " " + str(prey_file1) + " " + str(bait_file1) + " " + str(go_file1)
	os.system(cmd) 
	open('list.txt')
	os.rename('list.txt', str(output_file1)) 

if (vc_bool == "true"):
	if (go_bool == "false"):
		with_L(inter_file, prey_file, bait_file, output_file, vc_num, num_of_rep)
	elif (go_bool == "true"):
		external_data_with_L(inter_file, prey_file, bait_file, output_file, go_file, num_of_rep, vc_num)
elif (vc_bool == "false"):
	if (go_bool == "false"):
		default_run(inter_file, prey_file, bait_file, output_file, num_of_rep)
	elif (go_bool == "true"):
		external_data_no_L(inter_file, prey_file, bait_file, output_file, go_file, num_of_rep)