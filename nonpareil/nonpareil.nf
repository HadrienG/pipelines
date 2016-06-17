#!/usr/bin/env nextflow

params.reads = 'data/ERR1135746.fastq'
params.adapt = 'data/adapters.fasta'
params.mode = 'illumina'

sequences = file(params.reads)
adapters = file(params.adapt)

process adapter_trimming {
    input:
    file input from sequences
    file 'adapters.fasta' from adapters

    output:
    file "${input.baseName}.adapt" into adapt_trimmed

    script:
	if( params.mode == 'illumina' )
		"""
		scythe -q sanger -a adapters.fasta -o "${input.baseName}.adapt" $input
		"""
	else if( params.mode == 'ion' )
        """
        cp $input "${input.baseName}.adapt"
        """
    else
        error "Invalid alignment mode: ${params.mode}"

}

process quality_trimming {
    input:
    file input from adapt_trimmed

    output:
    file "${input.baseName}.trimmed" into trimmed

    """
    sickle se -f $input -t sanger -o "${input.baseName}.trimmed" -q 20
    """
}

process nonpareil {
    input:
    file input from trimmed

    output:
    file "${input.baseName}.npo" into nonpareil

    """
    nonpareil -f fastq -s $input -b "${input.baseName}" -t 12
    """
}

process curves {
    publishDir 'results'

    input:
    file input from nonpareil

	output:
	file "${input.baseName}.pdf" into plot

    """
    #!/usr/bin/env Rscript
    library(Nonpareil)
    pdf("${input.baseName}.pdf")
    Nonpareil.curve('$input')
    dev.off()
    """
}
