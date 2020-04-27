#!/bin/bash
#SBATCH --job-name=s2_%j
#SBATCH --output=s2_%j.log

### STEP 2: Call variant and invariant (allvar) sites for each species against the same reference (no pvalue threshold or snplist)

### For Peromyscus crinitus, do:
angsd -b pecr_bamfiles.txt -anc pecr10X_c2_HiC_chrAll_sortRC.fasta -out angsd_pecr_allvar \
        -P 24 -minMapQ 20 -minQ 20 -setMinDepth 20 -minInd 5 -GL 1 -doMaf 1 -doMajorMinor 1 -doGlf 2 -doPost 1 -doCounts 1 -doDepth 1 -dumpCounts 1 -dosaf 1
  ### Repeat for each species of interest

### OUTPUTS angsd_*spp*_allvar
  ### Includes both variable and invariable sites (used for window corrections downstream)
