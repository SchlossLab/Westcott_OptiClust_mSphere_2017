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
    |  |- raw/         # raw data, will not be altered
    |  |- he/	       # direct replication of He et al. analysis
    |  |- schloss/     # how I would have processed Canadian soil data
    |  |- miseq/       # analysis of murine MiSeq data
    |  |- gg_13_8/     # analysis of QIIME reference database
    |  |- rand_ref/    # analysis of murine MiSeq data with randomized database
    |  +- process/     # cleaned data, will not be altered once created;
    |                  # will be committed to repo
    |
    |- code/           # any programmatic code
    |
    |- results         # all output from workflows and analyses
    |  |- figures/     # graphs, likely designated for manuscript figures
    |
    |- scratch/        # temporary files that can be safely deleted or lost
    |
	|- submission/	   # files used to write, submit, and publish paper
	|  |- header.tex      # LaTeX header file for formatting paper
	|  |- Westcott_OptiClust_PeerJ_2015.Rmd # executable Rmarkdown for this study
	|  |- Westcott_OptiClust_PeerJ_2015.md  # Markdown (GitHub) version of the *Rmd file
	|  |- Westcott_OptiClust_PeerJ_2015.pdf # PDF version of *.Rmd file
	|  |- peerj.csl       # CSL file for formatting bibliograph using PeerJ's format
	|  + references.bib  # bibtex formatted file of references
	|  
	|
    |- Makefile        # executable Makefile for this study
    |
    +- LICENSE.md



Dependencies
------------
The following need to be installed and in the path...
* mothur (v.1.37.0)
* QIIME (v.1.9.1)
* UCLUST (v.6.1.544)
* VSEARCH (v.1.5.0)
* micca (OTUClust)
* R
    + jsonlite
    + knitr
    + Rcpp
    + plyr
    + ggplot2



These should be installed the specified folders
* vsearch (v.1.5.0 installed in code/vsearch)
* sumaclust (v.1.0.20 installed in code/sumaclust_v1.0.20)
* swarm (v.2.1.1 installed in code/swarm)
* NINJA-OPS (v.1.5.0 installed in code/NINJA-OPS
