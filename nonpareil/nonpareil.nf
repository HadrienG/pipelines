#!/usr/bin/env nextflow

params {
	in = "../data/sample.fastq"
	adapt = ""
}

params.in = "../test/1P.fastq"
params.adapt = "../test/adapters.fasta"

sequences = file(params.in)
adapters = file(params.adapt)

// should add condition of ion or illumina instead
process adapter_trimming {
	if (params.adapt =~ ".*fasta") {
		input:
		file 'input.fastq' from sequences
	    file 'adapters.fasta' from adapters

		output:
		file 'adapt_trimmed.fastq' into adapt_trimmed

		"""
		scythe -q sanger -a adapters.fasta -o adapt_trimmed.fastq input.fastq
		"""
	}
}

process quality_trimming {
	if (params.adapt =~ ".*fasta") {
		input:
		file 'adapt_trimmed.fastq' from adapt_trimmed
	}
	else {
		input:
		file 'input.fastq' from sequences
	}

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
    nonpareil -s trimmed.fastq -b nonpareil -t 12
    """
}

process curves {
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
