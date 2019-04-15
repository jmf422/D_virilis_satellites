#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N kcompile
#$ -cwd

# qsub kcompile.sh


# date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp $HOME/k_compiler.pl .
mkdir total

#cp /fs/cbsufsrv5/data1/jmf422/Polytene_sequencing/kSeek/*total total
cp /fs/cbsufsrv5/data1/jmf422/Polytene_sequencing/kSeek/allreads/*total total

perl k_compiler.pl total Dvir_polyteny.allreads

mv Dvir_polyteny.allreads.rep.compiled /fs/cbsufsrv5/data1/jmf422/Polytene_sequencing/kSeek/allreads

cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)