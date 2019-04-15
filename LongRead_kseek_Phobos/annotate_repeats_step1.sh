#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N annotate_repeats_step1
#$ -cwd
#$ -M jmf422@cornell.edu


#for name in `cat <species>.fileroots`; do qsub annotate_repeats_step1.sh $name <species>; done


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1
echo $2

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/jmf422/PacBio/$2/kseek/$1.rep .
cp /fs/cbsufsrv5/data1/platinum_genomes/$2/fasta/$1.subreads.fasta .


### GET THE READ NAMES WITH REPEATS FROM THE .rep FILES

cat $1.rep | grep '^@' | cut -f 2 -d "@" | cut -f 1-6 -d "_" | sed -e 's|_|/|3' | sed -e 's|_|/|3' | sort -u > $1.reads.with.repeats
echo "done getting read names from rep files"

### GET ALL THE READS WITH REPEATS, separated by the prefix

xargs samtools faidx $1.subreads.fasta < $1.reads.with.repeats > $1.repeatreads.fasta 
echo "got reads with repeats"

### RUN PHOBOS ON THESE FASTA READS
echo "now starting phobos"

$HOME/Programs/bin/phobos_64_libstdc++6 $1.repeatreads.fasta $1.phobos.out -U 20 --outputFormat 0 --printRepeatSeqMode 0 --reportUnit 2

mv $1.phobos.out /fs/cbsufsrv5/data1/jmf422/PacBio/$2/kseek/

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)