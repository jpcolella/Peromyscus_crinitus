#!/bin/bash
#SBATCH --job-name=pca
#SBATCH --output=pca.log

### RUN AS: script.sh #ind

### #ind = number of total individuals   
IND=$1

### PCA
### Determine the number of sites
gunzip angsd_global.mafs.gz # File generated in ANGSD
NSITES=`zcat angsd_global.mafs.gz | tail -n+2 | wc -l` # Will print the number of total sites

### Create a covariance matrix from angsd genotypes
gunzip angsd_global.geno.gz # This file, also generated in ANGSD
ngsCovar -probfile angsd_global.geno -outfile angsd_global.covar -nind $IND -nsites $NSITES -call 0 -norm 0

### Plot in R
