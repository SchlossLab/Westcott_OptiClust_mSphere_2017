###############################################################################
#
# Functions to generate the appropriate file names...
#
###############################################################################

#this function concatenates together the dataset, fraction, replicate number,
#and method to generate the filename stub
cat_cols_files <- function(x){
	x["frac"] <- gsub("\\.", "_", x["frac"])
	x["frac"] <- gsub("^1$", "1_0", x["frac"])
	x["rep"] <- gsub("^\\s*(\\d)$", "0\\1", x["rep"])
	paste(x["dataset"], x["frac"], x["rep"], x["method"], sep='.')
}

#takes file name stub from cat_cols_files and returns the stats files
build_cluster_stats_files <- function(x){
	seed <- cat_cols_files(x)
	paste0("data/", x["dataset"], "/", seed, ".stats")
}

#takes file name stub from cat_cols_files and returns the sensspec files
build_cluster_sensspec_files <- function(x){
	seed <- cat_cols_files(x)
	paste0("data/", x["dataset"], "/", seed, ".sensspec")
}

#takes file name stub from cat_cols_files and returns the list files
build_cluster_list_files <- function(x){
	seed <- cat_cols_files(x)
	paste0("data/", x["dataset"], "/", seed, ".list")
}

#takes file name stub from cat_cols_files and returns the appropriate distance
#filename
build_dist_stats_files <- function(x){
	#an was the only method that required the larger distance matrix
	if(x["method"] %in% c("accuracy", "f1score", "fn", "mcc", "nn")){
		x["method"] <- 'sm'
	} else if(x["method"] == 'an'){
		x["method"] <- 'lg'
	} else {
		x["method"] <- NA
	}

	seed <- cat_cols_files(x)

	stats <- NA
	if(!is.na(x["method"])){
		stats <- paste0("data/", x["dataset"], "/", seed, ".stats")
	}
	unlist(stats)
}


###############################################################################
#
# Functions to extract data from the appropriate files...
#
###############################################################################

#reads in stats files and returs the amount of walltime required to run
#command and the maximum amount of RAM required to complete command. If it
#timed out or used too much RAM, it returns NA values
get_performance_stats <- function(file_name){

	data <- scan(file_name, what="", sep='\n', quiet=T)

	stats <- c(NA,NA)

	if(sum(z <- grepl("^Out of memory", data) != 0)){
		stats <- c(NA,NA)
	} else if(sum(z <- grepl("^FINISHED", data) != 0)){
		parsed <- unlist(strsplit(data[z], " "))
		stats <- as.numeric(parsed[c(3,11)])
	} else if(sum(z <- grepl("^TIMEOUT", data) != 0)){
		stats <- c(NA,NA)
	} else if(sum(z <- grepl("^MEM_RSS", data) != 0)){
		stats <- c(NA,NA)
	}

	#for the small datasets, noticed that the memory required was -1, which was
	#probably the initial value from the timeout software. Convert these values
	#to zero...
	stats[2] <- ifelse(stats[2]<0,0,stats[2])

	return(stats)
}

#reads in sensspec files and returns the values from the sens_spec command. if
#the clustering bombed out, then return NA for the senssec values.
get_sensspec_data <- function(x){
	data <- rep(NA, 12)

	#for some of the slower/more memory intensive methods they were not able to
	#complete and outputted an empty list and sensspec file
	if(file.info(x)$size != 0){
		data <- read.table(file=x, stringsAsFactors=F, header=T)[,-c(1,2)]
	}

	return(data)
}

#extracts the number of OTUs for each clustering methods
get_num_otus <- function(x){

	num_otus <- rep(NA, length(x))
	names(num_otus) <- x

	otu_data <- read.table(file='data/processed/sobs_counts.tsv', stringsAsFactors=F)
	num_otus[otu_data$V1] <- as.numeric(otu_data$V3)

	return(num_otus)
}

#extracts the amount of time required to generate the distance matrix used
#for generating OTUs
get_dist_time <- function(x){

	seconds <- NA

	if(!is.na(x)){
		stats <- scan(x, quiet=T, what="")

		elapsed <- gsub("elapsed", "", stats[3])
		timing <- as.numeric(unlist(strsplit(elapsed, ":")))
		if(length(timing) == 2){
			timing <- c(0, timing)
		}

		seconds <- 3600*timing[1] + 60*timing[2] + timing[3]
	}
	return(seconds)
}


###############################################################################
#
# Run the analysis...
#
###############################################################################

# Six datasets - two synthetic and four biological
datasets <- c("even", "human", "marine", "mice", "soil", "staggered")
n_datasets <- length(datasets)

# these are the fractions of *unique* sequences that were used for each dataset
fractions <- seq(0.2,1,0.2)
n_fracs <- length(fractions)

# we randomized the sequences (and their order) in each fraction ten times
replicates <- 1:10
n_reps <- length(replicates)

# these are the 22 methods that we tested for clustering
methods <- c("accuracy", "an", "an_split2_8", "an_split3_8", "an_split4_8", "an_split5_8", "an_split6_8",
			"f1score", "fn", "mcc", "mcc_split2_8", "mcc_split3_8", "mcc_split4_8", "mcc_split5_8", "mcc_split6_8",
			"nn", "otuclust", "sumaclust", "swarm", "uagc", "udgc", "vagc_1", "vagc_8", "vdgc_1", "vdgc_8",
			"vdgc_split2_8", "vdgc_split3_8", "vdgc_split4_8", "vdgc_split5_8", "vdgc_split6_8", "mcc_agg")
n_methods <- length(methods)


#need to populate data frame with dataset, fraction, replicate, method
dataset_vector <- rep(datasets, each=n_reps*n_fracs*n_methods)
frac_vector <- rep(fractions, each=n_reps*n_methods, times=n_datasets)
rep_vector <- rep(replicates, times=n_datasets*n_fracs*n_methods)
method_vector <- rep(methods, each=n_reps, times=n_fracs*n_datasets)

results <- data.frame(dataset=dataset_vector, frac=frac_vector, rep=rep_vector, method=method_vector, stringsAsFactors=F)


#from each *.stats file, extract the performance stats and concatenate to the
#RHS of the results data frame
cluster_stats_names <- apply(results, 1, build_cluster_stats_files)
all_stats <- t(sapply(cluster_stats_names, get_performance_stats))
results$cluster_secs <- all_stats[,1] #timing data
results$cluster_kb <- all_stats[,2] #memory data


#from each *.sensspec file, extract the ROC data to the RHS of the results data
#frame
cluster_sensspec_names <- apply(results, 1, build_cluster_sensspec_files)

sens_spec <- do.call(rbind, lapply(cluster_sensspec_names, get_sensspec_data))
results <- cbind(results, sens_spec)

#load the sobs data from data/processed/sobs_counts.tsv
cluster_list_names <- apply(results, 1, build_cluster_list_files)
results$num_otus <- get_num_otus(cluster_list_names)

#output the elapsed time (secods) required to generate the distance matrix for
#the clustering commands that required a small or large distance matrix. not
#sure what to think of this since all of the methods need a distance matrix to
#get the confusion matrix; then again, the split methods generate the distance
#matrix on the fly
dist_stats_names <- apply(results, 1, build_dist_stats_files)
results$dist_secs <- sapply(dist_stats_names, get_dist_time)


write.table(x=results, file='data/processed/cluster_data.summary',
			row.names=FALSE, col.names=TRUE, quote=FALSE)
