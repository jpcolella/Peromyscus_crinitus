#!/bin/bash
#SBATCH --job-name=SF_step3
#SBATCH --output=SF_step3_chrN.log

# RUN AS: script.sh chr#

# Specify Chromosome number:
CHR=$2

### STEP 10: Run Sweepfinder at 10kb windows 
SweepFinder2 -lg 10000 angsd_allvar.allcount.$CHR.header angsd_allvar.allcount.combined.spectrum.nox sweep_pecr_allvar.${CHR}_nox_10k > ${CHR}_10k.log

