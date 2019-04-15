# README.txt

This folder contains scripts used to analyze complex satellites in the genome assemblies (Tandem Repeats Finder) and in the raw reads (NCRF).  

1) In the genome assemblies:
-run trf_complex.sh followed by process_trfcomplex_virilis.sh. Files were modified for the correct file paths for each species.  
-this script used a python script: Booths_kmers_v2.py in order to organize the output of TRF into the Lexicographically minimal string rotation (Booth's algorithm).  
-For D. novamexicana, we had to separate the 00000018F contig because the program froze because the single contig contains ~1.5 of complex satellite.  

2) In the raw reads:
-We used NCRF_complex.sh for the 32 and 36 bp satellites as well as for the helitron satellite found previously.  
Even using 30% divergence allowed, NCRF didn't find as much complex satellites as what got assembled.  
