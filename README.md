README
=======

ABSTRACT GOES HERE


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
* mothur (v.1.38.0; Opticluster branch)
* QIIME (v.1.9.1)
* UCLUST (v.6.1.544)
* VSEARCH (v.1.5.0)
* swarm (v.2.1.1)
* micca (OTUClust) - comes with QIIME
* R
    + knitr
    + dplyr
    + ggplot2
    + wesanderson
* make



These should be installed the specified folders
* vsearch (v.1.5.0 installed in code/vsearch)
* sumaclust (v.1.0.20 installed in code/sumaclust_v1.0.20)
* swarm (v.2.1.1 installed in code/swarm)



Build paper
-----------

    $ make write.paper

That will build the files that were submitted to *mSystems*. Honestly, that is probably a really bad idea. You likely want to build each target separately by firing off each target on a separate node on a high performance computer cluster.


Datasets used in this study include
-----------------------------------
* [seawater](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4894692/)
* [soil](https://www.ncbi.nlm.nih.gov/pubmed/27199914)
* [human](https://www.ncbi.nlm.nih.gov/pubmed/27056827)
* [mice](https://www.ncbi.nlm.nih.gov/pubmed/23793624)
