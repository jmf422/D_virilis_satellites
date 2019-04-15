#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N get_read_lengths
#$ -cwd

# qsub get_read_lengths.sh <species>


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

# split the files based on how many reads there are.
#for each read count the number of bases
subf="read_lengths.txt"
for f in $files
do
	csplit --digits=7 --quiet --prefix=reads $f.subreads.fasta "/>/" "{*}"
	for g in reads*
	do
		cat $g | grep -v '^>' | wc -m >> $subf
	done
done

# unix calculate average
echo "Average read length:"
cat read_lengths.txt | awk '{total = total + $2}END{print total/NR}'

# unix calculate max value:
echo "Max read length:"
cat read_lengths.txt | sort -nr | head -n 1

mv read_lengths.txt $1.readlengths.txt

mv $1.readlengths.txt /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc

cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)