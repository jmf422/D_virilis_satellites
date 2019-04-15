#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N get_contiglengths
#$ -cwd

# qsub get_contiglengths.sh <species> <assembly> <filename>
# qsub get_contiglengths.sh D_ananassae quickmerge merged.fasta

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/platinum_genomes/$1/assemblies/$2/$3 .

cat $3 | cut -f 1 -d "_" > temp.fa
mv temp.fa $3

samtools faidx $3
cat $3.fai | cut -f 1,2 > $1.$2.contig.lengths

# will do the joining in R

mv $1.$2.contig.lengths /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)
