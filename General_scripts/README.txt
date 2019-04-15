# README.txt

This folder contains supporting scripts used.

-count_bases_reads.sh counts the bases in all the reads in order to get an estimate of depth  
-fasta_to_fastq.pl is an open source perl script that converts a fasta file into a fastq file (gives perfect quality scores). It is used in several cases when particular programs need a fastq file, and I only have a fasta file - and quality scores are not important.  
-get_read_lengths.sh calculates the length of each read, the average length in the files, and the maximum read length.  
-mutation_satellite_calculations.xls shows how we calculated the expected percent identity if only base substitutions were occurring in the AAACTAC satellite, copy number remained constant, there was no recombination, and no selection was occurring.  
