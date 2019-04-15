# README.txt  

This folder contains scripts used to analyze the Illumina sequencing data of 12 strains of D. virilis, 8 strains of D. americana, and 5 strains of D. novamexicana.  

1) run_kSeek.sh is used to run the program k-Seek, followed by kcompile.sh.  

2) count_bases_illumina_virilis.sh is a script we used to count the number of bases sequenced so we can estimate depth for normalization.  

3) map_bowtie2_DINEs.sh was used to map Illumina reads to DINE-1 repeat sequences in order to estimate their abundance. vir_DINEs.fasta is the sequences of the DINEs we used (based on genome assembly analysis.  

4) seqdiv_satellites2.sh is the script we used to calculate sequence identity in the satellite reads. It uses the program NCRF, with modified parameters to allow for short reads.  

