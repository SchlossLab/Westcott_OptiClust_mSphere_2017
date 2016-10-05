library(dplyr, quietly=T, warn.conflicts=F)
library(tidyr, quietly=T, warn.conflicts=F)
library(ggplot2, quietly=T, warn.conflicts=F)
library(wesanderson, quietly=T, warn.conflicts=F)
library(cowplot, quietly=T, warn.conflicts=F)
library(scales)
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
			gather(metric, value, cluster_secs, cluster_kb) %>%
			group_by(frac, dataset, metric) %>%
			summarize(avg=mean(value, na.rm=T),
								min=min(value, na.rm=T),
								max=max(value, na.rm=T))

secs <- scaling %>% filter(metric == "cluster_secs") %>%
			ggplot() +
			geom_line(aes(frac, avg, color=dataset))+
			geom_point(aes(frac, avg, color=dataset))+
			geom_errorbar(aes(frac, ymin=min, ymax=max, col=dataset), width=0.02)+
			coord_cartesian(xlim = c(0, 1), ylim=c(0,3000))

kb <- scaling %>% filter(metric == "cluster_kb") %>%
			ggplot() +
			geom_line(aes(frac, avg, color=dataset))+
			geom_point(aes(frac, avg, color=dataset))+
			geom_errorbar(aes(frac, ymin=min, ymax=max, col=dataset), width=0.02)+
			coord_cartesian(xlim = c(0, 1))



c_secs <- data %>% filter(method=="mcc") %>% select(dataset, frac, cluster_secs)

subset <- c_secs %>% filter(dataset == "marine")
nls(cluster_secs ~ b * frac ^ z, start = list(b = 1000, z = 3), subset)

subset <- c_secs %>% filter(dataset == "soil")
nls(cluster_secs ~ b * frac ^ z, start = list(b = 1000, z = 3), subset)

subset <- c_secs %>% filter(dataset == "human")
nls(cluster_secs ~ b * frac ^ z, start = list(b = 1000, z = 3), subset)

subset <- c_secs %>% filter(dataset == "mice")
nls(cluster_secs ~ b * frac ^ z, start = list(b = 1000, z = 3), subset)


c_mem <- data %>% filter(method=="mcc") %>%
										select(dataset, frac, cluster_kb)
subset <- c_mem %>% filter(dataset == "marine")
nls(cluster_kb ~ b * frac ^ z, start = list(b = 1e6, z = 2), subset)

subset <- c_mem %>% filter(dataset == "soil")
nls(cluster_kb ~ b * frac ^ z, start = list(b = 1e6, z = 2), subset)

subset <- c_mem %>% filter(dataset == "human")
nls(cluster_kb ~ b * frac ^ z, start = list(b = 1e6, z = 3), subset)

subset <- c_mem %>% filter(dataset == "mice")
nls(cluster_kb ~ b * frac ^ z, start = list(b = 1e6, z = 3), subset)

#http://stackoverflow.com/questions/35996877/fitting-multiple-nls-functions-with-dplyr
# consider killing initial loading time
