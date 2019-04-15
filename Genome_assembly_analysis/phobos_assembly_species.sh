#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N phobos_assembly_species
#$ -cwd
#$ -l h_vmem=50G
#$ -M jmf422@cornell.edu

#qsub phobos_assembly_species.sh <species>


#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/platinum_genomes/$1/assemblies/quickmerge/merged.fasta .

cat merged.fasta | cut -f 1 -d "_" > $1_merged.fasta

$HOME/Programs/bin/phobos_64_libstdc++6 $1_merged.fasta $1_merged.phobos -U 20 --outputFormat 0 --printRepeatSeqMode 0 --reportUnit 2

csplit --digits=4 --quiet --prefix=allphobos $1_merged.phobos "/>/" "{*}"

rm allphobos0000

ls | grep allphobos > phobfiles.txt

files=`cat phobfiles.txt`

subf="summary.outfile"

for f in $files
do
	grep '^>' $f >> $subf # print the the name of the read
	echo "read length:" >> $subf
	grep 'sequence length' $f | cut -f 3 -d " " >> $subf # print the length of the read
	sed -e '1,3d' < $f > temp.txt # remove first 3 lines
	cat temp.txt | awk -F\| '{split ($6,b," "); split($2,a," "); print b[2],a[1]}' | sed -e "s/\ /\t/g" | awk '
	NR == 1 {print; next}
	{a[$1] += $2}
	END {
		for (i in a) {
			printf "%-15s\t%s\n" ,i, a[i] | "sort -rnk2";
		}
	}
	' > temp2.txt
	echo "total repeat span:" >> $subf
	cat temp2.txt | awk '{total = total + $2}END{print total}' >> $subf 
	cat temp2.txt >> $subf
done

mv summary.outfile $1_merged.phobos.summary

mv $1_merged.phobos.summary /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/

mv $1_merged.phobos /fs/cbsufsrv5/data1/jmf422/PacBio/genome_qc/

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)