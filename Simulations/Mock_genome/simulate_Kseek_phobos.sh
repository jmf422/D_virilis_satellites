#$ -S /bin/bash
#$ -q long_term.q
#$ -j y
#$ -N simulate_Kseek_phobos
#$ -l h_vmem=50G
#$ -cwd

# date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy perl script to convert to fastq
cp $HOME/Heterochromatin_scripts/fasta_to_fastq.pl .
cp $HOME/k_seek.r4.pl .

# cp in simulated fastq reads

cp /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/*fastq .

# merge the files together

cat *fastq > Dvir_PacBio.reads.fastq

# convert to fasta 

sed -n '1~4s/^@/>/p;2~4p' Dvir_PacBio.reads.fastq > Dvir_PacBio.reads.fasta

# split the reads into 100 bp
/programs/emboss/bin/splitter -sequence Dvir_PacBio.reads.fasta  -size 100 -outseq Dvir_PacBio.reads.split.fasta

# convert back to fastq
perl fasta_to_fastq.pl Dvir_PacBio.reads.split.fasta > Dvir_PacBio.reads.split.fastq

# run kseek
perl k_seek.r4.pl Dvir_PacBio.reads.split.fastq Dvir.simulated.Pacbio

cp Dvir.simulated.Pacbio.rep /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/MyMethod

#cp /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/MyMethod/Dvir.simulated.Pacbio.rep .

# get the reads with repeats in them

cat Dvir.simulated.Pacbio.rep | grep '^@' | cut -f 2 -d "@" | cut -f 1,2 -d "_"  | sort -u > reads.with.repeats
echo "done getting read names from rep files"

### GET ALL THE READS WITH REPEATS, separated by the prefix

xargs samtools faidx Dvir_PacBio.reads.fasta < reads.with.repeats > Dvir.PacBio.repeatreads.fasta 
echo "got reads with repeats"

cp Dvir.PacBio.repeatreads.fasta /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/MyMethod

### RUN PHOBOS ON THESE FASTA READS
echo "now starting phobos"

$HOME/Programs/bin/phobos_64_libstdc++6 Dvir.PacBio.repeatreads.fasta Dvir.PacBio.phobos.out -U 20 --outputFormat 0 --printRepeatSeqMode 0 --reportUnit 2

cp Dvir.PacBio.phobos.out /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/MyMethod

# Now process phobos

cp $HOME/Heterochromatin_scripts/remove_overlapping_windows_v2.r .

# split the file and do for each read
csplit --digits=6 --quiet --prefix=windowsplit Dvir.PacBio.phobos.out "/>/" "{*}"

rm windowsplit000000
find . -type f -exec awk -v x=5 'NR==x{exit 1}' {} \; -exec rm -f {} \;

for f in windowsplit*
do
	read=`cat $f | awk 'NR==1{print $1}' | cut -f 2 -d '>'` # get the read name
	readlen=`cat $f | awk 'NR==2{print $3}' | cut -f 3 -d " "`
	cat $f | grep -v '^#' | sed -e '1,3d' | sed -e "s/|//g" | sed -e "s/://g" | sed -e "s/%//g" | tr -s " " | sed -e "s/\ /\t/g" | cut -f 3,4,5,9,13 > temp.txt
	Rscript --vanilla remove_overlapping_windows_v2.r temp.txt $f.out.txt
	cat $f.out.txt | awk -v OFS="\t" '{print $5, $3}' | awk '
	NR == 0 {print; next}
	{a[$1] += $2}
	END {
		for (i in a) {
			printf "%s\t%s\n" ,i, a[i] | "sort -rnk2";
		}
	}
	' > $f.simple.out
	repspan=`cat $f.simple.out | awk '{total = total + $2}END{print total}'`
	printf "%s\t%i\t%i\n" $read $readlen $repspan > $f.bed.summary
done

cat *.bed.summary > Dvir.PacBio.repread.length.summary
cat *.simple.out > Dvir.PacBio.phobos.simple.out


mv Dvir.PacBio.repread.length.summary /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/MyMethod
mv Dvir.PacBio.phobos.simple.out /fs/cbsufsrv5/data1/jmf422/PacBio/SimGenome/mutated/MyMethod



cd ..

rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)