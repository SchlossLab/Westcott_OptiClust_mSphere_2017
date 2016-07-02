# This script implements the sumaclust algorithm. Because the output is weird
# we change it into a mothur list file. The input is a degapped and redundant
# fasta file and the output is a list file where sumaclust is used as the method
# tag. We'll assume that sumaclust is in code/sumaclust_v1.0.20. We will also
# assign sequences to OTUs based on 97% similarity (-t 0.97) and because we want
# to eventually generate a list file we want to output the mapping file with the
# -O flag. The outputted list file is a unqiue_list formatted file

FASTA=$1
COUNT=$2

TEMP_FASTA=$(echo $FASTA | sed 's/fasta/sumaclust.fasta/')
cp $FASTA $TEMP_FASTA

mothur "#degap.seqs(fasta=$TEMP_FASTA);deunique.seqs(fasta=current, count=$COUNT)"
NG_FASTA=$(echo $TEMP_FASTA | sed 's/fasta/ng.fasta/')
RED_FASTA=$(echo $TEMP_FASTA | sed 's/fasta/ng.redundant.fasta/')

SUMACLUST_CLUST=$(echo $FASTA | sed 's/fasta/sumaclust.clust/')

code/sumaclust_v1.0.20/sumaclust -t 0.97 $RED_FASTA -O $SUMACLUST_CLUST >/dev/null

R -e "source('code/run_sumaclust.R'); sumaclust_to_list('$SUMACLUST_CLUST')"


rm $TEMP_FASTA $NG_FASTA $RED_FASTA $SUMACLUST_CLUST
