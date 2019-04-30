#!/bin/bash

#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N run_trimmomatic
#$ -cwd
#$ -l h_vmem=50G

# run_trimmomatic.sh <input-prefix>
# then run fastqc

#date
d1=$(date +%s)

echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1

mkdir -p /workdir/$USER/$JOB_ID
cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/$1.fastq.gz .

java -jar /programs/trimmomatic/trimmomatic-0.36.jar SE -phred33 $1.fastq.gz $1.trimmed.fastq.gz ILLUMINACLIP:/programs/trimmomatic/adapters/TruSeq3-SE.fa:2:30:10 SLIDINGWINDOW:5:20 MINLEN:90 


fastqc $1.trimmed.fastq.gz

mv $1.trimmed.fastq.gz /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/
mv *html /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/

cd ..

cp -r $JOB_ID /fs/cbsufsrv5/data1/jmf422/Polytene_sequencing

rm -r ./$JOB_ID
#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)