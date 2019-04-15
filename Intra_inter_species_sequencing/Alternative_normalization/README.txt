# README.txt

This file goes through the analysis using a different normalization that shows consistent results with the final results.  
We chose to not use this normalization method because of potential mapping bias to the strains that the genome assemblies are from.  
We instead used a mapping-free method. The alternative normalization method using mapping + GC correction - a there is not a prominent GC bias in the sequencing data.  

1) mask_satellites_genomes.sh - this script masks the genome assemblies from the satellites so that satellite reads mapping to the assembly do not affect the GC correction. The file satellite_customlib.fasta is used to mask the genome with RepeatMasker.  

2) map_bowtie2_masked_virilis.sh - this script maskes the DNA sequencing reads to the masked genomes created above.  

3) GC_bias_diversity.sh runs the GC bias script we have described in previous papers: https://github.com/jmf422/Daphnia-MA-lines/tree/master/GC_correction .
It produced the files in the GC_normalization_masked_noXY directory.  

4) virilis_diversity_GCcorr.py produces the GC and depth corrected kmer counts in virilis_group.GCcorr.maskednolow.noXYvir.csv

5) Finally, the R markdown files summarize and display the results.  

