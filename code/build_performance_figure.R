library(dplyr, warn.conflicts=F)
library(tidyr, warn.conflicts=F)
library(ggplot2, warn.conflicts=F)
library(cowplot, warn.conflicts=F)
library(wesanderson, warn.conflicts=F)

basic_methods <- c('an', 'fn',
									'nn', 'otuclust', 'sumaclust', 'swarm',
									'uagc', 'udgc', 'vagc_1', 'vdgc_1', 'mcc')
pretty_methods <- c('Average\nNeighbor', 'Furthest\nNeighbor',
 										'Nearest\nNeighbor', 'OTUCLUST', 'Sumaclust', 'Swarm',
										'AGC with\nUSEARCH', 'DGC with\nUSEARCH',
										'AGC with\nVSEARCH', 'DGC with\nVSEARCH', 'OptiClust')
names(pretty_methods) <- basic_methods

datasets <- c('soil', 'marine', 'mice', 'human', 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human", "Even", "Staggered")
names(pretty_datasets) <- datasets

metrics <- c("mcc", "num_otus", "cluster_secs")
pretty_metrics <- c("Matthew's\nCorrelation Coefficient", "Number of OTUs", "Time to Cluster\n(seconds)")
names(pretty_metrics) <- metrics


data <- read.table(file="data/processed/cluster_data.summary", header=T)

data$cluster_secs[data$cluster_secs > 5000] <- NA

subset <- data %>%
			select(dataset, frac, rep, method, cluster_secs, mcc, num_otus) %>%
			filter(frac==1.0 & method %in% basic_methods) %>%
			gather(metric, value, mcc, num_otus, cluster_secs) %>%
			group_by(dataset, method, metric) %>%
			summarize(avg=mean(value, na.rm=T),
								min=min(value, na.rm=T),
								max=max(value, na.rm=T))

method_ordering <- data %>%
			filter(frac==1.0 & method %in% basic_methods) %>%
			group_by(method) %>%
			summarize(avg_mcc=mean(mcc, na.rm=T)) %>%
			arrange(desc(avg_mcc))

subset$method <- factor(subset$method, method_ordering$method)
subset$dataset <- factor(subset$dataset, datasets)
subset$metric <- factor(subset$metric, metrics)

my_theme <- theme_classic() +
	theme(
		axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, size=7),
		axis.text.y=element_text(size=7),
		axis.title.y=element_text(size=7),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
		strip.background = element_blank()
	)


facet_labels <- as_labeller(pretty_metrics)

figure <- ggplot(subset, aes(method, avg, col=dataset, shape=dataset))+
	geom_point(position = position_dodge(0.5), size=2) +
	geom_errorbar(position = position_dodge(0.5), aes(ymin=min, ymax=max), width=0.2) +
	expand_limits(y=c(0,1)) +
	geom_vline(xintercept=0.5 + (1:(length(levels(subset$method))-1))) +
	facet_grid(metric ~ ., scales='free_y', switch = 'y', labeller= facet_labels, margins=0) +
	scale_x_discrete(breaks=levels(subset$method),
		labels=pretty_methods[levels(subset$method)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
		c('black', wes_palette("Darjeeling")), name=NULL)+
	scale_shape_manual(breaks=datasets, labels=pretty_datasets,
		values = c(15, 16, 17, 21, 22, 23), name=NULL,
		guide = guide_legend(override.aes = list(linetype = "blank")))+
	xlab(NULL) + ylab(NULL) +
	my_theme +
	theme(legend.title=element_text(size=7),
		legend.text = element_text(size=6),
		legend.key.size = unit(0.55, "line"),
 		legend.key = element_rect(fill = NA, linetype=0),
		legend.position=c(.65, .65), plot.margin=margin(1,1,1,0, unit="mm"),
		legend.title=element_text(lineheight=-1),
		legend.background = element_rect(fill="white"),
		plot.margin=margin(1,1,1,0, unit="mm"))
figure

ggdraw() +
	draw_plot(figure) +
	draw_plot_label(c("A", "B", "C"), x=c(0,0,0), y=c(1.00,0.71,0.41), size=12) +
	ggsave('results/figures/performance.tiff', width=4, height=5.5, unit='in')
