library(dplyr, quietly=T, warn.conflicts=F)
library(tidyr, quietly=T, warn.conflicts=F)
library(ggplot2, quietly=T, warn.conflicts=F)
library(wesanderson, quietly=T, warn.conflicts=F)
library(cowplot, quietly=T, warn.conflicts=F)

basic_methods <- c('mcc')#,'sumaclust', 'udgc','vdgc_1')
pretty_methods <- c('Average\nNeighbor', 'OptiClust')#, 'Sumaclust',
										#'DGC with\nUSEARCH', 'DGC with\nVSEARCH')
names(pretty_methods) <- basic_methods

datasets <- c('soil', 'marine', 'mice', 'human')#, 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human")#, "Even", "Staggered")
names(pretty_datasets) <- datasets

metrics <- c("cluster_secs")#, "cluster_kb")
pretty_metrics <- c("Time to Cluster\n(seconds)")#, "Memory Required to\nCluster (kb)")
names(pretty_metrics) <- metrics


data <- read.table(file="data/processed/cluster_data.summary", header=T)

scaling <- data %>%
			select(dataset, frac, rep, method, cluster_secs, cluster_kb) %>%
			filter(method %in% basic_methods, dataset %in% datasets) %>%
			gather(metric, value, cluster_kb) %>%
			group_by(frac, dataset, method, metric) %>%
			summarize(avg=mean(value, na.rm=T),
								min=min(value, na.rm=T),
								max=max(value, na.rm=T))

ggplot(scaling) +
		geom_line(aes(frac, avg, col=dataset, shape=method))+
		geom_point(aes(frac, avg, col=dataset, shape=method))+
		geom_errorbar(aes(frac, avg, ymin=min, ymax=max, col=dataset), width=0.02)+
	#	scale_y_continuous(trans=trans_new('quad_trans', function(x)x^(1/2), function(x)x^2))+
		coord_cartesian(xlim = c(0, 1))
