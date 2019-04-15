#! /bin/bash

#sh  which_strand_pacbio_script.sh <ncrf file to work on> <subreads file root>
# script that gets the strand information of the reads. Assign the + strand as the AAACTAC etc



# get a bed file of the read fragments you want
cat $1 | grep -v '^#' | tr -s " " | sed 's| |\t|g' | cut -f 1,4 | grep -v '^A' | sed '/^$/d' | awk -v OFS="\t" '{split($2,a,"-"); print $1, a[1], a[2]}' > $1.bed

sort -k 1,1 -k2,2n $1.bed > $1.sorted.bed

bedtools getfasta -fi $2.subreads.fasta -bed $1.sorted.bed -fo $1.fasta 

# now break up the file
csplit --digits=6 --quiet --prefix=read $1.fasta "/>/" "{*}"

rm read000000

for r in read*
do
	cat $r | grep -v '^>' > read.txt 
	As=`grep -o "A" read.txt | wc -l`
	Ts=`grep -o "T" read.txt  | wc -l`
	Cs=`grep -o "C" read.txt  | wc -l`
	Gs=`grep -o "G" read.txt  | wc -l`
	if [ $As -gt $Ts ]
	then
		strand="+"
	else 
		strand="-"
	fi
	printf "%i\t%i\t%i\t%i\t%s\n" $As $Ts $Cs $Gs $strand >> $1.strand.summary
done

rm read*
