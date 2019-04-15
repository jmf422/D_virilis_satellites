#$ -S /bin/bash
#$ -j y
#$ -q regular.q
#$ -N blast_satellite_reads.sh
#$ -cwd
#$ -l h_vmem=100G


# qsub blast_satellite_reads.sh <satellite>

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data2
/programs/bin/labutils/mount_server cbsubscb14 /storage

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy in the masked genome
cp /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads/D_virilis_mecat1st_polished.fasta.masked .

mv D_virilis_mecat1st_polished.fasta.masked D_virilis_mecat1st_polished.masked.fasta

# copy in the PacBio reads

cp /fs/cbsufsrv5/data1/platinum_genomes/D_virilis/fasta/*fasta .

cat *fasta > D_virilis.PacBio.reads.fasta

# make blast database

#makeblastdb -dbtype nucl -in D_virilis_mecat1st_polished.masked.fasta

# let's get the satellite containing reads

#cp /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_TE_reads/bedfiles/virilis.all.$1.satellites.reads .

#xargs samtools faidx D_virilis.PacBio.reads.fasta < virilis.all.$1.satellites.reads > D_virilis.$1.reads.fasta


# run blast
#blastn -db D_virilis_mecat1st_polished.masked.fasta -query D_virilis.$1.reads.fasta -outfmt 6 -out D_virilis.$1.genome.blast.out

cp /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads/D_virilis.$1.genome.blast.out .

# problem: need to get the reads that map once. it doesnt matter where 

cat D_virilis.$1.genome.blast.out | awk -v OFS="\t" '{if($11<1e-20 && $4>500) print $2, $9, $10, $1}' > D_virilis.$1.genome.blast.goodhits.bed 

 cat D_virilis.$1.genome.blast.goodhits.bed | cut -f 4 |  sort | uniq -c | sed -e 's/^[ \t]*//' | sed 's| |\t|g' | awk '$1==1 {print $2}' > D_virilis.$1.reads.unique.blast.matches


grep -f D_virilis.$1.reads.unique.blast.matches D_virilis.$1.genome.blast.goodhits.bed | awk -v OFS="\t" '$2<$3 {print $0}' > D_virilis.$1.unique.blast.matches.f.bed
grep -f D_virilis.$1.reads.unique.blast.matches D_virilis.$1.genome.blast.goodhits.bed | awk -v OFS="\t" '$2>$3 {print $1, $3, $2, $4}' > D_virilis.$1.unique.blast.matches.r.bed

cat D_virilis.$1.unique.blast.matches.f.bed D_virilis.$1.unique.blast.matches.r.bed > D_virilis.$1.unique.blast.matches.all.bed

# now check if they match with TEs

cp /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads/D_virilis_TEmasked.genome.bed .

bedtools intersect -a D_virilis.$1.unique.blast.matches.all.bed -b D_virilis_TEmasked.genome.bed -v > D_virilis.$1.reads.unique.blast.matches.notTEs.bed

# for the ones that don't match TEs see what they match. 

cp /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads/D_virilis_mecat1st_polished.fasta.masked .
mv D_virilis_mecat1st_polished.fasta.masked D_virilis_mecat1st_polished.masked.fasta

bedtools getfasta -fi D_virilis_mecat1st_polished.masked.fasta -bed D_virilis.$1.reads.unique.blast.matches.notTEs.bed -fo D_virilis.$1.reads.unique.blast.matches.notTEs.fasta

cp /shared_data/genome_db/BLAST_NCBI/nt* ./

blastn -db nt -query D_virilis.$1.reads.unique.blast.matches.notTEs.fasta -outfmt 6 -out $1.linked.genome.uniquematch.blast.out

cp D_virilis.$1.reads.unique.blast.matches /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads
cp D_virilis.$1.unique.blast.matches.all.bed /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads
cp $1.linked.genome.uniquematch.blast.out /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads
cp D_virilis.$1.reads.unique.blast.matches.notTEs.bed /fs/cbsubscb14/storage/jmf422/virilis_PacBio/satellite_genome_reads

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)