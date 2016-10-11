#devtools::install_github("hadley/ggplot2")
#devtools::install_github("hadley/scales")
#devtools::install_github("wilkelab/cowplot")
library(dplyr, quietly=T, warn.conflicts=F)
library(tidyr, quietly=T, warn.conflicts=F)
library(ggplot2, quietly=T, warn.conflicts=F)
library(wesanderson, quietly=T, warn.conflicts=F)
library(cowplot, quietly=T, warn.conflicts=F)

basic_methods <- c('mcc')
pretty_methods <- c('OptiClust')
names(pretty_methods) <- basic_methods

datasets <- c('soil', 'marine', 'mice', 'human')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human")
names(pretty_datasets) <- datasets

metrics <- c("cluster_secs", "cluster_kb")
pretty_metrics <- c("Time for Each\nClustering Step (seconds)", "Memory Required\n(GB)")
names(pretty_metrics) <- metrics


speed_data <- read.table(file="data/processed/mcc_steps.summary", header=T)

speed_summary <- speed_data %>%
			select(dataset, frac, full_secs_cluster, full_steps) %>%
			filter(dataset %in% datasets) %>%
			group_by(frac, dataset) %>%
			summarize(avg=mean(full_secs_cluster/full_steps, na.rm=T),
								min=min(full_secs_cluster/full_steps, na.rm=T),
								max=max(full_secs_cluster/full_steps, na.rm=T))

speed_models <- speed_data %>%
		filter(dataset %in% datasets) %>%
		select(dataset, frac, full_secs_cluster, full_steps) %>%
		group_by(dataset) %>%
		do(model = nls((full_secs_cluster/full_steps) ~ b * frac ^ z, start = list(b = 1000, z = 2), data= .))

# speed_models[[1,2]]$m$getPars()["z"]	#2.131886
# speed_models[[2,2]]$m$getPars()["z"]	#2.975044
# speed_models[[3,2]]$m$getPars()["z"]	#2.687899
# speed_models[[4,2]]$m$getPars()["z"]	#2.379366




memory_data <- read.table(file="data/processed/cluster_data.summary", header=T)

memory_summary <- memory_data %>%
		filter(dataset %in% datasets, method=="mcc") %>%
		mutate(cluster_gb=cluster_kb/1048000) %>%
		select(dataset, frac, cluster_gb) %>%
		group_by(frac, dataset) %>%
		summarize(avg=mean(cluster_gb, na.rm=T),
							min=min(cluster_gb, na.rm=T),
							max=max(cluster_gb, na.rm=T))

memory_models <- memory_data %>%
		filter(dataset %in% datasets, method == "mcc") %>%
		mutate(cluster_gb=cluster_kb/1048000) %>%
		select(dataset, frac, cluster_gb) %>%
		group_by(dataset) %>%
		do(model = nls((cluster_gb) ~ b * frac ^ z, start = list(b = 1e6, z = 3), data= .))

# memory_models[[1,2]]$m$getPars()["z"]	#1.998879
# memory_models[[2,2]]$m$getPars()["z"]	#1.97656
# memory_models[[3,2]]$m$getPars()["z"]	#1.995457
# memory_models[[4,2]]$m$getPars()["z"]	#1.957556

my_theme <- theme_classic() +
	theme(
		axis.text.x = element_blank(),
		axis.text.y=element_text(size=7, margin=margin(r=2,0,0,0)),
		axis.title.y=element_text(size=7),
		axis.title.x=element_text(size=7),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
		legend.position = "none"
	)

my_legend <- theme(
		legend.text = element_text(size=7),
		legend.key.size = unit(0.55, "line"),
 		legend.key = element_rect(fill = NA, linetype=0),
		legend.position=c(0.3, 0.7),
		legend.title=element_text(lineheight=-1),
		legend.background = element_rect(fill="white", color="black"),
		legend.margin = margin(t=0,4,4,4)
	)

speed_plot <- speed_summary %>%
		ggplot() +
		geom_line(aes(frac, avg, color=dataset)) +
		geom_point(aes(frac, avg, color=dataset)) +
		geom_errorbar(aes(frac, ymin=min, ymax=max, col=dataset), width=0.02) +
		scale_y_sqrt(breaks=c(0,2,4,8,16,32,64,128,256)) +
		scale_color_manual(
						breaks=names(pretty_datasets),
						labels=pretty_datasets,
						values=rev(c('black', wes_palette("Darjeeling")[1:3])),
						name=NULL) +
		scale_shape_manual(
						breaks=names(pretty_datasets),
						labels=pretty_datasets,
						values = rep(16,6),
						name=NULL) +
		xlab(NULL) +
		ylab(pretty_metrics[1]) +
		my_theme +
		my_legend

memory_plot <- memory_summary %>%
	ggplot() +
	geom_line(aes(frac, avg, color=dataset)) +
	geom_point(aes(frac, avg, color=dataset)) +
	geom_errorbar(aes(frac, ymin=min, ymax=max, col=dataset), width=0.02) +
	scale_y_sqrt(breaks=c(0,1,2,3,4,5,6,7,8), limits=c(0,8)) +
	scale_color_manual(
					breaks=names(pretty_datasets),
					labels=pretty_datasets,
					values=rev(c('black', wes_palette("Darjeeling")[1:3])),
					name=NULL) +
	scale_shape_manual(
					breaks=names(pretty_datasets),
					labels=pretty_datasets,
					values = rep(16,6),
					name=NULL)+
	xlab("Fraction of Dataset Analyzed") +
	ylab(pretty_metrics[2]) +
	my_theme +
	theme(
		axis.text.x = element_text(size=7,margin=margin(t=3,0,0,0)),
		axis.title.y = element_text(margin=margin(r=13,0,0,0))
	)


ggdraw() +
	draw_plot(speed_plot,  x=0, y=0.535, 1.0, 0.465) +
	draw_plot(memory_plot, x=0, y=0.000, 1.0, 0.535) +
	draw_plot_label(c("A", "B"), x=c(0,0), y=c(1.00,0.54), size=12) +
	ggsave('results/figures/speed_memory.tiff', width=3.5, height=4.0, unit='in')
