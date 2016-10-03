library(dplyr, quietly=T, warn.conflicts=F)
library(tidyr, quietly=T, warn.conflicts=F)
library(ggplot2, quietly=T, warn.conflicts=F)
library(cowplot, quietly=T, warn.conflicts=F)
library(wesanderson, quietly=T, warn.conflicts=F)


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

steps_data <- read.table(file="data/processed/cluster_steps.summary", header=TRUE, stringsAsFactors=FALSE)

datasets <- c('soil', 'marine', 'mice', 'human', 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human", "Even", "Staggered")
names(pretty_datasets) <- datasets

conv <- c("close", "full")
pretty_conv <- c("Converge within 0.01%", "Complete convergence")
names(pretty_conv) <- conv

variables <- c("mcc", "sobs", "secs")
pretty_variables <- c("Matthew's\nCorrelation Coefficient", "Number of OTUs", "Time to Cluster\n(seconds)")
names(pretty_variables) <- variables


conv_comparison <- steps_data %>%
			filter(frac==1.0 & method == "mcc") %>%
			select(-method, -frac, -rep) %>%
			gather(metric, value, close_mcc, close_sobs, close_secs,
													full_mcc, full_sobs, full_secs) %>%
			group_by(dataset, metric) %>%
			summarize(avg=median(value, na.rm=T),
								min=min(value, na.rm=T),
								max=max(value, na.rm=T)) %>%
			separate(metric, into=c("convergence", "parameter"), sep="_")

conv_comparison$dataset <- factor(conv_comparison$dataset, datasets)
conv_comparison$convergence <- factor(conv_comparison$convergence, conv)
conv_comparison$parameter <- factor(conv_comparison$parameter, variables)


facet_labels <- as_labeller(pretty_variables)

figure <- ggplot(conv_comparison, aes(dataset, avg, col=dataset, shape=convergence))+
	geom_point(position = position_dodge(0.3), size=2) +
	geom_errorbar(position = position_dodge(0.3), aes(ymin=min, ymax=max), width=0.2) +
	facet_grid(parameter ~ ., scales='free_y', switch = 'y', labeller= facet_labels, margins=0) +
	scale_x_discrete(breaks=levels(conv_comparison$dataset),
		labels=pretty_datasets[levels(conv_comparison$dataset)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
		c('gray', wes_palette("Darjeeling")), guide=F)+
	scale_shape_manual(name=NULL, values=c(19,21),
		labels=pretty_conv) +
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
	ggsave('results/figures/convergence.tiff', width=4, height=5, unit='in')
