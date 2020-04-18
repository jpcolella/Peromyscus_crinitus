#!/Users/JocieColella/anaconda2/envs/py3/bin/python
import pandas as pd
import numpy as np
import scipy
import csv
import scipy.stats
import matplotlib.pyplot as plt
import glob
import os
import re

#GOAL:
# Find the global threshold for the N-th percentile of all the Composite Likelihood Ratios (CLRs) output from sweepfinder across all chromosomes (*.log files)
# Extract rows with significant values and write them to a new file (*_signifCLRs.out) for each chromosome

#NOTE:
# Run script from a directory that contains all the *.log files of interest (e.g., *.log outputs from sweepfinder)
# This script will cat/combine all log files ignoring header lines and last line:

### RUN AS: script.py threshold_float
    ### EXAMPLE for the 99.9th% threshold: script.py 99.9
N = float($1)

### If chromosomes are run independently through sweepfinder2, we must concatenate the results into a single file, named:
allCLRs = "allCLRS.txt" 
    ### Will not contain a headers, but will contain 3 tab delimited columns: location   CLR alpha

### List all the sweepfinder2 output log files (one for each chromsome) in the working directory
list_of_files = []
for log_file in glob.glob("*.log"):
    list_of_files.append(log_file)
print(list_of_files)

### Create a single file with all sweepfinder values from all chromosome files in a directory (without headers/footers)
with open(allCLRS, "w") as catfile:
    for each_file in list_of_files:
        with open(each_file, "r") as infile:
            lines = infile.readlines()[5:-1] ### The length of the header (5) and footer (-1) may change depending on which output file you use
            for line in lines:
                catfile.write(line)
catfile.close()

CLRs = []
with open("allCLRs.txt", "r") as file:
    lines = file.readlines()
    for line in lines:
        words = line.split()
        LRcol = words[1]
        CLRs.append(LRcol)
        
### Convert the list of str's to a new list of float's:
fl_CLRs=[]
for item in CLRs:
    fl_CLRs.append(float(item))
    
### Put data into numpy array and calculate global upper threshold limit
x = np.array(fl_CLRs)
upper = np.percentile(x,$N) ### Specify threshold limit here
print("Threshold = {0}".format(upper)) ### Prints the value corresponding to the prescribed threshold

### For each chromosome, find any CLR values above the global 99.9th percentile and write to a new file labeled with the chr name
for each_file in list_of_files:
    with open(each_file, "r") as infile:
    
        ### Extract first portion of file name to put into outfile name
        chr_name = each_file.split("_")[0]
        out_file_name = os.path.join(chr_name + "_signifCLRs.out")
        with open(out_file_name, "w") as outfile:
        
            ### Read in all but header and footer lines
            lines = infile.readlines()[1:-1]
            for line in lines:
                words = line.split()
                CLR_val = words[1]
                if float(CLR_val) > upper:
                    print("{0} Upper: {1}".format(chr_name, CLR_val))
                    outfile.write(line)
