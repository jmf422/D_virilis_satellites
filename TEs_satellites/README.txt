# README.txt

The files in this folder go through the analysis of TEs localized to satellites.  

TEs_satellite_reads.sh: 
-Collected satellite-containing reads from output of NCRF  
-Run Repeat Masker using Drosophila repbase
-Produce a bed file 

simulate_PacBio_reads_satGypsy.sh
We did a simulation to evaluate how many reads would be expected to be at the interphase of boundaries of repetitive elements, e.g. pericentromeric satellite - TEs, or pericentromeric satellite - centromeric satellite.  
-Gypsy-10_Dvi was a common TE so we used its sequence in the simulation
-We also used the satellite AAACTAC.
-The script make_AAACTAC_gypsy_seq.R produces a fasta file with a continuous sequence containing a large block of satellite with clean boundaries to a block of gypsy sequence.
-We then simulate PacBio reads off this sequence using our actual read lengths to guide the simulation. subsample_fasta.py is used here.
-We then use NCRF and RepeatMasker to find find the reads with satellites and TEs respectively. 
 

The Rmarkdown file processes and displays the results.  

blast_satellite_reads2.sh shows how we tried to anchor reads to the genome and how very almost no reads had a unique match to non-TE regions of the genome.  



