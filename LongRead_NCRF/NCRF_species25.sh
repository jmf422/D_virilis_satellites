#$ -S /bin/bash
#$ -j y
#$ -q regular.q
#$ -N NCRF_species25.sh
#$ -cwd
#$ -l h_vmem=30G


# for name in `cat <species>.fileroots`; do qsub NCRF_species25.sh $name <species>; done

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1

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

cat $1.subreads.fasta | $NCRF AAACTAC --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > $2.AAACTAC.$1.ncrf25.summary 
cat $1.subreads.fasta | $NCRF AAACTAT --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > $2.AAACTAT.$1.ncrf25.summary 
cat $1.subreads.fasta | $NCRF AAATTAC --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > $2.AAATTAC.$1.ncrf25.summary 

cat $1.subreads.fasta | $NCRF AAACGAC --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > $2.AAACGAC.$1.ncrf25.summary

cat $1.subreads.fasta | $NCRF AAACAAC --maxnoise=25% --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > $2.AAACAAC.$1.ncrf25.summary

cp *ncrf25.summary /fs/cbsufsrv5/data1/jmf422/PacBio/NCRF/virilis_group/

 
cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)