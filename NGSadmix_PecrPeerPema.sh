#!/bin/bash
#SBATCH --job-name=admix
#SBATCH --output=admix.log

### Test for admixture and population structure using ngsAdmix
REFERENCE = "reference_genome.fasta"

### Run angsd to call variant sites and generate a beagle output file
angsd -b bamfiles.txt -anc $REFERENCE -out angsd_admix \
        -P 24 -SNP_pval 1e-6 -minMapQ 20 -minQ 20 -setMinDepth 20 -minInd 20 -minMaf 0.05 -GL 1 -doMaf 1 \
        -doMajorMinor 1 -doGlf 2 -doPost 1 -doGeno 32 -doCounts 1 -doDepth 1 -dumpCounts 1 -dosaf 1

### Run NGSadmix for K=1 through K = 20
source activate ngstools-20190326 # Varies depending on where ngstools is installed on your machine
for K in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; # Test K populations 1 through 20
    do NGSadmix -likes angsd_admix.beagle.gz -K $K -P 4 -o ngsadmix_${K} -minMaf 0.05;
done
