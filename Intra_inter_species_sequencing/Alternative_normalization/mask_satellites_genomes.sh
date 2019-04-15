#$ -S /bin/bash
#$ -j y
#$ -q regular.q
#$ -N mask_satellites_genomes.sh
#$ -cwd
#$ -pe bscb 4



#date
d1=$(date +%s)
echo $HOSTNAME


#/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsufsrv5 /data2

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data2/jmf422/virilis_diversity/mapping/GCcorr/Genomes/D_virilis.canu.fasta .
cp /fs/cbsufsrv5/data2/jmf422/virilis_diversity/mapping/GCcorr/Genomes/D_americana.canu.fasta .
cp /fs/cbsufsrv5/data2/jmf422/virilis_diversity/mapping/GCcorr/Genomes/D_novamexicana.canu.fasta .

cp $HOME/Heterochromatin_scripts/satellite_customlib.fasta .

/programs/RepeatMasker/RepeatMasker -lib satellite_customlib.fasta -pa 8 -nolow D_virilis.canu.fasta
/programs/RepeatMasker/RepeatMasker -lib satellite_customlib.fasta -pa 8 -nolow D_americana.canu.fasta
/programs/RepeatMasker/RepeatMasker -lib satellite_customlib.fasta -pa 8 -nolow D_novamexicana.canu.fasta

cp *out /fs/cbsufsrv5/data2/jmf422/virilis_diversity/mapping/GCcorr/results/testing/nolow
cp *mask* /fs/cbsufsrv5/data2/jmf422/virilis_diversity/mapping/GCcorr/results/testing/nolow

cd ..


rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)