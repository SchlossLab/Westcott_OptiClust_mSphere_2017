library(dplyr)
library(ggplot2)
library(tidyr)
library(wesanderson)
library(cowplot)


my_theme <- theme_classic() +
	theme(
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
#		strip.background = element_blank(),
#		strip.text.y = element_text(size = 11)
		axis.text.y = element_text(size=8),
		axis.text.x = element_blank(),
		axis.title = element_text(size=8),
		legend.position="none"
	)

my_legend <- theme(
		legend.title=element_text(size=0),
		legend.text = element_text(size=5),
		legend.key.size = unit(0.55, "line"),
		legend.background = element_blank()
	)


cluster_data <- read.table(file="data/processed/cluster_data.summary", header=TRUE, stringsAsFactors=FALSE)

mcc_methods <- c("mcc", "mcc_agg")
pretty_methods <- c("Separate OTUs", "Single OTU")

datasets <- c('soil', 'marine', 'mice', 'human', 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human", "Even", "Staggered")
names(pretty_datasets) <- datasets

agg_comparison <- cluster_data %>%
			filter(frac==1.0 & method %in% mcc_methods) %>%
			group_by(dataset, method) %>%
			summarize(avg_mcc=mean(mcc, na.rm=T),
								min_mcc=min(mcc, na.rm=T),
								max_mcc=max(mcc, na.rm=T),
								avg_secs=mean(cluster_secs, na.rm=T),
								min_secs=min(cluster_secs, na.rm=T),
								max_secs=max(cluster_secs, na.rm=T))
agg_comparison$dataset <- factor(agg_comparison$dataset, datasets)


steps_data <- read.table(file="data/processed/cluster_steps.summary", header=TRUE, stringsAsFactors=FALSE)

completion <- c("close_enough", "convergence")
pretty_completion <- c("Converge within 0.01%", "Complete convergence")
names(pretty_completion) <- completion


steps_comparison <- steps_data %>%
			filter(frac==1.0 & method == "mcc") %>%
			select(-method) %>%
			gather(completion, steps, close_enough, convergence) %>%
			group_by(dataset, completion) %>%
			summarize(median_steps=median(steps, na.rm=T),
								min_steps=min(steps, na.rm=T),
								max_steps=max(steps, na.rm=T))

steps_comparison$dataset <- factor(steps_comparison$dataset, datasets)


mcc <- ggplot(agg_comparison, aes(dataset, avg_mcc, col=dataset, shape=method))+
	geom_point(position = position_dodge(0.1), size=2) +
	geom_errorbar(position = position_dodge(0.1), aes(ymin=min_mcc, ymax=max_mcc), width=0.1) +
	scale_x_discrete(breaks=levels(agg_comparison$dataset),
		labels=pretty_datasets[levels(agg_comparison$dataset)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
		c('black', wes_palette("Darjeeling")), guide=F)+
	scale_shape_manual(name="Sequences initialized as", values=c(19,21), labels=pretty_methods) +
	expand_limits(y=c(0,1)) +
	xlab(NULL) + ylab("Matthew's\nCorrelation Coefficient") +
	my_theme +
	theme(axis.title.y=element_text(margin=margin(0,9,0,0))) +
	my_legend + 		theme(legend.position=c(.8, .35))


time <- ggplot(agg_comparison, aes(dataset, avg_secs, col=dataset, shape=method)) +
	geom_point(position = position_dodge(0.1), size=2) +
	geom_errorbar(position = position_dodge(0.1), aes(ymin=min_secs, ymax=max_secs), width=0.1) +
	scale_x_discrete(breaks=levels(agg_comparison$dataset),
		labels=pretty_datasets[levels(agg_comparison$dataset)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
		c('black', wes_palette("Darjeeling")), guide=F)+
	scale_shape_manual(name="Sequences initialized as", values=c(19,21), labels=pretty_methods) +
	expand_limits(y=c(0,1)) +
	xlab(NULL) + ylab("Execution Time\n(seconds)") +
	my_theme


steps <- ggplot(steps_comparison, aes(dataset, median_steps, col=dataset, shape=completion)) +
	geom_point(position = position_dodge(0.1), size=2) +
	geom_errorbar(position = position_dodge(0.1), aes(ymin=min_steps, ymax=max_steps), width=0.1) +
	scale_x_discrete(breaks=levels(steps_comparison$dataset),
		labels=pretty_datasets[levels(steps_comparison$dataset)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
		c('black', wes_palette("Darjeeling")), guide=F)+
	scale_shape_manual(name=NULL, values=c(0,15), labels=pretty_completion) +
	expand_limits(y=c(0,15)) +
	xlab(NULL) + ylab("Number of\nClustering Steps") +
	my_theme +
	theme(axis.title.y=element_text(margin=margin(0,16,0,0))) +
	my_legend + theme(legend.position=c(0.8, 0.85))



ggdraw() +
	draw_plot(mcc,0,0.7,1,0.3) +
	draw_plot(time, 0,0.40,1,0.3) +
	draw_plot(steps + 	theme(axis.text.x = element_text(size=8), axis.text.x=element_text(vjust=0.5)), 0,0.085,1,0.315) +
	draw_plot_label(c("A", "B", "C"), x=c(0,0,0), y=c(1.00,0.72,0.42), size=12) +
	ggsave('results/figures/algorithm.tiff', width=4, height=5, unit='in')
