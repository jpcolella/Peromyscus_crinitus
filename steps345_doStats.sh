#!/bin/bash
#SBATCH --job-name=S345_%j
#SBATCH --output=S345_%j.log

### After completing steps 1 and 2:

### STEP 3: Generate SFS from var sites
angsd/misc/realSFS angsd_pecr_var.saf.idx -P 24 > angsd_pecr_var.sfs

### STEP 4: Calculate thetas/pi and do a sliding window
angsd -b pecr_bamfiles.txt -anc pecr10X_c2_HiC_chrAll_sortRC.fasta  -out angsd_pecr_Win -doThetas 1 -doSaf 1 -pest angsd_pecr_var.sfs -GL 1

### STEP 5: Estimate stats (Tajima's D and others) for every Chromosome/scaffold
angsd/misc/thetaStat do_stat angsd_pecr_Win.thetas.idx
angsd/misc/thetaStat print angsd_pecr_Win.thetas.idx > angsd_pecr_Win.thetas.logSites.idx
  ### Last step makes the output readable

#Output in the .pestPG file (14 tab delim col) are the sum of the per site estimates for a region (e.g., chr)
        #The first column contains information about the region.
        #The second and third columns are the reference name and the center of the window.
        #Then there are 5 different estimators of theta: Watterson, pairwise, FuLi, fayH, L
        #And 5 different neutrality test statistics: Tajima's D, Fu&Li F's, Fu&Li's D, Fay's H, Zeng's E.
        #The final column is the effective number of sites with data in the window.
        
#*.logSites.idx looks like:
#Chromo Pos     Watterson       Pairwise        thetaSingleton  thetaH  thetaL
#chr1    7       -1.508250       -1.259530       -7.018687       -1.525145       -1.383545
#chr1    8       -1.508250       -1.259530       -7.018687       -1.525145       -1.383545
#chr1    9       -1.508249       -1.028086       -9.296788       -0.834603       -0.926673
