#!/usr/bin/env nextflow

params.reads = 'data/SRR957824.fastq'
params.ref = 'data/pO157_Sakai.fasta'
params.adapt = 'data/adapters.fasta'
params.mode = 'illumina'

sequences = file(params.reads)
reference = file(params.ref)
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

process bowtie {
    input:
    file input from trimmed
    file ref_genome from reference

    output:
    file "${input.baseName}.mapped" into mapped

    """
    bowtie2-build $ref_genome index
    bowtie2 -p 12 -x index -U $input -S "${input.baseName}.bam"
    """
}

process mpileup {
    input:
    file input from mapped
    file ref_genome from reference

    output:
    file "${input.baseName}.vcf" into snp_file

    """
    samtools mpileup
    """
}
