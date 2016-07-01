subsample <- function(stub, fraction, replicate){

	fraction <- as.numeric(gsub("_", "\\.", fraction))

	rep <- as.numeric(gsub("^0", "", replicate))
	set.seed(rep)

	path <- paste0('data/', stub, '/', stub)

	fasta_file <- paste0(path, '.fasta')
	fasta <- scan(fasta_file, what="", sep="\n", quiet=T)
	fasta_names <- substring(fasta[1:length(fasta) %% 2 == 1],2)
	fasta_seqs <- fasta[1:length(fasta) %% 2 == 0]
	o <- order(fasta_names)
	fasta_names <- fasta_names[o]
	fasta_seqs <- fasta_seqs[o]

	count_file <- paste0(path, '.count_table')
	count <- read.table(file=count_file, header=T, stringsAsFactors=FALSE)
	count <- count[order(count$Representative_Sequence),]

	taxonomy_file <- paste0(path, '.taxonomy')
	taxonomy <- read.table(file=taxonomy_file, stringsAsFactors=FALSE)
	taxonomy <- taxonomy[order(taxonomy$V1),]

	stopifnot(fasta_names == count$Representative_Sequence)
	stopifnot(fasta_names == taxonomy$V1)

	n_seqs <- length(fasta_names)
	subsample_size <- floor(n_seqs * fraction)
	keep <- sample(1:n_seqs, subsample_size)

	fraction <- format(fraction, nsmall=1L)
	fraction <- gsub('\\.', '_', fraction)

	#fasta
	fasta_names <- paste0(">", fasta_names)
	write(paste(fasta_names[keep], fasta_seqs[keep], sep='\n'), paste0(path, '.', fraction, '.', replicate, '.fasta'))

	#taxonomy
	write.table(taxonomy[keep,], paste0(path, '.', fraction, '.', replicate, '.taxonomy'), col.names=F, row.names=F, quote=F, sep='\t')

	#count
	write.table(count[keep,], paste0(path, '.', fraction, '.', replicate, '.count_table'), col.names=T, row.names=F, quote=F, sep='\t')

}
