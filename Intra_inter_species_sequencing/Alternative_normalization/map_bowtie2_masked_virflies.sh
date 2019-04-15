#!/bin/bash
#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N map_bowtie2_masked_virflies
#$ -cwd
#$ -l h_vmem=12G


#qsub map_bowtie2_masked_virflies Dvir_flies D_virilis
# for p in `cat virilis_diversity.fileroots`; do qsub map_bowtie2_masked.sh $p D_virilis; done

#date
d1=$(date +%s)

echo $HOSTNAME
echo $1
echo $2

#/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsufsrv5 /data2

mkdir -p /workdir/$USER/$JOB_ID
cd /workdir/$USER/$JOB_ID

#copy the genome assembly over 
cp /fs/cbsufsrv5/data2/jmf422/virilis_diversity/mapping/GCcorr/results/testing/nolow/$2.canu.masked.fasta .
#mv $2.canu.fasta.masked $2.canu.masked.fasta


#index the genome <input fasta file> <prefix for index>
/programs/bowtie2-2.2.8/bowtie2-build $2.canu.masked.fasta $2.canu.masked

#copy sequencing reads over and unzip
cp /fs/cbsufsrv5/data1/jmf422/Polytene_sequencing/$1.fastq.gz .
mv $1.fastq.gz $1_1.fastq.gz

gunzip *.fastq.gz

#map to the genome
/programs/bowtie2-2.2.8/bowtie2 -x $2.canu.masked -U $1_1.fastq  -S $1_1_aln.nuc.sam

echo "mapped to genome: got sam file"

#convert to bam
/programs/samtools-1.8/bin/samtools view -Sb $1_1_aln.nuc.sam > $1_1_aln.nuc.bam

echo "converted to bam"

#sort
/programs/samtools-1.8/bin/samtools sort $1_1_aln.nuc.bam -o $1_1_aln.nuc.sorted.bam

echo "sorted bam"


#move necessary output to file server 5
mv *.sorted.bam /fs/cbsufsrv5/data2/jmf422/virilis_diversity/mapping/masked_mapping2



cd ..
rm -r ./$JOB_ID
#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)