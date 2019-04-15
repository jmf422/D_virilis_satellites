#$ -S /bin/bash
#$ -q long_term.q
#$ -j y
#$ -N trf_complex
#$ -cwd
#$ -l h_vmem=90G
#$ -M jmf422@cornell.edu
#$ -m be

#qsub trf_complex.sh <species> <assembly> <assembly.file>
#qsub trf_complex.sh D_virilis quickmerge merged.fasta
#qsub trf_complex.sh D_americana canu1st canu1st.contigs.fasta


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/platinum_genomes/$1/assemblies/$2/$3 .
#cp /fs/cbsufsrv5/data1/jmf422/PacBio/noseq121.fasta .
cp $HOME/Heterochromatin_scripts/trfparser_v1.pl .

cat $3 | cut -f 1 -d " " > temp.fasta
mv temp.fasta $3

trf $3 2 4 4 80 10 200 500 -h
#trf noseq121.fasta 2 4 4 80 10 200 500 -h

# parse the output with publicly available perl script 
# https://sourceforge.net/projects/trfparser/files/trf_parser/

perl trfparser_v1.pl $3.2.4.4.80.10.200.500.dat 1
#perl trfparser_v1.pl noseq121.fasta.2.4.4.80.10.200.500.dat 1

mv $3.2.4.4.80.10.200.500.dat /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex
#mv noseq121.fasta.2.4.4.80.10.200.500.dat /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex

mv *.parse /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex

cd ..

rm -r ./$JOB_ID


#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)