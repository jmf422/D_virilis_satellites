#$ -S /bin/bash
#$ -j y
#$ -q regular.q
#$ -N NCRF_virilis_strand
#$ -cwd
#$ -l h_vmem=60G


# qsub NCRF_virilis_strand.sh <subreads to use>  #m54138_170528_012814

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp $HOME/Heterochromatin_scripts/which_strand_pacbio_script.sh .
# copy in the corresponding fasta file

cp /fs/cbsufsrv5/data1/platinum_genomes/D_virilis/fasta/$1.subreads.fasta .


NCRF="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/NCRF"
NCRF_bed="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_to_bed.py"
NCRF_summary="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_summary.py"
NCRF_filter="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_consensus_filter.py" 
NCRF_sort="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_sort.py"
NCRF_cat="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_cat.py"
NCRF_overlaps="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_resolve_overlaps.py"

cat $1.subreads.fasta | $NCRF AAACTAC --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter > D_virilis.$1.AAACTAC.ncrf25

cat $1.subreads.fasta | $NCRF AAATTAC --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter > D_virilis.$1.AAATTAC.ncrf25

cat $1.subreads.fasta | $NCRF AAACTAT --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter > D_virilis.$1.AAACTAT.ncrf25

cat $1.subreads.fasta | $NCRF AAACGAC --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter > D_virilis.$1.AAACGAC.ncrf25

sh which_strand_pacbio_script.sh D_virilis.$1.AAACTAC.ncrf25 $1
sh which_strand_pacbio_script.sh D_virilis.$1.AAATTAC.ncrf25 $1
sh which_strand_pacbio_script.sh D_virilis.$1.AAACTAT.ncrf25 $1
sh which_strand_pacbio_script.sh D_virilis.$1.AAACGAC.ncrf25 $1

cp *strand.summary /fs/cbsufsrv5/data1/jmf422/PacBio/NCRF/virilis_group/25perc/stranded
cp *ncrf25 /fs/cbsufsrv5/data1/jmf422/PacBio/NCRF/virilis_group/25perc/stranded
#cp *ncrf25.fasta /fs/cbsufsrv5/data1/jmf422/PacBio/NCRF/virilis_group/25perc/stranded
#cp *ncrf25.bed /fs/cbsufsrv5/data1/jmf422/PacBio/NCRF/virilis_group/25perc/stranded

 
cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)
