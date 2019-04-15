#$ -S /bin/bash
#$ -j y
#$ -q regular.q
#$ -N TEs_satellite_reads
#$ -cwd
#$ -pe bscb 4


# qsub TEs_satellite_reads.sh <read prefix> <satellite>
# for f in `cat D_virilis.fileroots`; do qsub TEs_satellite_reads.sh $f AAACTAC

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1
echo $2 

/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsubscb14 /storage

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy in the NCRF file. 

cp /fs/cbsufsrv5/data1/jmf422/PacBio/NCRF/virilis_group/25perc/D_virilis.$2.$1.ncrf25.summary .

# copy in the corresponding fasta file

cp /fs/cbsufsrv5/data1/platinum_genomes/D_virilis/fasta/$1.subreads.fasta .

# get a text file of the reads I want:

cat D_virilis.$2.$1.ncrf25.summary | sed '1d' | cut -f 3 | sort -u > $1.reads

# now extract these reads from the fasta file

xargs samtools faidx $1.subreads.fasta < $1.reads > $1.$2.satellites.fasta 

/programs/RepeatMasker/RepeatMasker -species Drosophila -nolow -pa 8 $1.$2.satellites.fasta 

cat $1.$2.satellites.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | sed 's/(//g' | sed 's/)//g' > file1.txt
cat file1.txt  | awk -v OFS="\t" '{print $5, $6, $7, $7+$8, $7-$6, $10, $11, $2}' | grep -v "Simple_repeat" | grep -v "Low_complexity" > $1.$2.satellites.bed


cp $1.$2.satellites.fasta* /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads
cp $1.$2.satellites.bed /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads


cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)