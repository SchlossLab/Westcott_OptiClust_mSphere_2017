OptiClust: Improved method for assigning amplicon-based sequence data to operational taxonomic units
=======

Assignment of 16S rRNA gene sequences to operational taxonomic units (OTUs) is a computational bottleneck in the process of analyzing microbial communities. Although this has been an active area of research, it has been difficult to overcome the time and memory demands while improving the quality of the OTU assignments. Here we developed a new OTU assignment algorithm that iteratively reassigns sequences to new OTUs to optimize the Matthews correlation coefficient (MCC), a measure of the quality of OTU assignments. To assess the new algorithm, OptiClust, we compared it to ten other algorithms using 16S rRNA gene sequences from two simulated and four natural communities. Using the OptiClust algorithm, the MCC values averaged 15.2 and 16.5% higher than the OTUs generated when we used the average neighbor and distance-based greedy clustering with VSEARCH, respectively. Furthermore, on average, OptiClust was 94.6-times faster than the average neighbor algorithm and just as fast as distance-based greedy clustering with VSEARCH. An empirical analysis of the efficiency of the algorithms showed that the time and memory required to perform the algorithm scaled quadratically with the number of unique sequences in the dataset. The significant improvement in the quality of the OTU assignments over previously existing methods will significantly enhance downstream analysis by limiting the splitting of similar sequences into separate OTUs and merging of dissimilar sequences into the same OTU. The development of the OptiClust algorithm represents a significant advance that is likely to have numerous other applications.



Overview
--------

	  project
	  |- README          # the top level description of content
	  |
	  |- data            # raw and primary data, are not changed once created
	  |  |- references/  # reference files to be used in analysis
	  |  |- even/        # clustering of even dataset
	  |  |- staggered/   # clustering of staggered dataset
	  |  |- human/       # clustering of human dataset
	  |  |- mice/        # clustering of murine dataset
	  |  |- soil/        # clustering of soil dataset
	  |  |- marine/      # clustering of marine dataset
	  |  +- processed/   # cleaned data, will not be altered once created;
	  |                  # will be committed to repo
	  |
	  |- code/           # any programmatic code
	  |
	  |- results         # all output from workflows and analyses
	  |  +- figures/     # graphs, likely designated for manuscript figures
	  |
	  |- scratch/        # temporary files that can be safely deleted or lost
	  |
	  |- submission/	   # files used to write, submit, and publish paper
	  |  |- header.tex      # LaTeX header file for formatting paper
	  |  |- supplemental_text.Rmd  # worked example of algorithm with toy dataset
	  |  |- supplemental_text.pdf  # worked example of algorithm with toy dataset
	  |  |- Westcott_Opticlust_mSystems_2016.Rmd # executable Rmarkdown for this study
	  |  |- Westcott_Opticlust_mSystems_2016.md  # Markdown (GitHub) version of the *Rmd file
	  |  |- Westcott_Opticlust_mSystems_2016.pdf # PDF version of *.Rmd file
	  |  |- msystems.csl       # CSL file for formatting bibliograph using PeerJ's format
	  |  + references.bib  # bibtex formatted file of references
	  |  
	  |
	  |- Makefile        # executable Makefile for this study
	  |
	  +- LICENSE.md



Dependencies
------------
The following need to be installed and in the path...
* mothur (v.1.38.0; Opticluster branch - to be merged into mothur v.1.39.0)
* QIIME (v.1.9.1)
* USEARCH (v.6.1)
* VSEARCH (v.2.3.3)
* swarm (v.2.1.9)
* SumaClust (v.1.0.20)
* micca (OTUClust v.0.1) - comes with QIIME
* R (v.3.3.2)
    + knitr / rmarkdown
    + dplyr (v.0.5.0)
    + tidyr (v.0.6.0)
    + cowplot (v.0.6.9990)
    + ggplot2 (v.2.1.0.9001)
    + wesanderson (v.0.3.2)
* make


These should be installed the specified folders
* mothur - installed in the PATH
* vsearch - installed in the PATH
* usearch - installed in the PATH
* sumaclust - installed in code/sumaclust_v1.0.20
* swarm - installed in code/swarm



Build paper
-----------

    $ make write.paper

That will build the files that were submitted to *mSystems*. Honestly, running that command is probably a really bad idea since it will take a very long time. You likely want to build each target separately by firing off each target on a separate node on a high performance computer cluster to better parallelize the process.


Datasets used in this study include
-----------------------------------
* [seawater](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4894692/)
* [soil](https://www.ncbi.nlm.nih.gov/pubmed/27199914)
* [human](https://www.ncbi.nlm.nih.gov/pubmed/27056827)
* [mice](https://www.ncbi.nlm.nih.gov/pubmed/23793624)
