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
		strip.background = element_blank(),
		axis.text.y = element_text(size=7),
		axis.text.x = element_text(size=7),
		axis.title = element_text(size=7),
		legend.position="none"
	)




cluster_data <- read.table(file="data/processed/cluster_data.summary", header=TRUE, stringsAsFactors=FALSE)

mcc_methods <- c("mcc", "mcc_agg")
pretty_methods <- c("Separate OTUs", "Single OTU")
names(pretty_methods) <- mcc_methods

datasets <- c('soil', 'marine', 'mice', 'human', 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human", "Even", "Staggered")
names(pretty_datasets) <- datasets

variables <- c("mcc", "num_otus", "cluster_secs")
pretty_variables <- c("Matthew's\nCorrelation Coefficient", "Number of OTUs", "Time to Cluster\n(seconds)")
names(pretty_variables) <- variables

agg_comparison <- cluster_data %>%
			filter(frac==1.0 & method %in% mcc_methods) %>%
			gather(variable, value, mcc, num_otus, cluster_secs) %>%
			group_by(dataset, method, variable) %>%
			summarize(avg=mean(value, na.rm=T),
								min=min(value, na.rm=T),
								max=max(value, na.rm=T)
								)
agg_comparison$dataset <- factor(agg_comparison$dataset, datasets)
agg_comparison$method <- factor(agg_comparison$method, mcc_methods)
agg_comparison$variable <- factor(agg_comparison$variable, variables)

facet_labels <- as_labeller(pretty_variables)

figure <- ggplot(agg_comparison, aes(dataset, avg, col=dataset, shape=method))+
	geom_point(position = position_dodge(0.3), size=2) +
	geom_errorbar(position = position_dodge(0.3), aes(ymin=min, ymax=max), width=0.2) +
	facet_grid(variable ~ ., scales='free_y', switch = 'y', labeller= facet_labels, margins=0) +
	scale_x_discrete(breaks=levels(agg_comparison$dataset),
		labels=pretty_datasets[levels(agg_comparison$dataset)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
		c('gray', wes_palette("Darjeeling")), guide=F)+
	scale_shape_manual(name="Sequences initialized as", values=c(19,21), labels=pretty_methods) +
	expand_limits(y=c(0,1)) +
	xlab(NULL) + ylab(NULL) +
	my_theme +
	theme(legend.title=element_text(size=7),
			legend.text = element_text(size=6),
			legend.key.size = unit(0.55, "line"),
			legend.background = element_blank(),
			legend.position=c(.8, .8), plot.margin=margin(1,1,1,0, unit="mm"))

ggdraw() +
	draw_plot(figure) +
	draw_plot_label(c("A", "B", "C"), x=c(0,0,0), y=c(1.00,0.68,0.36), size=12) +
	ggsave('results/figures/seeding.tiff', width=4, height=5, unit='in')
