#!/usr/bin/env python

# reduces TRF kmers into the minimum rotation
# python Booths_kmers.py

import numpy
import argparse

def rev_comp(kmer):
    '''Returns reverse complement of k-mer.'''
    result = ''
    nucleotides = ['A', 'C', 'T', 'G']
    for char in kmer[::-1]:
        result += nucleotides[(nucleotides.index(char)+2)%len(nucleotides)]
    return result

def get_rotations(kmer):
    '''Returns all rotated versions of k-mer.'''
    return [(kmer*2)[i:len(kmer)+i] for i in range(0, len(kmer))]

def get_reverse_complements(rotations):
    '''Returns reverse complements of a k-mer's rotations.'''
    return [rev_comp(kmer) for kmer in rotations]

def is_same_kmer(rotations, reverse_complements, query):
    '''Returns True if query is either a rotated version of the target
    k-mer or the reverse complement of one of these rotations.'''
    if (query in rotations) or (query in reverse_complements):
        return True
    else:
        return False

def get_arguments():
    parser = argparse.ArgumentParser(description = '''
    Takes a list of kmers and puts them in the minimum rotation using 
    Booth's algorithm.
    
    Example usage:

    python Booths_kmers.py kmers.txt -o kmers_min.txt
    
    ''', formatter_class = argparse.RawTextHelpFormatter)
    parser.add_argument("input", help='input file of kmers')
    parser.add_argument("--output", '-o', help='name of output file.\
 Default is kmers_min.txt.', default='kmers_min.txt')
    return parser.parse_args()


def BoothsAlgorithm(s):
    #Booth's algoritm for finding the lexicographical minimum string rotation
    #From Wiki https://en.wikipedia.org/wiki/Lexicographically_minimal_string_rotation
    S = s*2      # Concatenate string to it self to avoid modular arithmetic
    f = [-1] * len(S)     # Failure function
    k = 0       # Least rotation of string found so far
    for j in xrange(1,len(S)):
        sj = S[j]
        i = f[j-k-1]
        while i != -1 and sj != S[k+i+1]:
            if sj < S[k+i+1]:
                k = j-i-1
            i = f[i]
        if sj != S[k+i+1]: # if sj != S[k+i+1], then i == -1
            if sj < S[k]: # k+i+1 = k
                k = j
            f[j-k] = -1
        else:
            f[j-k] = i+1
    length=len(s)

    return s[k-length:]+s[:k]

# read in the kmers and collapse into the minimum rotation
def parse_kmers (infile, outfile):
	min_kmers = list()
	out = open(outfile, 'w')
	with open(infile, 'r') as f:
		for line in f: # for each kmer
			kmer_string = line.strip()
			booths_rotation_obs = BoothsAlgorithm(kmer_string)
			kmer_rc = rev_comp(kmer_string)
			booths_rotation_rc = BoothsAlgorithm(kmer_rc)
			min_rotation = sorted([booths_rotation_obs, booths_rotation_rc])[0]
			min_kmers.append(min_rotation)
	for k in min_kmers:
		out.write("%s\n" % k)

	out.close()

args = get_arguments()
parse_kmers(args.input, args.output)



