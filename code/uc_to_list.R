merge_seqs <- function(seed, hits){
	otu <- paste(seed, paste(hits[hits$V10==seed,"V9"], collapse=','), sep=',')
	gsub(",$", "", otu)
}

uc_to_list <- function(clustered_file_name){

	clustered <- read.table(file=clustered_file_name, stringsAsFactors=FALSE)

	clustered$V9 <- gsub("_\\d*;size=\\d*;", "",clustered$V9)
	clustered$V10 <- gsub("_\\d*;size=\\d*;", "",clustered$V10)

	seeds <- clustered[clustered$V1 == "S", "V9" ] 
	hits <- clustered[clustered$V1 == "H", ]

	otus <- sapply(seeds, merge_seqs, hits)


	list_file_name <- gsub("clustered.uc", "list", clustered_file_name)
	list_data <- paste(otus, collapse="\t")
	list_data <- paste("userLabel", length(otus), list_data, sep="\t")
	write.table(x=list_data, file=list_file_name, quote=F, row.names=F, col.names=F, sep="\t")

}


