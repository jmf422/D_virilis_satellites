#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N kseek_species
#$ -cwd

#for name in `cat <fileroot file>`; do qsub kseek_species.sh $name <species>; done


# date
d1=$(date +%s)
echo $HOSTNAME
echo $1
echo $2

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp $HOME/k_seek.r4.pl .

# copy over the fasta file
cp /fs/cbsufsrv5/data1/platinum_genomes/$2/fasta/$1.subreads.fasta .

# copy perl script to convert to fastq
cp $HOME/Heterochromatin_scripts/fasta_to_fastq.pl .

/programs/emboss/bin/splitter -sequence $1.subreads.fasta  -size 100 -outseq $1.split.fasta

# convert back to fastq
perl fasta_to_fastq.pl $1.split.fasta > $1.split.fastq

# run kseek
perl k_seek.r4.pl $1.split.fastq $1

mv *.rep /fs/cbsufsrv5/data1/jmf422/PacBio/$2/kseek
mv *.total /fs/cbsufsrv5/data1/jmf422/PacBio/$2/kseek

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)