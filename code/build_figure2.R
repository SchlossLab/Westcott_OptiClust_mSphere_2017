library(dplyr)
library(ggplot2)
library(cowplot)


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
			mutate(cov_mcc=sd_mcc/avg_mcc) %>%
			print(n=nrow(.))

method_ordering <- data %>%
			filter(frac==1.0 & method %in% basic_methods) %>%
			group_by(method) %>%
			summarize(avg_mcc=mean(mcc, na.rm=T)) %>%
			arrange(desc(avg_mcc))

subset$method <- factor(subset$method, ordering$method)
subset$dataset <- factor(subset$dataset, datasets)

mcc <- ggplot(subset, aes(method, avg_mcc, col=dataset, shape=dataset)) +
	geom_point(position = position_dodge(0.5), size=2) +
	coord_cartesian(ylim=c(0,1)) +
	ylab("Mean Matthew's\nCorrelation Coefficient") +
	xlab(NULL) +
	scale_color_discrete(breaks=datasets, labels=pretty_datasets)+
	scale_shape_manual(breaks=datasets, labels=pretty_datasets,
						guide=guide_legend(override.aes=aes(size=2)),
						values = c(15, 16, 17, 21, 22, 23)) +
	# scale_x_discrete(breaks=levels(subset$method),
	# 				labels=pretty_methods[levels(subset$method)]) +
	theme(axis.text.x =element_blank(),legend.position="none")


cov <- ggplot(subset, aes(method, cov_mcc, col=dataset, shape=dataset)) +
	geom_point(position = position_dodge(0.5), size=2) +
	coord_cartesian(ylim=c(0,0.04)) +
	ylab("Coefficient of Variation for\nMatthew's Correlation Coefficient") +
	xlab(NULL) +
	scale_color_discrete(breaks=datasets, labels=pretty_datasets)+
	scale_shape_manual(breaks=datasets, labels=pretty_datasets,
						guide=guide_legend(override.aes=aes(size=2)),
						values = c(15, 16, 17, 21, 22, 23)) +
	# scale_x_discrete(breaks=levels(subset$method),
	# 				labels=pretty_methods[levels(subset$method)]) +
	theme(axis.text.x =element_blank(),legend.position="none")

sobs <- ggplot(subset, aes(method, avg_sobs, col=dataset, shape=dataset)) +
	geom_point(position = position_dodge(0.5), size=2) +
#	coord_cartesian(ylim=c(0,1e5)) +
	ylab("Mean Number of OTUs") +
	xlab(NULL) +
	scale_color_discrete(breaks=datasets, labels=pretty_datasets)+
	scale_shape_manual(breaks=datasets, labels=pretty_datasets,
						guide=guide_legend(override.aes=aes(size=2)),
						values = c(15, 16, 17, 21, 22, 23)) +
	# scale_x_discrete(breaks=levels(subset$method),
	# 				labels=pretty_methods[levels(subset$method)]) +
	theme(axis.text.x =element_blank(),legend.position="none")

my_legend <- theme(
	legend.title=element_blank(),
	legend.position = c(0.085, 0.25),
	legend.text = element_text(size = 8),
	legend.key.height=unit(0.7,"line"),
	legend.key = element_rect(fill = NA),
	legend.margin = unit(0,"line")
)

ggdraw() +
	draw_plot(mcc + my_legend, 0,0.70,1,0.3) +
	draw_plot(cov, 0,0.40,1,0.3) +
	draw_plot(sobs, 0,0.10,1,0.3) +
	theme(
	#	axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, size=8),
		axis.title=element_text(size=10),
		panel.grid.major.y = element_blank(),
		panel.grid.minor.y = element_blank(),
		panel.grid.major.x = element_line(colour = "gray",size=0.5),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA)
	)
