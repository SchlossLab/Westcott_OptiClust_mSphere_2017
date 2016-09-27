#this function concatenates together the dataset, fraction, replicate number,
#and method to generate the filename stub
cat_cols_files <- function(x){
	x["frac"] <- gsub("\\.", "_", x["frac"])
	x["frac"] <- gsub("^1$", "1_0", x["frac"])
	x["rep"] <- gsub("^\\s*(\\d)$", "0\\1", x["rep"])
	paste(x["dataset"], x["frac"], x["rep"], x["method"], sep='.')
}


#takes file name stub from results and returns the steps files
build_steps_files <- function(x){
	seed <- cat_cols_files(x)
	paste0("data/", x["dataset"], "/", seed, ".steps")
}


#return the total number of steps to reach point where change is less than #0.01% or to convergence (0.00% change)
get_required_steps <- function(file){
	steps <- read.table(file=file, header=T)

	mcc_a <- steps[-nrow(steps),"mcc"]
	mcc_b <- steps[-1, "mcc"]

	c(min(steps$iter[(mcc_b - mcc_a) / mcc_a < 0.0001]), max(steps$iter))
}

# Six datasets - two synthetic and four biological
datasets <- c("even", "human", "marine", "mice", "soil", "staggered")
n_datasets <- length(datasets)

# these are the fractions of *unique* sequences that were used for each dataset
fractions <- 1#seq(0.2,1,0.2)
n_fracs <- length(fractions)

# we randomized the sequences (and their order) in each fraction ten times
replicates <- 1:10
n_reps <- length(replicates)

# focus on the mcc method
methods <- c("mcc", "mcc_agg")
n_methods <- length(methods)

dataset_vector <- rep(datasets, each=n_reps*n_fracs*n_methods)
frac_vector <- rep(fractions, each=n_reps*n_methods, times=n_datasets)
rep_vector <- rep(replicates, times=n_datasets*n_fracs*n_methods)
method_vector <- rep(methods, each=n_reps, times=n_fracs*n_datasets)

results <- data.frame(dataset=dataset_vector, frac=frac_vector, rep=rep_vector, method=method_vector, stringsAsFactors=F)

steps_names <- apply(results, 1, build_steps_files)
all_stats <- t(sapply(steps_names, get_required_steps))
results$close_enough <- all_stats[,1] #within 0.01%
results$convergence <- all_stats[,2] #complete convergence

write.table(x=results, file='data/processed/cluster_steps.summary',
			row.names=FALSE, col.names=TRUE, quote=FALSE)
