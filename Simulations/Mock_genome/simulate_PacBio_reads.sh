#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N simulate_PacBio_reads
#$ -cwd

# date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# cp in the genome

cp /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/D_virilis_sim_genome.fasta .

# run the program

PBSIM="/home/jmf422/Heterochromatin_scripts/Programs/PBSIM-PacBio-Simulator/src/pbsim"
SIMDAT="/home/jmf422/Heterochromatin_scripts/Programs/PBSIM-PacBio-Simulator/data"

PBSIM --data-type CLR --depth 10 --model_qc $SIMDAT/model_qc_clr D_virilis_sim_genome.fasta

mv *fastq /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/


cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)