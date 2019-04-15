#! /bin/python

import sys,random
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.Alphabet import generic_protein

# Use: python   subsample_fasta.py   number_of_random_seq   infile.fasta   outfile.fasta

infile = sys.argv[2]                                #Name of the input file
seq = list(SeqIO.parse(infile,"fasta"))             #Create a list with all the sequence records
print "Input fasta file = ", infile

totseq = len(seq)                                   #Total number of sequences in the input file
print "Number of sequences in the original file = ", len(seq)

randseq = int(sys.argv[1])                          #Number of random sequences desired
print "Number of random sequences desired = ", randseq

if randseq > totseq:
  print "The requested number of random sequences is greater that the total number of input sequences. Exiting."
  exit()

outfile = sys.argv[3]                               #Name of the output file
print "Output fasta file = ", outfile

outrandseq = []
outlist = []
print "Randomly chosen output sequences:"

for i in range(randseq):
  choose = random.randint(1,totseq-1)               #Choose a random sequence record number
  for j in range(len(outrandseq)):                  #Test to see if the random sequence record number has already been chosen
    if choose == outrandseq[j]:
      choose = random.randint(1,totseq-1)           #Choose a new random sequence record number if the current one has already been chosen
  outrandseq.append(choose)
  print choose
  outseq = seq[choose]
  outlist.append(outseq)                            #Append seq record to output list

SeqIO.write(outlist, outfile, "fasta")              #Write the output list to the outfile

exit()