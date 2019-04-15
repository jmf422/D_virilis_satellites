#$ -S /bin/bash
#$ -q long_term.q
#$ -j y
#$ -N check_rDNA_R1
#$ -cwd


# date
d1=$(date +%s)
echo $HOSTNAME
echo $1


# qsub check_rDNA_R1.sh

/programs/bin/labutils/mount_server  cbsubscb14 /storage
/programs/bin/labutils/mount_server  cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# first get the reads that have R1 and AAACTAC.

# copy in and compile the fasta files
cp /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/*.AAACTAC.satellites.fasta .

cat *.AAACTAC.satellites.fasta > AAACTAC.all.satellites.fasta

# copy in the R1 read names

cp /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/bedfiles/AAACTAC.R1.reads .

# now extract these reads from the fasta file

xargs samtools faidx AAACTAC.all.satellites.fasta < AAACTAC.R1.reads > AAACTAC.R1.reads.fasta

cp $HOME/Heterochromatin_scripts/D_virilis_rDNA_eikbush.fasta .

/programs/RepeatMasker/RepeatMasker -lib D_virilis_rDNA_eikbush.fasta -nolow AAACTAC.R1.reads.fasta 

cat AAACTAC.R1.reads.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | sed 's/(//g' | sed 's/)//g' > file1.txt
cat file1.txt  | awk -v OFS="\t" '{print $5, $6, $7, $7+$8, $7-$6, $10, $11, $2}' | grep -v "Simple_repeat" | grep -v "Low_complexity" > AAACTAC.R1.Rmasker.bed

cp AAACTAC.R1.reads.fasta.out /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/bedfiles/rDNA

cp AAACTAC.R1.Rmasker.bed /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/bedfiles/rDNA


cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)