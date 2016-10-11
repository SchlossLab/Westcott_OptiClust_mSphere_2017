#devtools::install_github("hadley/ggplot2")
#devtools::install_github("hadley/scales")
#devtools::install_github("wilkelab/cowplot")
library(dplyr, warn.conflicts=F)
library(tidyr, warn.conflicts=F)
library(ggplot2, warn.conflicts=F)
library(cowplot, warn.conflicts=F)
library(wesanderson, warn.conflicts=F)

methods <- c("an", "vdgc", "mcc")
pretty_methods <- c('Average Neighbor', 'DGC with VSEARCH', 'OptiClust')
names(pretty_methods) <- methods

datasets <- c('soil', 'marine', 'mice', 'human')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human")
names(pretty_datasets) <- datasets

metrics <- c("mcc", "num_otus", "cluster_secs")
pretty_metrics <- c("Matthew's\nCorrelation Coefficient", "Number of OTUs", "Time to Cluster\n(seconds)")
names(pretty_metrics) <- metrics

full_data <- read.table(file="data/processed/cluster_data.summary", header=T, stringsAsFactors=FALSE)

full_data$method <- gsub("^mcc$", "mcc_split1_8", full_data$method)
full_data$method <- gsub("^vdgc_1$", "vdgc_split1_8", full_data$method)
full_data$method <- gsub("^an$", "an_split1_8", full_data$method)

split_data <- full_data %>%
				filter(
						grepl("split", method) | method %in% c('mcc_split1_8',
									'vdgc_split1_8', 'an_split1_8'),
						frac==1.0,
						dataset==datasets
				) %>%
				select(dataset, method, cluster_secs, mcc, num_otus) %>%
				separate(method, into=c("method", "split", "processors"), sep="_") %>%
				mutate(tax_level=as.numeric(gsub("split", "", split))) %>%
				select(-split, -processors) %>%
				gather(metric, value, cluster_secs, mcc, num_otus) %>%
				group_by(dataset, method, metric, tax_level) %>%
				summarize(
					avg=if(sum(!is.na(value))>0){mean(value, na.rm=TRUE)}	else { NA },
					min=if(sum(!is.na(value))>0){min(value, na.rm=TRUE)}	else { NA },
					max=if(sum(!is.na(value))>0){max(value, na.rm=TRUE)}	else { NA }
				)

taxon_level_names <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus")

split_data$dataset <- factor(split_data$dataset, levels=c("soil", "marine", "mice", "human"))

my_theme <- theme_classic() +
	theme(
		axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5, size=7, margin=margin(t=3,0,0,0)),

		axis.text.y=element_text(size=7, margin=margin(r=2,0,0,0)),

		axis.title.y=element_text(size=7),
		axis.title.x=element_blank(),

		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.spacing = unit(0.5, "lines"),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
		strip.background = element_blank(),
		strip.text.y = element_blank(),

		legend.position=c(0.75, 0.8),
		legend.text = element_text(size=7),
		legend.key.size = unit(0.55, "line"),
 		legend.key = element_rect(fill = NA, linetype=0),
		legend.title=element_text(lineheight=-1),
		legend.background = element_rect(fill="white", color="black"),
		legend.margin = margin(t=0,4,4,4)
	)

figure <- split_data %>% filter(metric == "mcc") %>%
	ggplot(aes(x=tax_level, y=avg, color=dataset, shape=method)) +
		facet_grid(dataset ~ ., scales="free_y") +
		geom_point() +
		geom_line() +
		scale_x_discrete(
			aes(breaks=tax_level),
			labels=taxon_level_names,
			limits=1:6
		) +
		expand_limits(y=c(0,1)) +
		scale_color_manual(
			breaks=datasets,
			values=c('black', wes_palette("Darjeeling")[1:3]),
			name=NULL,
			guide=FALSE
		) +
		scale_shape_manual(
			breaks=methods,
			labels=pretty_methods,
			values = c(15,16,17),
			name=NULL
		) +
		ylab("Matthew's Correlation Coefficient") +
		my_theme


ggdraw() +
	draw_plot(figure,  x=0, y=0, 1.0, 1) +
	draw_plot_label(pretty_datasets, x=rep(0.15,4), y=c(0.825,0.6,0.375,0.15), size=10, hjust=0) +
	ggsave("results/figures/split_mcc.tiff", width=3.5, height=5.0, unit="in")
