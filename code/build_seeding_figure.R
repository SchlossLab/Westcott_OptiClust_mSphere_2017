library(dplyr)
library(ggplot2)
library(tidyr)
library(wesanderson)

cluster_data <- read.table(file="data/processed/cluster_data.summary", header=TRUE, stringsAsFactors=FALSE)

mcc_methods <- c("mcc", "mcc_agg")
pretty_methods <- c("Separate OTUs", "Single OTU")

datasets <- c('soil', 'marine', 'mice', 'human', 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human", "Even", "Staggered")
names(pretty_datasets) <- datasets

cluster <- cluster_data %>%
			filter(frac==1.0 & method %in% mcc_methods) %>%
			group_by(dataset, method) %>%
			summarize(avg_mcc=mean(mcc, na.rm=T),
								avg_secs=mean(cluster_secs, na.rm=T))
cluster$dataset <- factor(cluster$dataset, datasets)

my_theme <- theme_classic() +
	theme(
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
		strip.background = element_blank(),
		strip.text.y = element_text(size = 11),
		axis.text.x=element_text(size=10),
		legend.position=c(.75, .7),
		legend.title=element_text(size=9),
		legend.text = element_text(size=9),
		legend.key.size = unit(0.75, "line")
	)


gathered <- gather(cluster, parameter, variable, avg_mcc, avg_secs)

facet_labels <- as_labeller(c('avg_mcc' = "Mean Matthew's\nCorrelation Coefficient", 'avg_secs' = "Execution Time\n(seconds)"))

ggplot(gathered, aes(dataset, variable, col=dataset, shape=method)) +
	geom_point(position = position_dodge(0.1), size=2) +
	facet_grid(parameter~., scales = 'free_y', switch = 'y', labeller = facet_labels) +
	scale_x_discrete(breaks=levels(agg_test$dataset),
		labels=pretty_datasets[levels(agg_test$dataset)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=
		c('black', wes_palette("Darjeeling")), guide=F)+
	scale_shape_manual(name="Sequences initialized as", values=c(19,21), labels=pretty_methods) +
	expand_limits(y=c(0,1)) +
	xlab(NULL) + ylab(NULL) +
	my_theme +
	ggsave('results/figures/seeding.tiff', width=4.4, height=4.0, unit='in')
