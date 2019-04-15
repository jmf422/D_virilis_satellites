#$ -S /bin/bash
#$ -j y
#$ -q regular.q
#$ -N NCRF_complex.sh
#$ -cwd
#$ -l h_vmem=30G


# for name in `cat <species>.fileroots`; do qsub NCRF_complex.sh $name <species> <satellite>; done
# virilis: AAAACGACATAACTCCGCGCGGAGATATGACGTTCC
# novamexicana: AAAAGCTGATTGCTATATGTGCAATAGCTGAC

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1
echo $2
echo $3

/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsufsrv5 /data2

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/platinum_genomes/$2/fasta/$1.subreads.fasta .



NCRF="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/NCRF"
NCRF_bed="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_to_bed.py"
NCRF_summary="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_summary.py"
NCRF_filter="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_consensus_filter.py" 
NCRF_sort="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_sort.py"
NCRF_cat="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_cat.py"
NCRF_overlaps="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_resolve_overlaps.py"

cat $1.subreads.fasta | $NCRF $3 --maxnoise=30% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > $2.$1.complex30.ncrf25.summary 

cp *ncrf25.summary /fs/cbsufsrv5/data2/jmf422/NCRF/complex

 
cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)