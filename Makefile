REFS = data/references

print-%:
	@echo '$*=$($*)'


$(REFS)/silva.bact_archaea.% :
	wget -N -P $(REFS)/ http://www.mothur.org/w/images/b/be/Silva.nr_v123.tgz
	tar xvzf $(REFS)/Silva.nr_v123.tgz -C $(REFS)/;
	mothur "#get.lineage(fasta=$(REFS)/silva.nr_v123.align, taxonomy=$(REFS)/silva.nr_v123.tax, taxon=Bacteria-Archaea)";
	mv $(REFS)/silva.nr_v123.pick.align $(REFS)/silva.bact_archaea.align
	mv $(REFS)/silva.nr_v123.pick.tax $(REFS)/silva.bact_archaea.tax; \
	rm $(REFS)/README.Rmd $(REFS)/README.html
	rm $(REFS)/?ilva.nr_v123.*

$(REFS)/silva.bacteria.% : $(REFS)/silva.bact_archaea.align $(REFS)/silva.bact_archaea.tax
	mothur "#get.lineage(fasta=$(REFS)/silva.bact_archaea.align, taxonomy=$(REFS)/silva.bact_archaea.tax, taxon=Bacteria)";
	mv $(REFS)/silva.bact_archaea.pick.align $(REFS)/silva.bacteria.align
	mv $(REFS)/silva.bact_archaea.pick.tax $(REFS)/silva.bacteria.tax

$(REFS)/silva.v4.% : $(REFS)/silva.bacteria.align
	mothur "#pcr.seqs(fasta=$^, start=13862, end=23445, keepdots=F, processors=8);degap.seqs();unique.seqs()"
	cut -f 1 $(REFS)/silva.bacteria.pcr.ng.names > $(REFS)/silva.bacteria.pcr.ng.accnos
	mothur "#get.seqs(fasta=$(REFS)/silva.bacteria.pcr.align, accnos=$(REFS)/silva.bacteria.pcr.ng.accnos);screen.seqs(minlength=240, maxlength=275, maxambig=0, maxhomop=8, processors=8); filter.seqs(vertical=T)"
	mv $(REFS)/silva.bacteria.pcr.pick.good.filter.fasta $(REFS)/silva.v4.align
	grep "^>" $(REFS)/silva.v4.align | cut -c 2- > $(REFS)/silva.v4.accnos
	mothur "#get.seqs(taxonomy=$(REFS)/silva.bacteria.tax, accnos=$(REFS)/silva.v4.accnos)"
	mv data/references/silva.bacteria.pick.tax data/references/silva.v4.tax
	rm $(REFS)/silva.bacteria.pcr.*
	rm $(REFS)/silva.filter

$(REFS)/trainset14_032015.pds.% :
	mkdir -p $(REFS)/rdp
	wget -N -P $(REFS)/ http://www.mothur.org/w/images/8/88/Trainset14_032015.pds.tgz; \
	tar xvzf $(REFS)/Trainset14_032015.pds.tgz -C $(REFS)/rdp;\
	mv $(REFS)/rdp/trainset14_032015.pds/trainset14_032015.* $(REFS);\
	rm -rf $(REFS)/rdp $(REFS)/Trainset*


.SECONDEXPANSION:
data/%.fasta data/%.count_table data/%.taxonomy : code/$$(notdir $$*).batch code/$$(notdir $$*).R\
			$(REFS)/silva.v4.align\
			$(REFS)/trainset14_032015.pds.fasta\
			$(REFS)/trainset14_032015.pds.tax
	bash $<



SAMPLES = mice human soil sediment marine landfill even staggered
FRACTIONS = 0_2 0_4 0_6 0_8 1_0
REPLICATE = 01 02 03 04 05 06 07 08 09 10
DATAPATH = $(foreach S,$(SAMPLES),$(foreach F,$(FRACTIONS), $(foreach R, $(REPLICATE), data/$S/$S.$F.$R)))
SUB_FASTA = $(foreach D,$(DATAPATH),$D.fasta)
SUB_TAX = $(foreach D,$(DATAPATH),$D.taxonomy)
SUB_COUNT = $(foreach D,$(DATAPATH),$D.count_table)
SUB_FILES = $(SUB_FASTA) $(SUB_TAX) $(SUB_COUNT)


.SECONDEXPANSION:
$(SUB_FILES) : code/subsample.R $$(basename $$(basename $$(basename $$@))).fasta $$(basename $$(basename $$(basename $$@))).taxonomy $$(basename $$(basename $$(basename $$@))).count_table
	@echo $^
	$(eval SAMPLE=$(basename $(basename $(basename $(notdir $@)))))
	$(eval REP=$(subst .,,$(suffix $(basename $@))))
	$(eval FRAC=$(subst .,,$(suffix $(basename $(basename $@)))))
	@echo $(FRAC)
	@echo $(REP)
	R -e "source('code/subsample.R'); subsample('$(SAMPLE)', '$(FRAC)', '$(REP)')"

SUB_SM_DIST = $(subst fasta,sm.dist,$(SUB_FASTA))
$(SUB_SM_DIST) : $$(subst sm.dist,fasta,$$@)
	mothur "#dist.seqs(fasta=$^, cutoff=0.03, processors=8)"
	$(eval FULL_NAME=$(subst sm.dist,dist,$@))
	mv $(FULL_NAME) $@ 

SUB_LG_DIST = $(subst fasta,lg.dist,$(SUB_FASTA))
$(SUB_LG_DIST) : $$(subst lg.dist,fasta,$$@)
	mothur "#dist.seqs(fasta=$^, cutoff=0.15, processors=8)"
	$(eval FULL_NAME=$(subst lg.dist,dist,$@))
	mv $(FULL_NAME) $@
