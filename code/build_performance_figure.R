library(dplyr)
library(ggplot2)
library(cowplot)
library(wesanderson)

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

data <- read.table(file="data/processed/cluster_data.summary", header=T)

subset <- data %>%
			filter(frac==1.0 & method %in% basic_methods) %>%
			group_by(dataset, method) %>%
			summarize(avg_mcc=mean(mcc, na.rm=T),
								sd_mcc=sd(mcc, na.rm=T),
								avg_sobs=mean(num_otus, na.rm=T),
								sd_sobs=sd(num_otus, na.rm=T),
								n=sum(!is.na(mcc))) %>%
			mutate(cov_mcc=sd_mcc/avg_mcc)

method_ordering <- data %>%
			filter(frac==1.0 & method %in% basic_methods) %>%
			group_by(method) %>%
			summarize(avg_mcc=mean(mcc, na.rm=T)) %>%
			arrange(desc(avg_mcc))

subset$method <- factor(subset$method, method_ordering$method)
subset$dataset <- factor(subset$dataset, datasets)

my_theme <- theme_classic() +
	theme(axis.text.x =element_blank(),
		axis.text.y=element_text(size=8),
		axis.ticks.x = element_blank(),
		axis.title.y=element_text(size=8),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
		legend.position="none"
	)

plot_performance <- function(x, var, label, ylimits){
	mcc <- ggplot(x, aes_string("method", var, col="dataset", shape="dataset")) +
		geom_point(position = position_dodge(0.5), size=2) +
		geom_vline(xintercept=0.5 + 1:(length(levels(x$method))-1)) +
		coord_cartesian(ylim=ylimits) +
		ylab(label) +
		xlab(NULL) +
		scale_x_discrete(breaks=levels(subset$method),
			labels=pretty_methods[levels(subset$method)]) +
		scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
			c('black', wes_palette("Darjeeling")))+
		scale_shape_manual(breaks=datasets, labels=pretty_datasets,
			guide=guide_legend(override.aes=aes(size=2)),
			values = c(15, 16, 17, 21, 22, 23))+
		my_theme

	if(var != 'avg_sobs'){
		mcc <- mcc + theme(axis.title.y=element_text(margin=margin(0,10,0,0)))
	}
	return(mcc)
}

mcc <- plot_performance(subset, 'avg_mcc', "Mean Matthew's\nCorrelation Coefficient", c(0,1))
cov <- plot_performance(subset, 'cov_mcc', "Coefficient of Variation for\nMatthew's Correlation Coefficient", c(0,0.04))
sobs <- plot_performance(subset, 'avg_sobs', "Number of OTUs", c(0,1.05e5))

my_legend <- theme(
	legend.title=element_blank(),
	legend.position = c(0.12, 0.7),
	legend.text = element_text(size = 8),
	legend.key.height=unit(0.7,"line"),
	legend.key = element_rect(fill = NA, linetype=0),
	legend.margin = unit(-2,"line")
)

ggdraw() +
	draw_plot(mcc,0,0.7,1,0.3) +
	draw_plot(cov + my_legend, 0,0.40,1,0.3) +
	draw_plot(sobs + 	theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, size=8)), 0,0.02,1,0.38) +
	draw_plot_label(c("A", "B", "C"), x=c(0,0,0), y=c(1.00,0.72,0.42), size=18) +
	ggsave('results/figures/seeding.tiff', width=5.4, height=7.0, unit='in')
