# this is an r-based wrapper to cluster sequences using the swarm algorithm.
# swarm isn't really designed to be used as a distance-based threshold method,
# but whatever, that's what people really want. this is how to run the code:
#
#		get_mothur_list(something.fasta, something.count_table)
#
#		output: something.swarm.list
#


# here we read in the count_file and unique'd fasta file generated in mothur and
# output a modified fasta file that will work with swarm. the only change is to
# concatenate the number of sequences each unique sequence represents to the end
# of the sequence name with a _ separating the sequence name and frequency.

prep_swarm_clust <- function(count, fasta){

	count_file <- read.table(file=count, header=T, stringsAsFactors=FALSE)
	n_seqs <- count_file$total
	names(n_seqs) <- count_file$Representative_Sequence

	fasta_data <- scan(fasta, what="", quiet=TRUE)
	sequence_data <- fasta_data[grepl("^[ATGCatgc.-]", fasta_data)]
	sequence_data <- gsub("[-.]", "", sequence_data)
	names(sequence_data) <- gsub(">", "", fasta_data[grepl("^>", fasta_data)], 2, )

	seq_with_freq <- paste0(">", names(sequence_data), "_", n_seqs[names(sequence_data)], "\n", sequence_data)

	swarm_fasta <- gsub("fasta", "swarm.fasta", fasta)
	write(seq_with_freq, swarm_fasta)

	swarm_fasta
}


# here's the wrapper that calls swarm. this assumes that swarm is installed in
# code/swarm/bin. the output will only contain the unique sequence names with
# the frequency data concatenated to the end.
run_swarm_clust <- function(fasta){
	swarm_fasta <- gsub("fasta", "swarm.fasta", fasta)
	swarm_list <- gsub("fasta", "temp_list", swarm_fasta)

	command_string <- paste("code/swarm/bin/swarm -f -t 1 --mothur -o", swarm_list,  swarm_fasta)
	system(command_string)

	swarm_list
}


# this function will convert the swarm mothur-based list file and converts it
# to a true mothur-based list file. basically, for each unique sequence name
# from the swarm file, it inserts the names of the redundant sequence names.
convert_swarm_clust <- function(swarm_fasta_file, swarm_list_file){

	swarm_list <- scan(swarm_list_file, what="", quiet=TRUE)
	swarm_list <- gsub("_\\d*,", ",", swarm_list)
	swarm_list <- gsub("_\\d*$", "", swarm_list)
	swarm_list[1] <- "userLabel"
	paste(swarm_list, collapse='\t')

}


# this function drives the assignment of sequences to OTUs using swarm. takes
# as input the output of running unique.seqs (*.unique.fasta and *.names) and
# outputs *.swarm.list using 'userLabel' as the label in the list file
get_mothur_list <- function(fasta, count){
	swarm_fasta_file_name <- prep_swarm_clust(count, fasta)
	swarm_list_file_name <- run_swarm_clust(fasta)

	list_data <- convert_swarm_clust(swarm_fasta_file_name, swarm_list_file_name)

	mothur_list_file_name <- gsub("temp_", "", swarm_list_file_name)
	write(list_data, mothur_list_file_name)
	unlink(swarm_fasta_file_name)
	unlink(swarm_list_file_name)
}
