#!/usr/bin/env nextflow

params.reads = 'data/sample.fastq'
params.adapt = 'data/adapters.fasta'
params.mode = 'ion'

sequences = file(params.reads)
adapters = file(params.adapt)

process adapter_trimming {
    input:
    file input from sequences
    file 'adapters.fasta' from adapters

    output:
    file "${input.baseName}_adapt" into adapt_trimmed

    script:
	if( params.mode == 'illumina' )
		"""
		scythe -q sanger -a adapters.fasta -o "${input.baseName}_adapt" $input
		"""
	else if( params.mode == 'ion' )
        """
        cp input.fastq adapt_trimmed.fastq
        """
    else
        error "Invalid alignment mode: ${params.mode}"

}

process quality_trimming {
    input:
    file input from adapt_trimmed

    output:
    file "${input.baseName}_trimmed" into trimmed

    """
    sickle se -f $input -t sanger -o "${input.baseName}_trimmed" -q 20
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
    Nonpareil.curve('nonpareil.npo')
    """
}
