# make mock haplotype with AAACTAC tandem repeats, with Gypsy10-Dvi flanking - make several tandem copies.

AAACTAC_hap <- paste0(rep("AAACTAC", times=2E6), collapse="")


Gypsy_seq <- paste(readLines("~/Documents/AndyLab/Heterochromatin/PacBio_scripts/Revised_scripts/D_virilis_satellites_analysis/TEs_satellites/Gypsy-10_Dvi.txt"), collapse="")
Gypsy_seq
nchar(Gypsy_seq)

Gypsy_hap <- paste0(rep(Gypsy_seq, times=20), collapse="")

chrm_seq <- paste0(c(AAACTAC_hap, Gypsy_hap), collapse="")
outdir="~/Documents/AndyLab/Heterochromatin/PacBio_scripts/Revised_scripts/D_virilis_satellites_analysis/TEs_satellites/"
out_total <- paste0(outdir, "AAACTAC_Gypsy.fasta")
write(paste0(">", "AAACTAC_Gypsy"), file=out_total)
write(chrm_seq, file=out_total, append=T)
