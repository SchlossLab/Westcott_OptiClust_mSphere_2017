#!/bin/bash

# This script implements the OTUClust algorithm. Because the output is weird
# we change it into a mothur list file. The input is a degapped and redundant
# fasta file and the output is a list file where otuclust is used as the method
# tag. We'll assume that OTUClust is in QIIME and that this is in the users path.
# We will also assign sequences to OTUs based on 97% similarity (-s 0.97) and
# because we want to include all of the sequences we'll keep the singletons (-m 1)


#data/mice/mice.0_2.02.otuclust.redundant.fasta

OTUCLUST_FASTA=$1
OTUCLUST_CLUST=$(echo $OTUCLUST_FASTA | sed 's/ng.redundant.fasta/clust/')
OTUCLUST_REP=$(echo $OTUCLUST_FASTA | sed 's/ng.redundant.fasta/rep/')

STATS=$(echo $OTUCLUST_FASTA | sed 's/ng.redundant.fasta/stats/')

#echo $OTUCLUST_FASTA
#echo $OTUCLUST_CLUST
#echo $OTUCLUST_REP

otuclust -f fasta $OTUCLUST_FASTA --out-clust $OTUCLUST_CLUST --out-rep $OTUCLUST_REP -s 0.97 -m 1

#echo $STATS

R -e "source('code/run_otuclust.R'); otuclust_to_list('$OTUCLUST_CLUST')"

rm $TEMP_FASTA $OTUCLUST_FASTA $OTUCLUST_CLUST $OTUCLUST_REP

