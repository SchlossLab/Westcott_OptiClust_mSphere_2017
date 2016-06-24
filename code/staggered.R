get_seq_names <- function(fasta_file){
	fasta_data <- scan(fasta_file, what=character(), sep='\n', quiet=T)
	is_seq_name <- grepl("^>", fasta_data)
	gsub('>', '', fasta_data[is_seq_name])
}

staggered <- function(fasta_file, max_n_seqs=200){
	set.seed(1)
	seq_names <- get_seq_names(fasta_file)
	freqs <- floor(runif(length(seq_names), 1, max_n_seqs))
	count_data <- data.frame(Representative_Sequence=seq_names, total=freqs)
	count_file <- gsub('fasta', 'count_table', fasta_file)
	write.table(count_data, count_file, row.names=F, quote=F, sep='\t')
}
