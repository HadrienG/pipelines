#!/usr/bin/env nextflow

params.in = "../test/1P.fastq"
params.adapt = "../test/adapters.fa"

sequences = file(params.in)
adapters = file(params.adapt)

// only do that process if option adapters
process adapter_trimming {
	input:
	file 'input.fastq' from sequences
    file adapters

	output:
	file 'adapt_trimmed.fastq' into adapt_trimmed

	"""
	scythe -q sanger -a adapters -o adapt_trimmed.fastq input.fastq
	"""
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
    nonpareil -s trimmed.fasta -b nonpareil
    """
}

process curves {
    input:
    file 'nonpareil.npo' from nonpareil

    """
    #!/usr/bin/env Rscript
    library(Nonpareil)
    Nonpareil.curve('nonpareil.npo')
    """
}
