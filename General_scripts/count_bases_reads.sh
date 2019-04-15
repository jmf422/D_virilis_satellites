#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N count_bases_reads
#$ -cwd

# qsub count_bases_reads.sh <species> 


# date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy over fileroot files
cp $HOME/Heterochromatin_scripts/$1.fileroots .

# copy over the raw reads
cp /fs/cbsufsrv5/data1/platinum_genomes/$1/fasta/*subreads.fasta .


files=`cat $1.fileroots`

subf="total_bases.txt"

for f in $files
do
	cat $f.subreads.fasta | grep -v '^>' | wc -m >> $subf
done

echo "total characters in the reads:"  
total_bp=`cat total_bases.txt | awk '{total = total + $1}END{print total}'`
echo $total_bp


cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)