#!/usr/bin/env nextflow

params.in = "../test/1P.fastq"
sequences = file(params.in)

process adapter_trimming {
	input:
	file 'input.fastq' from sequences

	output:
	file 'trimmed.fastq' into trimmed

	"""
	scythe 
	"""
}
