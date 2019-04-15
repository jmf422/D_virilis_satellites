#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N get_contiglengths_no18F
#$ -cwd

#qsub get_contiglengths_no18F.sh

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/jmf422/PacBio/noseq121.fasta .

cat noseq121.fasta | cut -f 1 -d "_" > temp.fa


samtools faidx temp.fa
cat temp.fa.fai | cut -f 1,2 > novamex_noseq18F.contig.lengths

# will do the joining in R

mv novamex_noseq18F.contig.lengths /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)
