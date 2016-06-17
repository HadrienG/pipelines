#!/usr/bin/env nextflow

params.reads = 'data/sample.fastq'
params.adapt = 'data/adapters.fasta'

sequences = file(params.reads)
adapters = file(params.adapt)

process adapter_trimming {
    time = '1h'

    input:
    file 'input.fastq' from sequences
    file 'adapters.fasta' from adapters

    output:
    file 'adapt_trimmed.fastq' into adapt_trimmed

    script:
	if(params.adapt == '.*fasta')
		"""
		scythe -q sanger -a adapters.fasta -o adapt_trimmed.fastq input.fastq
		"""
	else
        """
        cp input.fastq adapt_trimmed.fastq
        """

}

process quality_trimming {
    time = '1h'

    input:
    file 'adapt_trimmed.fastq' from adapt_trimmed

    output:
    file 'trimmed.fastq' into trimmed

    """
    sickle se -f adapt_trimmed.fastq -t sanger -o trimmed.fastq -q 20
    """
}

process nonpareil {
    time = '2h'

    input:
    file 'trimmed.fastq' from trimmed

    output:
    file 'nonpareil.npo' into nonpareil

    """
    nonpareil -f fastq -s trimmed.fastq -b nonpareil -t 12
    """
}

process curves {
    time = '1h'
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
