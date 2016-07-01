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




NN_LIST = $(subst sm.dist,nn.list,$(SUB_SM_DIST))
FN_LIST = $(subst sm.dist,fn.list,$(SUB_SM_DIST))
AN_LIST = $(subst lg.dist,an.list,$(SUB_LG_DIST))
SPLIT5_8_LIST = $(subst fasta,split5_8.list,$(SUB_FASTA))
SPLIT5_1_LIST = $(subst fasta,split5_1.list,$(SUB_FASTA))


OTUCLUST_LIST = $(subst fasta,otuclust.list,$(SUB_FASTA))
SUMACLUST_LIST = $(subst fasta,sumaclust.list,$(SUB_FASTA))


.SECONDEXPANSION:
$(NN_LIST) : $$(subst .nn.list,.sm.dist, $$@) $$(subst nn.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	/usr/bin/time -o $(STATS) mothur "#cluster(column=$(DIST), count=$(COUNT), method=nearest)" > /dev/null
	$(eval TEMP=$(subst nn.list,sm.nn.unique_list.list,$@))
	mv $(TEMP) $@

.SECONDEXPANSION:
$(FN_LIST) : $$(subst .fn.list,.sm.dist, $$@) $$(subst fn.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	/usr/bin/time -o $(STATS) mothur "#cluster(column=$(DIST), count=$(COUNT), method=furthest)" > /dev/null
	$(eval TEMP=$(subst fn.list,sm.fn.unique_list.list,$@))
	mv $(TEMP) $@

.SECONDEXPANSION:
$(AN_LIST) : $$(subst .an.list,.lg.dist, $$@) $$(subst an.list,count_table, $$@)
	$(eval DIST=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	/usr/bin/time -o $(STATS) mothur "#cluster(column=$(DIST), count=$(COUNT), method=average)" > /dev/null
	$(eval TEMP=$(subst an.list,lg.an.unique_list.list,$@))
	mv $(TEMP) $@

.SECONDEXPANSION:
$(SPLIT5_8_LIST) : $$(subst .split5_8.list,.fasta, $$@) $$(subst .split5_8.list,.taxonomy, $$@) $$(subst split5_8.list,count_table, $$@)
	$(eval FASTA=$(word 1,$^))
	$(eval TAXONOMY=$(word 2,$^))
	$(eval COUNT=$(word 3,$^))
	$(eval STATS=$(subst list,stats, $@))
	/usr/bin/time -o $(STATS) mothur "#cluster.split(fasta=$(FASTA), count=$(COUNT), taxonomy=$(TAXONOMY), taxlevel=5, processors=8)" > /dev/null
	$(eval TEMP=$(subst split5_8.list,an.unique_list.list,$@))
	mv $(TEMP) $@

.SECONDEXPANSION:
$(SPLIT5_1_LIST) : $$(subst .split5_1.list,.fasta, $$@) $$(subst .split5_1.list,.taxonomy, $$@) $$(subst split5_1.list,count_table, $$@)
	$(eval FASTA=$(word 1,$^))
	$(eval TAXONOMY=$(word 2,$^))
	$(eval COUNT=$(word 3,$^))
	$(eval STATS=$(subst list,stats, $@))
	/usr/bin/time -o $(STATS) mothur "#cluster.split(fasta=$(FASTA), count=$(COUNT), taxonomy=$(TAXONOMY), taxlevel=5, processors=1)" > /dev/null
	$(eval TEMP=$(subst split5_1.list,an.unique_list.list,$@))
	mv $(TEMP) $@


.SECONDEXPANSION:
$(OTUCLUST_LIST) : $$(subst .otuclust.list,.fasta, $$@) $$(subst .otuclust.list,.count_table, $$@)
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TEMP_FASTA=$(subst fasta,otuclust.fasta,$(FASTA)))
	cp $(FASTA) $(TEMP_FASTA)
	mothur "#degap.seqs(fasta=$(TEMP_FASTA));deunique.seqs(fasta=current, count=$(COUNT))"
	$(eval RED_FASTA=$(subst fasta,ng.redundant.fasta,$(TEMP_FASTA)))
	/usr/bin/time -o $(STATS) ./code/run_otuclust.sh $(RED_FASTA)


.SECONDEXPANSION:
$(SUMACLUST_LIST) : $$(subst .sumaclust.list,.fasta, $$@) $$(subst .sumaclust.list,.count_table, $$@) code/run_sumaclust.sh code/run_sumaclust.R
	$(eval FASTA=$(word 1,$^))
	$(eval COUNT=$(word 2,$^))
	$(eval STATS=$(subst list,stats, $@))
	$(eval TEMP_FASTA=$(subst fasta,sumaclust.fasta,$(FASTA)))
	cp $(FASTA) $(TEMP_FASTA)
	mothur "#degap.seqs(fasta=$(TEMP_FASTA));deunique.seqs(fasta=current, count=$(COUNT))"
	$(eval NG_FASTA=$(subst fasta,ng.fasta,$(TEMP_FASTA)))
	$(eval RED_FASTA=$(subst fasta,ng.redundant.fasta,$(TEMP_FASTA)))
	/usr/bin/time -o $(STATS) ./code/run_sumaclust.sh $(RED_FASTA)
	rm $(TEMP_FASTA) $(RED_FASTA) $(NG_FASTA)
