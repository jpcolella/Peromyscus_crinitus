#!/bin/bash
#SBATCH --partition=shared,macmanes
#SBATCH --job-name=var_%j
#SBATCH --output=var_%j.log
#SBATCH --mem=100GB #MB
#SBATCH --exclude node117,node118

### Call variable sites in ANGSD with pvalue quality threshold
    ### To run pi/thetas downstream, we also need these options: -bam bam.filelist -doSaf 1 -anc chimpHg19.fa -GL 1
    ### NOT folded

#For Peromyscus crinitus (repeat for all species of interest)
angsd -b pecr_bamfiles.txt -anc pecr10X_c2_HiC_chrAll_sortRC.fasta -out angsd_pecr_var \
    -P 24 -SNP_pval 1e-6 -minMapQ 20 -minQ 20 -setMinDepth 20 -minInd 5 -GL 1 -doMaf 1 -doMajorMinor 1 -doGlf 2 -doPost 1 -doCounts 1 -doDepth 1 -dumpCounts 1 -doSaf 1

#OUTPUTS angsd_*spp*_var
  #Contains VARIABLES sites only
