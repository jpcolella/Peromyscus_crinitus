#!/bin/bash
#SBATCH --job-name=S6_%j
#SBATCH --output=S6_%j.log

STEP 6: Do a NON-OVERLAPPING sliding window analysis, for Peromyscus eremicus:
angsd/misc/thetaStat do_stat angsd_pecr_Win.thetas.idx -win 1000 -step 1000 -type 2 -outnames angsd_pecr_Win.1kthetasWindow.gz
  ### type 2 = folded SFS
  ### Use this output to plot Tajima's D and calcuate global average
