#$ -S /bin/bash
#$ -q long_term.q
#$ -j y
#$ -N simulate_NCRF
#$ -cwd


#date
d1=$(date +%s)
echo $HOSTNAME

/programs/bin/labutils/mount_server cbsufsrv5 /data1

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy in the reads

cp /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/*fastq .
#cp /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/*fastq .

# merge the files together

cat *fastq > Dvir_PacBio.reads.fastq

# convert to fasta 

sed -n '1~4s/^@/>/p;2~4p' Dvir_PacBio.reads.fastq > Dvir_PacBio.reads.fasta

NCRF="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/NCRF"
NCRF_bed="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_to_bed.py"
NCRF_summary="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_summary.py"
NCRF_filter="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_consensus_filter.py" 
NCRF_sort="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_sort.py"
NCRF_cat="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_cat.py"
NCRF_overlaps="/home/jmf422/Heterochromatin_scripts/Programs/NoiseCancellingRepeatFinder/ncrf_resolve_overlaps.py"

percents="18% 19% 20% 21% 22% 23% 24% 25% 26% 27% 28% 29% 30%"

subf="repeats.found.percents"
for p in $percents
do
	cat Dvir_PacBio.reads.fasta | $NCRF AAACTAC --maxnoise=$p --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > Dvir.PacBio.AAACTAC.filtered.$p.ncrf.summary
	amt=`cat Dvir.PacBio.AAACTAC.filtered.$p.ncrf.summary | sed '1d' | cut -f 1-9 | awk -v OFS="\t" '{print $0, $5-$4}' | awk '{sum += $10} END { print sum/10 }'`
	printf "%s\t%s\t%f\n" AAACTAC $p $amt >> $subf
	
	cat Dvir_PacBio.reads.fasta | $NCRF AAACTAT --maxnoise=$p --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > Dvir.PacBio.AAACTAT.filtered.$p.ncrf.summary
	amt=`cat Dvir.PacBio.AAACTAT.filtered.$p.ncrf.summary | sed '1d' | cut -f 1-9 | awk -v OFS="\t" '{print $0, $5-$4}' | awk '{sum += $10} END { print sum/10 }'`
	printf "%s\t%s\t%f\n" AAACTAT $p $amt >> $subf
	
	cat Dvir_PacBio.reads.fasta | $NCRF AAATTAC --maxnoise=$p --scoring=pacbio --stats=events --positionalevents | $NCRF_filter | $NCRF_summary > Dvir.PacBio.AAATTAC.filtered.$p.ncrf.summary
	amt=`cat Dvir.PacBio.AAATTAC.filtered.$p.ncrf.summary | sed '1d' | cut -f 1-9 | awk -v OFS="\t" '{print $0, $5-$4}' | awk '{sum += $10} END { print sum/10 }'`
	printf "%s\t%s\t%f\n" AAATTAC $p $amt >> $subf
done 
	

cp repeats.found.percents /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/NCRF_Sim/percent_tests

#cp repeats.found.percents /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/sim_percents
 
cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)