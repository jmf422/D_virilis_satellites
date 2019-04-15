#$ -S /bin/bash
#$ -j y
#$ -q regular.q
#$ -N seqdiv_satellites2
#$ -cwd


# qsub seqdiv_satellites.sh <satellite> <sample>

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1
echo $2

/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsubscb14 /storage

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy in the .rep file for this sample
cp /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/kseek/$2.fastq.rep .

# use extract.py to get the reads containing the satellite of interest.

cp $HOME/extract.py .

python extract.py $1 $2.fastq.rep -o $2.$1.fasta

NCRF="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/NCRF"
NCRF_bed="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_to_bed.py"
NCRF_summary="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_summary.py"
NCRF_filter="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_consensus_filter.py" 
NCRF_sort="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_sort.py"
NCRF_cat="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_cat.py"
NCRF_overlaps="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_resolve_overlaps.py"

cat $2.$1.fasta | $NCRF $1 --maxnoise=10% --minlength=100 --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > $2.$1.ncrf10.summary

cp $2.$1.ncrf10.summary /fs/cbsubscb14/storage/jmf422/virilis_diversity/reads_divergence



cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)