# the otuclust format puts otus on separate rows and the sequences within each
# otu on the same line separated by tabs. this will return a unique'd list file
# that only has the names of the unique sequences

parse_otus <- function(otu_line){
	otu_line <- gsub("_\\d*(\\s)", "\\1", otu_line)
	otu_line <- gsub("_\\d*$", "", otu_line)
	sequences <- unique(unlist(strsplit(otu_line, "\t")))
	otus <- paste(sequences, collapse=',')
}

otuclust_to_list <- function(otuclust_file_name, count_file_name){
	otuclust_data <- scan(otuclust_file_name, what="", sep="\n", quiet=TRUE)

	count_data <- read.table(count_file_name, stringsAsFactors=F, header=T)
	n_unique_seqs <- nrow(count_data)

	otuclust_data <- sapply(otuclust_data, parse_otus)
	n_seqs <- sum(nchar(otuclust_data) - nchar(gsub(",", "", otuclust_data)) + 1)

	stopifnot(n_unique_seqs == n_seqs)

	n_otus <- length(otuclust_data)
	list_data <- paste(c("userLabel", n_otus, otuclust_data), collapse='\t')
	list_file_name <- gsub("\\.clust", ".list", otuclust_file_name)
	list_file_name <- gsub("\\.redundant", "", list_file_name)
	write(list_data, list_file_name)
}
