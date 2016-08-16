# the otuclust format puts otus on separate rows and the sequences within each
# otu on the same line separated by tabs. this will return a unique'd list file
# that only has the names of the unique sequences

parse_otus <- function(otu_line){
	seqs <- unlist(strsplit(otu_line, '\t'))
	seqs <- seqs[grepl("_1$", seqs)]
	seqs <- gsub("_1$", "", seqs)
	otu <- paste(unique(seqs), collapse=',')
}

otuclust_to_list <- function(otuclust_file_name){
	otuclust_data <- scan(otuclust_file_name, what="", sep="\n", quiet=TRUE)

	otuclust_data <- unname(sapply(otuclust_data, parse_otus))

	n_otus <- length(otuclust_data)
	list_data <- paste(c("userLabel", n_otus, otuclust_data), collapse='\t')
	list_file_name <- gsub("\\.clust", ".list", otuclust_file_name)
	list_file_name <- gsub("\\.redundant", "", list_file_name)
	write(list_data, list_file_name)
}
