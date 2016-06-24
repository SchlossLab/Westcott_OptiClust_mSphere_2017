REFS = data/references/



#get the silva reference alignment
$(REFS)silva.bacteria.align :
	wget -N -P $(REFS) http://www.mothur.org/w/images/b/be/Silva.nr_v123.tgz
	tar xvzf $(REFS)Silva.nr_v123.tgz -C $(REFS);
	mothur "#get.lineage(fasta=$(REFS)silva.nr_v123.align, taxonomy=$(REFS)silva.nr_v123.tax, taxon=Bacteria)";
	mv $(REFS)silva.nr_v123.pick.align $(REFS)silva.bacteria.align
	rm $(REFS)README.*
	rm $(REFS)silva.nr_v123.*

$(REFS)silva.bact_archaea.align : $(REFS)silva.bacteria.align
	wget -N -P $(REFS) http:/www.mothur.org/w/images/2/27/Silva.nr_v123.tgz
	tar xvzf $(REFS)Silva.nr_v123.tgz -C $(REFS);
	mothur "#get.lineage(fasta=$(REFS)silva.nr_v123.align, taxonomy=$(REFS)silva.nr_v123.tax, taxon=Archaea)";
	cp $(REFS)silva.bacteria.align $(REFS)silva.bact_archaea.align;
	cat $(REFS)silva.nr_v123.pick.align >> $(REFS)silva.bact_archaea.align
	rm $(REFS)README.*
	rm $(REFS)silva.nr_v123.*

$(REFS)silva.v4.align : $(REFS)silva.bacteria.align
	mothur "#pcr.seqs(fasta=$^, start=13862, end=23445, keepdots=F, processors=8);degap.seqs();unique.seqs()"
	cut -f 1 $(REFS)silva.bacteria.pcr.ng.names > $(REFS)silva.bacteria.pcr.ng.accnos
	mothur "#get.seqs(fasta=$(REFS)silva.bacteria.pcr.align, accnos=$(REFS)silva.bacteria.pcr.ng.accnos);screen.seqs(minlength=240, maxlength=275, maxambig=0, maxhomop=8, processors=8); filter.seqs(vertical=T)"
	mv $(REFS)silva.bacteria.pcr.pick.good.filter.fasta $@
	rm $(REFS)silva.bacteria.*
	rm $(REFS)silva.filter

#get the rdp training set data
$(REFS)trainset14_032015.pds.% :
	wget -N -P $(REFS) http://www.mothur.org/w/images/8/88/Trainset14_032015.pds.tgz; \
	tar xvzf $(REFS)Trainset14_032015.pds.tgz -C $(REFS);\
	mv $(REFS)trainset14_032015.pds/trainset14_032015.* $(REFS);\
	rm -rf $(REFS)trainset14_032015.pds
