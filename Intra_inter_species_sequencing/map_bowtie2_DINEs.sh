#!/bin/bash
#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N map_bowtie2_DINEs
#$ -cwd
#$ -l h_vmem=12G


#qsub map_bowtie2.sh <fileroot> <species>
# for p in `cat virilis_diversity.fileroots`; do qsub map_bowtie2_DINEs.sh $p; done

#date
d1=$(date +%s)

echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsubscb14 /storage


mkdir -p /workdir/$USER/$JOB_ID
cd /workdir/$USER/$JOB_ID

# copy over the DINE file

cp $HOME/Heterochromatin_scripts/vir_DINEs.fasta .


#index the genome <input fasta file> <prefix for index>
/programs/bowtie2-2.2.8/bowtie2-build vir_DINEs.fasta vir_DINEs

#copy sequencing reads over and unzip
cp /fs/cbsufsrv5/data1/jmf422/virilis_diversity/fastq/$1.fastq.gz .

gunzip *.fastq.gz

#map to the genome
/programs/bowtie2-2.2.8/bowtie2 -x vir_DINEs -U $1.fastq -S $1.vir_DINEs.sam

echo "mapped to genome: got sam file"

mv *sam /fs/cbsubscb14/storage/jmf422/virilis_diversity/DINEs


cd ..
rm -r ./$JOB_ID
#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)