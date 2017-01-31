library(dplyr)

dataset <- c('soil', 'marine', 'human', 'mice', 'staggered', 'even')

distances <- read.table(file="data/processed/distance_counts.tsv")
distances$V2 <- gsub("data/(.*)/(.*).1_0.01.sm.dist", "\\1", distances$V2)
rownames(distances) <- distances$V2

sobs <- read.table(file="data/processed/sobs_counts.tsv")
sobs <- sobs[grep("1_0.*.mcc.list", x=sobs$V1),]
sobs$V1 <- gsub("data/(.*)/.*\\.1_0.*", "\\1", sobs$V1)
sobs_mean <- sobs %>%
							select(c(1,3)) %>%
							group_by(V1) %>%
							summarize(ave=mean(V3))

get_stats <- function(dataset) {

	count_file_name <- paste0('data/', dataset, '/', dataset, '.count_table')
	count_data <- read.table(file=count_file_name, header=T)

	n_unique_seqs <- nrow(count_data)
	n_total_seqs <- sum(count_data$total)

	n_samples <- ncol(count_data) - 2
	if(n_samples == 0) n_samples <- NA

	n_distances <- distances[dataset, "V1"]
	n_sobs <- sobs_mean %>% filter(V1==dataset) %>% select(ave) %>% .[[1]]
	
	c(n_samples=n_samples, n_unique_seqs=n_unique_seqs, n_total_seqs=n_total_seqs,
		n_distances=n_distances, n_sobs=n_sobs)
}

summary_table <- t(sapply(dataset, get_stats))
rownames(summary_table) <- dataset

write.table(summary_table, file="data/processed/datasets.summary", quote=F, sep='\t')
