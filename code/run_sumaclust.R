# the sumaclust format puts otus on separate rows and the sequences within each
# otu on the same line separated by tabs. the representative sequence name is
# repeated in the first two columns. The outputted list file is a unqiue_list
# formatted file

collapse_line <- function(line){
	split_line <- unlist(strsplit(line, '\t'))
	unique_base_names <- unique(gsub("_\\d*$", "", split_line))
	paste(unique_base_names, collapse=',')
}

#sumaclust_file_name <- 'data/mice/mice.0_2.01.sumaclust.clust'

sumaclust_to_list <- function(sumaclust_file_name){
	sumaclust_data <- scan(sumaclust_file_name, what="", sep="\n", quiet=TRUE)
	sumaclust_data <- gsub("^[^\t]*\t", "", sumaclust_data) #remove first column

	otu_data <- unname(sapply(sumaclust_data, collapse_line))

	n_otus <- length(otu_data)
	list_data <- paste(c("userLabel", n_otus, otu_data), collapse='\t')

	list_file_name <- gsub("\\.sumaclust.clust", ".sumaclust.list", sumaclust_file_name)
	write(list_data, list_file_name)
}
