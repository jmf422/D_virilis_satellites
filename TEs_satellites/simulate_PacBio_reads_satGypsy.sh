#$ -S /bin/bash
#$ -q long_term.q
#$ -j y
#$ -N simulate_PacBio_reads_satGypsy
#$ -cwd
#$ -pe bscb 9
#$ -l h_vmem=100G


# date
d1=$(date +%s)
echo $HOSTNAME
echo $1


# qsub simulate_PacBio_reads_satGypsy.sh

/programs/bin/labutils/mount_server  cbsubscb14 /storage
/programs/bin/labutils/mount_server  cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# cp in the genome

cp $HOME/Heterochromatin_scripts/AAACTAC_Gypsy.fasta .

# cp in the fasta reads to model their lengths

cp /fs/cbsufsrv5/data1/platinum_genomes/D_virilis/fasta/*fasta .
cat *fasta > virilis_subreads.all.fasta

# need to subsample this file
cp $HOME/Heterochromatin_scripts/subsample_fasta.py .
python subsample_fasta.py 100000 virilis_subreads.all.fasta virilis_subreads.sample.fasta


cp $HOME/Heterochromatin_scripts/fasta_to_fastq.pl .

perl fasta_to_fastq.pl virilis_subreads.sample.fasta > virilis_subreads.all.fastq

# run the program

PBSIM="/home/jmf422/Heterochromatin_scripts/Programs/PBSIM-PacBio-Simulator/src/pbsim"
SIMDAT="/home/jmf422/Heterochromatin_scripts/Programs/PBSIM-PacBio-Simulator/data"

$PBSIM --data-type CLR --depth 105 --sample-fastq virilis_subreads.all.fastq AAACTAC_Gypsy.fasta

cp *fastq /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/simulations
cp AAACTAC_Gypsy.fasta /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/simulations

#check the depth

# merge the files together

cat *fastq > AAACTAC_Gypsy.PBsim.fastq 

# convert to fasta 

sed -n '1~4s/^@/>/p;2~4p' AAACTAC_Gypsy.PBsim.fastq > AAACTAC_Gypsy.PBsim.fasta

# now let's run NCRF
NCRF="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/NCRF"
NCRF_bed="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_to_bed.py"
NCRF_summary="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_summary.py"
NCRF_filter="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_consensus_filter.py" 
NCRF_sort="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_sort.py"
NCRF_cat="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_cat.py"
NCRF_overlaps="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_resolve_overlaps.py"

cat AAACTAC_Gypsy.PBsim.fasta| $NCRF AAACTAC --maxnoise=25% --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > AAACTAC_Gypsy.PBsim.NCRF.summary

cp AAACTAC_Gypsy.PBsim.NCRF.summary /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/simulations/NCRF

# now select these reads and extract them, then run repeat masker

cat AAACTAC_Gypsy.PBsim.NCRF.summary | sed '1d' | cut -f 3 | sort -u > AAACTAC.reads

# now extract these reads from the fasta file

xargs samtools faidx AAACTAC_Gypsy.PBsim.fasta < AAACTAC.reads > AAACTAC_satellite.reads.fasta

/programs/RepeatMasker/RepeatMasker -species Drosophila -nolow -pa 18 AAACTAC_satellite.reads.fasta 

cat AAACTAC_satellite.reads.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | sed 's/(//g' | sed 's/)//g' > file1.txt
cat file1.txt  | awk -v OFS="\t" '{print $5, $6, $7, $7+$8, $7-$6, $10, $11, $2}' | grep -v "Simple_repeat" | grep -v "Low_complexity" > AAACTAC_Gypsy.Rmasker.bed

cp AAACTAC_satellite.reads.fasta.out /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/simulations/Rmasker
cp AAACTAC_satellite.reads.fasta.tbl /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/simulations/Rmasker
cp AAACTAC_Gypsy.Rmasker.bed /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/simulations/Rmasker


cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)