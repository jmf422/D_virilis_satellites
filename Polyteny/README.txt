# README.txt

This folder contains files used to analyze the Polytene data.  

Trimmomatic was used to filter low quality sequences with the following command:

java -jar /programs/trimmomatic/trimmomatic-0.36.jar SE -phred33 $1.fastq.gz $1.trimmed.fastq.gz ILLUMINACLIP:/programs/trimmomatic/adapters/TruSeq3-SE.fa:2:30:10 SLIDINGWINDOW:5:20 MINLEN:90 

k-Seek was run using first: run_kSeek.sh followed by kcompile.sh  

These scripts were also run on the data after filtering.   

The Rmd files show the results of the analysis, including the same analysis on D. melanogaster data. 
-embryos and salivary glands from Yarosh and Spradling 2004
-flies from Gutzwiller et al. 2015.  

