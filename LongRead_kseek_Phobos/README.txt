# README.txt  

This folder details the analysis of long read data, using the kSeek+Phobos approach.   

1) kseek_species.sh is the script used to run k-Seek on the long reads. First, long reads are chopped into 100 bp fragments and are converted to fastq for k-Seek.  

2) annotate_repeats_step1.sh is used next to select the parent reads which had subreads containing tandem repeats determined by k-Seek. Then, Phobos is run on the complete parent reads.  

3) annotate_repeats_step2.sh is used to then process the Phobos output files so total span can be estimated. Note that PHOBOS estimates are in bp not in copy number.  A supporting script used is remove_overlapping_windows_v2.r. 

4) R markdown file summarizes and shows the results for the species analyzed for this project.  

