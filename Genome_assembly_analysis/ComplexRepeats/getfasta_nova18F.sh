#$ -S /bin/bash
#$ -q long_term.q
#$ -j y
#$ -N getfasta_nova18F
#$ -l h_vmem=90G
#$ -cwd

#qsub getfasta_nova18F.sh


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy over the raw reads and the header names you want

cp /fs/cbsufsrv5/data1/jmf422/PacBio/merged.fasta .
cp $HOME/Heterochromatin_scripts/trfparser_v1.pl .

samtools faidx merged.fasta 000018F_000564089:B~000126427:B~000617921:E~000633619:B_ctg_linear_3319184_17557168 > nova_merged18F.fasta

cat nova_merged18F.fasta | grep -v '^>' | wc -m 

# then run TRF

trf nova_merged18F.fasta 2 4 4 80 10 200 500 -h

perl trfparser_v1.pl nova_merged18F.fasta.2.4.4.80.10.200.500.dat 1

mv nova_merged18F.fasta.2.4.4.80.10.200.500.dat /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex

mv *.parse /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex

mv nova_merged18F.fasta /fs/cbsufsrv5/data1/jmf422/PacBio/

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)