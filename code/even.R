get_seq_names <- function(fasta_file){
	fasta_data <- scan(fasta_file, what=character(), sep='\n', quiet=T)
	is_seq_name <- grepl("^>", fasta_data)
	gsub('>', '', fasta_data[is_seq_name])
}

even <- function(fasta_file, n_seqs=100){
	seq_names <- get_seq_names(fasta_file)
	count_data <- data.frame(Representative_Sequence=seq_names, total=100)
	count_file <- gsub('fasta', 'count_table', fasta_file)
	write.table(count_data, count_file, row.names=F, quote=F, sep='\t')
}
