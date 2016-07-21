#!/bin/bash

FASTA=$1
COUNT=$2

mothur "#degap.seqs(fasta=$FASTA); deunique.seqs(fasta=current, count=$COUNT)"

REDUNDANT=$(echo $FASTA | sed 's/fasta/ng.redundant.fasta/')
ROOT=$(echo $FASTA | sed 's/fasta/udgc/')

usearch61 --sizeout --derep_fulllength $REDUNDANT --minseqlength 30 --threads 1 --uc $ROOT.sorted.uc --output $ROOT.sorted.fna --strand both --log $ROOT.sorted.log --threads 1

usearch61 --maxaccepts 16 --usersort --id 0.97 --minseqlength 30 --wordlength 8 --uc $ROOT.clustered.uc --cluster_smallmem $ROOT.sorted.fna --maxrejects 64 --strand both --log $ROOT.clustered.log --threads 1

R -e "source('code/uc_to_list.R'); uc_to_list('$ROOT.clustered.uc')"

rm $ROOT.sorted.uc $ROOT.sorted.fna $ROOT.sorted.log $ROOT.clustered.uc $ROOT.clustered.log

rm $(echo $FASTA | sed 's/fasta/ng.fasta/')
rm $(echo $FASTA | sed 's/fasta/ng.redundant.fasta/')
rm -f $(echo $FASTA | sed 's/fasta/redundant.groups/')
