library(dplyr)
library(ggplot2)
library(wesanderson)

get_steps_data <- function(dataset, rep, fraction="1_0"){

	steps_file_name <- paste0("data/", dataset, "/", dataset, ".", fraction, ".", rep, ".mcc.steps")
	read.table(file=steps_file_name, stringsAsFactors=FALSE, header=T) %>%
						select(iter, mcc) %>%
						filter(iter != 0) %>%
						mutate(dataset=dataset, replicate=rep)

}


datasets <- c('soil', 'marine', 'mice', 'human', 'even', 'staggered')
pretty_datasets <- c("Soil", "Marine", "Mice", "Human", "Even", "Staggered")
names(pretty_datasets) <- datasets

libraries <- rep(datasets, each=10)
reps <- rep(c(paste0('0', 1:9), '10'), length.out=length(libraries))


all_step_data <- data.frame()

for(i in 1:length(libraries)){
	new_step_data <- get_steps_data(dataset=libraries[i], rep=reps[i])
	all_step_data <- rbind(all_step_data, new_step_data)
}

#write.table(all_step_data, file="test.tsv", row.names=FALSE)
#all_step_data <- read.table(file="test.tsv", header=T, stringsAsFactors=F)
#all_step_data$dataset <- factor(all_step_data$dataset, levels=datasets)

my_theme <- theme_classic() +
	theme(
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_rect(color = "black", fill=NA, size=1),
		panel.background = element_rect(fill=NA),
		axis.text.y=element_text(size=5),
		axis.title.y=element_text(size=7),
		axis.text.x=element_text(size=5),
		axis.title.x=element_text(size=7),
		legend.text = element_text(size=5),
		legend.margin = margin(t=0,0,0,0),
		legend.key.height=unit(0.5,"line"),
		legend.key.width=unit(1,"line")
	)



all_step_data %>%
	ggplot(aes(x=iter, y=mcc, color=dataset, group=interaction(dataset, replicate))) +
	geom_line() +
	scale_color_manual(breaks=levels(all_step_data$dataset), labels=pretty_datasets[levels(all_step_data$dataset)],
											values=c('black', wes_palette("Darjeeling")), name=NULL) +
	xlab("Number of Iterations") + ylab("Matthew's\nCorrelation Coefficient") +
	expand_limits(y=c(0.7,0.9), x=c(0,17)) +
	scale_x_continuous(breaks=c(0,5,10,15,20), labels=c(0,5,10,15,20)) +
	my_theme +
	ggsave("results/figures/optimization.tiff", width=3.5, height=3.5, unit='in') +
	ggsave("results/figures/optimization.png", width=3.5, height=3.5, unit='in')
