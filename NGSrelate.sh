#!/bin/bash
#SBATCH --job-name=relate
#SBATCH --output=relate.log

###GOAL: Test for relatedness (using ngsRelate) among individuals (run for each species or population separately)
REFERENCE = "reference_genome.fasta"
OUTFILE = "output_file_relate"

### Create list of variable sites by extracting the first 4 columns of the mafs file (generated in ANGSD) into a separate 'snplist' file
gunzip angsd_global.mafs.gz
cut -f 1,2,3,4 angsd_global.mafs| tail -n +2 > global_snplist.txt
angsd sites index global_snplist.txt

### Then run angsd:
angsd	-b bamfiles.txt	-anc $REFERENCE	-out $OUTFILE \
    -P 24 -SNP_pval 1e-6 -minMapQ 20 -minQ 20 -setMinDepth 20 -minInd 20 -minMaf 0.01 -GL 1 \
    -doMaf 1 -doMajorMinor 1 -doGlf 3 -doPost 1 -doGeno 32 -doCounts 1 -doDepth 1 -dumpCounts 1 -doSaf 1
    #NOTE: minMaf = 0.0 for relatedness testing
    
### Creat frequency file
gunzip angsd_relate.mafs.gz
cat angsd_relate.mafs | cut -f6 |sed 1d > angsd_relate.freq

### Run NGSrelate
ngsRelate -g angsd_relate.glf.gz -n 40 -f angsd_relate.freq  -O angsd_relate.newres
	#n = number of individuals
