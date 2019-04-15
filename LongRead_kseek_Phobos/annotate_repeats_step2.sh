#$ -S /bin/bash
#$ -q long_term.q
#$ -j y
#$ -N annotate_repeats_step2
#$ -l h_vmem=50G
#$ -M jmf422@cornell.edu
#$ -cwd

# for name in `cat <D_<species>.fileroots>`; do qsub annotate_repeats_step2.sh $name $species; done

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/jmf422/PacBio/$2/kseek/$1.phobos.out .

cp $HOME/Heterochromatin_scripts/remove_overlapping_windows_v2.r .

# split the file and do for each read
csplit --digits=6 --quiet --prefix=windowsplit $1.phobos.out "/>/" "{*}"

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

cat *.bed.summary > $1.repread.length.summary
cat *.simple.out > $1.phobos.simple.out

#mv $1.repread.length.summary /fs/cbsufsrv5/data1/jmf422/PacBio/Rawreads/kSeek/Updated_analysis
#mv $1.phobos.simple.out /fs/cbsufsrv5/data1/jmf422/PacBio/Rawreads/kSeek/Updated_analysis

mv $1.repread.length.summary /fs/cbsufsrv5/data1/jmf422/PacBio/$2/Phobos
mv $1.phobos.simple.out /fs/cbsufsrv5/data1/jmf422/PacBio/$2/Phobos

cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)