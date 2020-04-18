#!/bin/bash
#SBATCH --job-name=SF_prep_step2
#SBATCH --output=SF_prep_step2.log

### RUN AS: script.sh chromosome_number
CHR=$1 ### chromosome number

### STEP 6: For each chromosome name, pull out lines containing that each chromosome and create file with info from columns 2, 9, 7 values*2 (diploid allele counts), and 8
for CHR in `cat chromosomes.txt`;
do 
    grep "$CHR" angsd_allvar.allcount | awk '{ print $2 "\t" $9 "\t" $7*2 "\t" $8}' > 'angsd_allvar.allcount.'$CHR
    ### Add header (position x n folded) to each file
    echo -e "position\tx\tn\tfolded" | cat - 'angsd_allvar.allcount.'$CHR > 'angsd_allvar.allcount.'$CHR.header
done

### STEP 7: Concatenate call angsd_$SPP_allvar.allcount.$CHR files using a regex
cat *[[:digit:]] > angsd_allvar.allcount.combined_nox

### STEP 8: Add header to combined output file
echo -e "position\tx\tn\tfolded" | cat - angsd_allvar.allcount.combined_nox > angsd_allvar.allcount.combined.header_nox

### STEP 9: Compute empirical SFS
SweepFinder2 -f angsd_allvar.allcount.combined.header_nox angsd_allvar.allcount.combined.spectrum.nox
