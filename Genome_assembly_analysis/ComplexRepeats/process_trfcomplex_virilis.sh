#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N process_trfcomplex_virilis
#$ -cwd


#qsub process_trfcomplex_virilis.sh


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy over parsed file
cp /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex/merged.fasta.2.4.4.80.10.200.500.dat.parse .
cp $HOME/Chlamy_scripts/remove_overlapping_windows_v2.2.R .
cp $HOME/Heterochromatin_scripts/Booths_kmers.py .


cat merged.fasta.2.4.4.80.10.200.500.dat.parse | sed -e '1d' | awk -v OFS="\t" '{if($3>20 && $4>5.0) print $1, $2, $3, $5, $6}' > Dvir.complexreps.filtered

Rscript --vanilla remove_overlapping_windows_v2.2.R Dvir.complexreps.filtered Dvir.complexreps.filtered.nooverlap.txt

# now use python script to put in minimum rotation 
cut -f 5 Dvir.complexreps.filtered.nooverlap.txt > Dvir.complexreps.txt

python Booths_kmers_v2.py

cat Dvir.complexreps.filtered.nooverlap.txt | cut -f 1,2,3,4 > firstpart.txt
paste firstpart.txt min_rot_kmers.txt > Dvir.complexreps.filtered.nooverlap.Booths.txt


mv Dvir.complexreps* /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex
mv min_rot_kmers.txt /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/TRF_complex

cd ..

rm -r ./$JOB_ID


#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)