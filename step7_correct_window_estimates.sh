#!/bin/bash
#SBATCH --job-name=S7
#SBATCH --output=S7_%j.log

### RUN AS: script.sh KB_WIN_SIZE_INTEGER 
WIN=$1 ### window size in kb
REF="reference_genome_index.fasta.fai"

### GOAL: Correct estimate of nucleotide diversity (here, watterson's theta, equivalent to pi) based on the number of variant (vs. invariant) sites per window)
   ### And get a window-wise average

module load linuxbrew/colsa ### Varies depending on where your software is installed

### Make windows for entire genome - divide length of each chromosome by window size and make that many windows in tab delimited output file
bedtools makewindows -g $REF -w ${WIN}000 | awk '$3 ~ /000$/' | sed 's/ /\t/g'> genome_windows_${WIN}k.bed
    #Output (1k windows across all chr): genome_windows_1k.bed
    #chr1    0       1000
    #chr1    1000    2000
    #chr1    2000    300
    
### Remove the header:
tail -n +2 angsd_pecr_Win.thetas.logSites.idx > angsd_pecr_Win.thetas.logSites_nohead
    #-n +K  = to write output starting with the Kth line (here the 2nd line)
    
### Extract the 2nd field (e.g., the 1st col) and write to new file
cut -f2 angsd_pecr_Win.thetas.logSites_nohead | awk '{$1 = $1 + 1; print}' | paste angsd_pecr_Win.thetas.logSites_nohead - | awk 'BEGIN {FS="\t"};{ print $1"\t"$2"\t"$8"\t"$4}' | sed 's/ //g' > pi_pecr_global.bed


### NOW, loop through all chromosomes (names listed 1 per line in chromosomes.txt)
for CHR in `cat chromosomes.txt`; do

    ###make bed file for all variant and invariant sites for each chromosome
    grep "$CHR" angsd_pecr_allvar.mafs > pecr_allvar_${CHR}.mafs
    
    ### Extract fields 1 and 2 and put them into a new file
    cut -f 1,2 pecr_allvar_${CHR}.mafs > pecr_allvar.sites_${CHR}.txt

    ### Extract only the second field, add 1 to it (possibly due to 0 vs. 1 base indexing)
    cut -f2 pecr_allvar.sites_${CHR}.txt | awk '{$1 = $1 + 1; print}' | paste pecr_allvar.sites_${CHR}.txt - | sed 's/ //g'> pecr_allvar.sites_${CHR}.bed
        # first_col +1 (and add this as a third column)

    ### Split the genome window file into chromosomes
    grep "$CHR" genome_windows_${WIN}k.bed > genome_windows_${WIN}k_${CHR}.bed

    ### Calculate the number of sites in each window for each chromosome
    bedtools coverage -a genome_windows_${WIN}k_${CHR}.bed -b pecr_allvar.sites_${CHR}.bed -counts > pecr_allsites_${WIN}kbwin_${CHR}.txt
        # Adds a column of coverage/depth

    ### Extract the 4th field and replace 0's with NA's 
    cut -f4 pecr_allsites_${WIN}kbwin_${CHR}.txt | sed 's/^0/NA/g' > pecr_allsites_${WIN}kwin_NA_${CHR}.txt

    ### Split the per site theta file
    grep "$CHR" pi_pecr_global.bed > pi_pecr_global_${CHR}.bed
    
    ### e to the X with X being the values in col4 (e.g., Watterson's theta estimates per site)
    awk '{print exp($4)}' pi_pecr_global_${CHR}.bed | paste pi_pecr_global_${CHR}.bed - > pi_pecr_global_log_${CHR}.bed   
    bedtools map -a genome_windows_${WIN}k_${CHR}.bed -b pi_pecr_global_log_${CHR}.bed -c 5 -o sum | sed 's/\t[.]/\tNA/g' - > pi_pecr_global_log_${WIN}kbwin_${CHR}.txt
        # Values from B (col 5 -> exp(Watterson)) mapped onto intervales in A and removing NAs
        # 5th column is a the number of variable sites

    ### If it's an NA do nothing, otherwise divide col_4/col_5 (that is the sum of exp(Wattersons) divided by the total number of variant sites within the interval)
    ### to get an average value of Watterson's (measure of nucleotide diversity equivalent to pi) for a given window
    paste pi_pecr_global_log_${WIN}kbwin_${CHR}.txt pecr_allsites_${WIN}kwin_NA_${CHR}.txt | sed 's/[.]\t/NA\t/g' - > pi_pecr_global_log_${WIN}kbwin_sites_${CHR}.txt
    awk '{if(/NA/)var="NA";else var=$5/$4;print var}' pi_pecr_global_log_${WIN}kbwin_sites_${CHR}.txt | paste pi_pecr_global_log_${WIN}kbwin_sites_${CHR}.txt - > pi_pecr_global_log_${WIN}kbwin_sites_corrected_${CHR}.txt

done

#OUTPUT LOOKS LIKE THIS (without header)
#chr    start   stop    SUM(exp(WatTheta))   #varSites_perWin   (SUM/#varSites)
#chr23   0       1000    222.144159                   927            0.239638
#chr23   1000    2000    219.912544                  894             0.245987
#chr23   2000    3000    224.832897                  873             0.257541
#chr23   3000    4000    227.845044                  929             0.245258
#chr23   4000    5000    206.18176                   944             0.218413
