#$ -S /bin/bash
#$ -q regular.q@cbsubscb10
#$ -j y
#$ -N count_bases_illumina_virilis
#$ -cwd

# qsub count_bases_illumina_virilis.sh <species-fileroots>


# date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server
/programs/bin/labutils/mount_server cbsufsrv5 /data2

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy over fileroot files
cp $HOME/Heterochromatin_scripts/$1 .


files=`cat $1`


for f in $files
do
	cp /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/$f.fastq.gz .
	gunzip $f.fastq.gz
	awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' $f.fastq > $f.lengths
	length=`cat $f.lengths | awk '{print $1*$2}' | awk '{sum += $1} END {print sum}' `
	printf "%s\t%i\t%i\n" $f $length 389000000 >> virilis_samples_read.totals
done

cat virilis_samples_read.totals | awk -v OFS="\t" '{print $1, $2, $2/$3}' > virilis_samples_read.depth

cp virilis_samples_read* /fs/cbsufsrv5/data2/jmf422/virilis_diversity/depth_estimation
cp vir47_ATCACG_R1.lengths /fs/cbsufsrv5/data2/jmf422/virilis_diversity/depth_estimation


cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)