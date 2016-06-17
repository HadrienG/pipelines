#!/usr/bin/env nextflow

params.reads = 'data/sample.fastq'
params.adapt = 'data/adapters.fasta'
params.mode = 'ion'

sequences = file(params.reads)
adapters = file(params.adapt)

process adapter_trimming {
    input:
    file 'input.fastq' from sequences
    file 'adapters.fasta' from adapters

    output:
    file 'adapt_trimmed.fastq' into adapt_trimmed

    script:
	if( params.mode == 'illumina' )
		"""
		scythe -q sanger -a adapters.fasta -o adapt_trimmed.fastq input.fastq
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
    file 'adapt_trimmed.fastq' from adapt_trimmed

    output:
    file 'trimmed.fastq' into trimmed

    """
    sickle se -f adapt_trimmed.fastq -t sanger -o trimmed.fastq -q 20
    """
}

process nonpareil {
    input:
    file 'trimmed.fastq' from trimmed

    output:
    file 'nonpareil.npo' into nonpareil

    """
    nonpareil -f fastq -s trimmed.fastq -b nonpareil -t 12
    """
}

process curves {
    publishDir 'results'

    input:
    file 'nonpareil.npo' from nonpareil

	output:
	file 'Rplots.pdf' into plot

    """
    #!/usr/bin/env Rscript
    library(Nonpareil)
    Nonpareil.curve('nonpareil.npo')
    """
}
