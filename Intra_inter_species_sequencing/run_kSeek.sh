#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N run_kSeek
#$ -cwd

#qsub run_kSeek.sh <fileroot>
#for p in `cat lane1_2_sample.prefixes`; do qsub run_kSeek.sh $p; done


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy over the trimmed files , or the untrimmed files.

cp /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/$1.fastq.gz .

gunzip $1.fastq.gz

cp $HOME/k_seek.r4.pl .

perl k_seek.r4.pl $1.fastq $1.fastq

mv *.rep /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/kseek
mv *.total /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/kseek

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)