#devtools::install_github("hadley/ggplot2")
#devtools::install_github("hadley/scales")
#devtools::install_github("wilkelab/cowplot")
library(dplyr, warn.conflicts=F)
library(tidyr, warn.conflicts=F)
library(ggplot2, warn.conflicts=F)
library(cowplot, warn.conflicts=F)
library(wesanderson, warn.conflicts=F)

basic_methods <- c('accuracy', 'f1score', 'fpfn', 'mcc', 'npv', 'opti_fn', 'sens', 'tp', 'tptn')

pretty_methods <- c('Accuracy\n(max.)', 'F1-score\n(max.)', 'False Positives +\nFalse Negatives\n(min.)',
										"Matthew's Correlation\nCoefficient (max.)",
										"Negative\nPredictive\nValue (max.)", "False Negatives\n(min.)", "Sensitivity\n(max.)",
 										"True Positives\n(max.)", "True Positives +\nTrue Negatives (max.)")

names(pretty_methods) <- basic_methods

datasets <- c('soil', 'marine', 'mice', 'human', 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human", "Even", "Staggered")
names(pretty_datasets) <- datasets

metrics <- c("mcc", "num_otus", "cluster_secs")
pretty_metrics <- c("Matthew's\nCorrelation Coefficient", "Number of OTUs", "Time to Cluster\n(seconds)")
names(pretty_metrics) <- metrics


full_data <- read.table(file="data/processed/cluster_data.summary", header=T, stringsAsFactors=F)

full_tidy <- full_data %>%
						filter(method %in% basic_methods, frac==1.0) %>%
						select(dataset, method, mcc, num_otus, cluster_secs) %>%
						gather(metric, value, mcc, num_otus, cluster_secs) %>%
						group_by(dataset, method, metric) %>%
						summarize(avg=mean(value, na.rm=T),
											min=min(value, na.rm=T),
											max=max(value, na.rm=T))

method_ordering <- full_tidy %>%
			filter(metric=='mcc') %>%
			group_by(method) %>%
			summarize(avg_mcc=mean(avg, na.rm=T)) %>%
			arrange(desc(avg_mcc))

full_tidy$method <- factor(full_tidy$method, method_ordering$method)
full_tidy$dataset <- factor(full_tidy$dataset, datasets)
full_tidy$metric <- factor(full_tidy$metric, metrics)

my_theme <- theme_classic() +
	theme(
		axis.text.x = element_blank(),#(angle = 90, hjust = 1, vjust=0.5, size=7),
		axis.text.y=element_text(size=7, margin=margin(0,0,0,0)),
		axis.title.y=element_text(size=7),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
		legend.position = "none"
	)


alpha <- 0.3
mcc <- full_tidy %>% filter(metric == "mcc") %>%
	ggplot(aes(method, avg, col=dataset, shape=dataset))+
	geom_hline(yintercept = seq(0,1,0.25), colour = "gray", size=0.15) +
	geom_point(position = position_dodge(0.7), size=2) +
	geom_errorbar(position = position_dodge(0.7), aes(ymin=min, ymax=max), width=0.2) +
	expand_limits(y=c(0,1)) +
	geom_vline(xintercept=0.5 + (1:(length(levels(full_tidy$method))-1))) +
	scale_x_discrete(breaks=levels(full_tidy$method), labels=pretty_methods[levels(full_tidy$method)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=c('black', wes_palette("Darjeeling")), name=NULL)+
	scale_shape_manual(breaks=datasets, labels=pretty_datasets,	values = rep(16,6), name=NULL,	guide = guide_legend(override.aes = list(linetype = "blank")))+
	xlab(NULL) + ylab(pretty_metrics[1]) +
	my_theme

sobs <- full_tidy %>% filter(metric == "num_otus") %>%
	ggplot(aes(method, avg, col=dataset, shape=dataset))+
	geom_hline(yintercept = seq(0,1e5,2.5e4), colour = "gray", size=0.15) +

	geom_point(position = position_dodge(0.7), size=2) +
	geom_errorbar(position = position_dodge(0.7), aes(ymin=min, ymax=max), width=0.2) +
	expand_limits(y=c(0,1)) +
	geom_vline(xintercept=0.5 + (1:(length(levels(full_tidy$method))-1))) +
	scale_x_discrete(breaks=levels(full_tidy$method), labels=pretty_methods[levels(full_tidy$method)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=c('black', wes_palette("Darjeeling")), name=NULL)+
	scale_shape_manual(breaks=datasets, labels=pretty_datasets,	values = rep(16,6), name=NULL,	guide = guide_legend(override.aes = list(linetype = "blank")))+
	xlab(NULL) + ylab(pretty_metrics[2]) +
	my_theme

secs <- full_tidy %>% filter(metric == "cluster_secs") %>%
	ggplot(aes(method, avg, col=dataset, shape=dataset))+
	geom_hline(yintercept = c(1,100,10000), colour = "gray", size=0.15) +

	geom_point(position = position_dodge(0.7), size=2) +
	geom_errorbar(position = position_dodge(0.7), aes(ymin=min, ymax=max), width=0.2) +
	scale_y_log10() +
	# expand_limits(y=c(0,1)) +
	geom_vline(xintercept=0.5 + (1:(length(levels(full_tidy$method))-1))) +
	scale_x_discrete(breaks=levels(full_tidy$method), labels=pretty_methods[levels(full_tidy$method)]) +
	scale_color_manual(breaks=datasets, labels=pretty_datasets, values=c('black', wes_palette("Darjeeling")), name=NULL)+
	scale_shape_manual(breaks=datasets, labels=pretty_datasets,	values = rep(16,6), name=NULL,	guide = guide_legend(override.aes = list(linetype = "blank")))+
	xlab(NULL) + ylab(pretty_metrics[3]) +
	my_theme +
	theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, size=7, margin=margin(t=1,0,0,0)))



my_legend <- theme(
		legend.text = element_text(size=7),
		legend.key.size = unit(0.55, "line"),
 		legend.key = element_rect(fill = NA, linetype=0),
		legend.position=c(.65, 1.0),
		legend.title=element_text(lineheight=-1),
		legend.background = element_rect(fill="white", color="black"),
		legend.margin = margin(t=0,4,4,4)
	)


ggdraw() +
	draw_plot(mcc + theme(axis.title.y=element_text(margin=margin(r=13,l=0,t=0,b=0))),x=0,y=0.725,width=1,height=0.275) +
	draw_plot(sobs + theme(axis.title.y=element_text(margin=margin(r=11,l=0,t=0,b=0))) + my_legend,x=0,y=0.45,1,0.275) +
	draw_plot(secs,x=0,y=0.0,1,0.45) +
	draw_plot_label(c("A", "B", "C"), x=c(0,0,0), y=c(1.00,0.735,0.46), size=12) +
	ggsave('results/figures/performance_other.tiff', width=6.875, height=5.5, unit='in') +
	ggsave('results/figures/performance_other.png', width=6.875, height=5.5, unit='in')
