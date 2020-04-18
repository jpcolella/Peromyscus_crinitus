#!/bin/bash
#SBATCH --job-name=mds
#SBATCH --output=mds.log

###GOAL: Multi-dimensional scaling (MDS)

REFERENCE = "reference_genome.fasta"
OUTNAME = "output_file_MDS"

### Create a list of variable sites by extracting the first 4 columns of the a mafs file (generated in ANGSD) into a separate 'snplist' file
gunzip angsd_global.mafs.gz
cut -f 1,2,3,4 angsd_global.mafs| tail -n +2 > global_snplist.txt
angsd sites index global_snplist.txt

### Then run angsd:
angsd -b bamfiles.txt -anc $REFERENCE -out $OUTNAME -P 24 -minMapQ 20 -minQ 20 -minInd 40 -GL 2 -doMajorMinor 3 -doMaf 1 -doIBS 1 -doCounts 1 -doCov 1 -makeMatrix 1 -minMaf 0.01 -sites global_snplist.txt
    #NOTE: -doMajorMinor 3 fixes the major allele to what is specified in the SNP list (this option is typically REQUIRED for comparisons between populations or species)
    #Outputs: pairwise differences (.ibsMat) and covariance matrix (.covMat)
