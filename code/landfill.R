library(openxlsx)

get_oligos_file <- function(){
	metadata <- read.xlsx('data/landfill/landfill.xlsx')
	metadata <- metadata[!is.na(metadata$Barcode.Sequence),]

	barcode <- metadata$Barcode.Sequence
	for_primer <- metadata$"Linker/Primer.Sequence"
	rev_primer <- metadata$Reverse.Primer.Sequence
	sample <- paste(metadata$Sample, metadata$Replicate, sep="_")

	forward <- cbind("forward", unique(for_primer), "")
	reverse <- cbind("reverse", unique(rev_primer), "")
	barcodes <- cbind("barcode", barcode, sample)

	oligos <- rbind(forward, reverse, barcodes)

	write.table(oligos, file="data/landfill/landfill.oligos", quote=F,
 							row.names=F, col.names=F, sep='\t')
}
