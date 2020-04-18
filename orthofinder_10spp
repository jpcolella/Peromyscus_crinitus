#!/bin/bash
#SBATCH --cpus-per-task=40
#SBATCH -J ortho
#SBATCH --output orthofind.log

### Run orthofinder
$HOME/OrthoFinder/orthofinder.py -t 40 -a 40 -M msa -S diamond -f /proteins
    # /proteins is a directory that contains *.functional.proteins.fasta files (generated in MAKER) for each of the 10 species examined
