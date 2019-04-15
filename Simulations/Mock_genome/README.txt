# README.txt

 This directory contains the scripts used for using a mock genome to evaluate methods of quantifying satellites from long reads.
 
1) R script mock_genome.Rmd produces a mock D. virilis-like genome. Its contents were based on FISH analysis.
 Each chromosome contains a centromeric satellite (AAATTAC or AAACTAT) and a pericentromeric satellite (AAACTAC) followed by random sequence of a chosen GC content.
It also processes the results from the downstream analysis. 


2)  simulate_PacBio_reads.sh simulates PacBio reads off the virilis-like genome using the program PBSIM.  

3) simulate_Kseek_phobos.sh takes the simulated data and quantifies the satellites with the k-Seek + Phobos approach.  

4) simulate_NCRF.sh runs NCRF using different maximum divergence parameters on the simulated data.  
It outputs the file repeats.found.percents.  

