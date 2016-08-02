cat_cols_files <- function(x){
	x["frac"] <- gsub("\\.", "_", x["frac"])
	x["rep"] <- gsub(" ", "0", x["rep"])
	paste(x["dataset"], x["frac"], x["rep"], x["method"], sep='.')
}

build_cluster_stats_files <- function(x){
	seed <- cat_cols_files(x)
	paste0("data/", x["dataset"], "/", seed, ".stats")
}

build_cluster_sensspec_files <- function(x){
	seed <- cat_cols_files(x)
	paste0("data/", x["dataset"], "/", seed, ".sensspec")
}

build_dist_stats_files <- function(x){
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


get_stats <- function(file_name){

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

	return(stats)
}


datasets <- c("even", "human", "marine", "mice", "sediment", "soil", "staggered")

fractions <- seq(0.2,1,0.2)
n_fracs <- length(fractions)

replicates <- 1:10
n_reps <- length(replicates)

methods <- c("accuracy", "an", "an_split5_1", "an_split5_8", "f1score", "fn", "mcc", "mcc_split5_1", "mcc_split5_8", "nn", "otuclust", "sumaclust", "swarm", "uagc", "udgc", "vagc_1", "vagc_8", "vdgc_1", "vdgc_8", "vdgc_split5_1", "vdgc_split5_8")
n_methods <- length(methods)

# dataset, fraction, replicate, method, memory(kb), walltime(sec), mcc, f1score, accuracy
d <- "marine"
path <- paste("data", d, d, sep='/')

dataset_vector <- rep(d, n_reps*n_fracs*n_methods)
frac_vector <- rep(fractions, each=n_reps*n_methods)
rep_vector <- rep(replicates, n_fracs*n_methods)
method_vector <- rep(methods, each=n_reps*n_fracs)

results <- data.frame(dataset=dataset_vector, frac=frac_vector, rep=rep_vector, method=method_vector, stringsAsFactors=F)

cluster_stats_names <- apply(results, 1, build_cluster_stats_files)
all_stats <- t(sapply(cluster_stats_names, get_stats))
results$cluster_secs <- all_stats[,1]
results$cluster_kb <- all_stats[,2]

get_sensspec <- function(x){
	read.table(file=x, stringsAsFactors=F, header=T)[,-c(1,2)]
}

cluster_sensspec_names <- apply(results, 1, build_cluster_sensspec_files)
senspec <- sapply(cluster_sensspec_names, get_sensspec)

dist_stats_names <- apply(results, 1, build_dist_stats_files)
