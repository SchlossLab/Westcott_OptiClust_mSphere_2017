dataset <- c('soil', 'marine', 'human', 'mice', 'staggered', 'even')

count_file_names <- paste0('data/', dataset, '/', dataset, '.count_table')

get_stats <- function(count_file_name) {
	count_data <- read.table(file=count_file_name, header=T)

	n_unique_seqs <- nrow(count_data)
	n_total_seqs <- sum(count_data$total)

	n_samples <- ncol(count_data) - 2
	if(n_samples == 0) n_samples <- NA

	c(n_samples=n_samples, n_unique_seqs=n_unique_seqs, n_total_seqs=n_total_seqs)
}

summary_table <- t(sapply(count_file_names, get_stats))
rownames(summary_table) <- dataset

write.table(summary_table, file="data/processed/datasets.summary", quote=F, sep='\t')

