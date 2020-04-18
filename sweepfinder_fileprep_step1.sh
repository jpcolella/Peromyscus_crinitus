#!/bin/bash
#SBATCH --job-name=SF_prep_step1
#SBATCH --output=SF_prep_step1.log

### GOAL: File preparation and work flow for running SweepFinder2 on low-coverage genomes

### Before Running this script:
    ### Create a "bamfiles.txt" file that lists the name of each bam filename on a different line
    ### Create a "chromosomes_nox.txt" file that contains each chromosome name on a different line, excluding the x chromosome
        ### To get chromosome names: grep ">" reference_genome.fasta

#Specify name and location of reference genome fasta file
REF= "reference_genome.fasta"

#STEP 1: Run ANGSD, including variable and invariable sites
angsd -b bamfiles.txt -anc $REF -out angsd_allvar -P 24 -minMapQ 20 -minQ 20 -setMinDepth 20 -minInd 5 -GL 1 -doMaf 1 -doMajorMinor 1 -doPost 1 -doCounts 1 -doDepth 1

### STEP 2: Unzip
gunzip -c angsd_allvar.mafs.gz > angsd_allvar.mafs

### STEP 3: Get allele counts - Add a tab-separated column that contains the product of column 6 ($6) * column 7 ($7) * 2 (because our species is diploid)
awk '{print $0 "\t" $6*$7*2}' angsd_allvar.mafs | awk '{printf "%.0f\n", $8}' > angsd_allvar.round

### STEP 4: Add an additional column of all 1's
awk '{print $0, "\t1"}' angsd_allvar.mafs > angsd_allvar.mafs.notfolded

### STEP 5: Merge files horizontally (e.g., across rows) and output to a new file
paste angsd_allvar.mafs.notfolded angsd_allvar.round > angsd_allvar.allcount
