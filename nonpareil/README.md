## Nonpareil

Estimate average coverage and create Nonpareil curves for metagenomic datasets.

### Quick Start

To execute the pipeline on your computer, first pull the docker image

    docker pull hadrieng/nonpareil

Then execute the workflow

    nextflow run nonpareil.nf

It will produce a nonpareil curve for the sample data present in this directory.

### Pipeline parameters

#### --reads

* Specifies the location of the reads fastq file
* By default it is set to data/ERR1135746.fastq

#### --mode
* Specifies the mode for running the pipeline
* It must be **ion** or **illumina**
* If set ion, non adapter trimming will be performed
* If set to illumina, see option --adapt below

#### --adapt

* Optional. It is used by --mode illumina
* Specifies the location of the adapters file for adapter trimming
* It must end in .fasta
* By default it is set to data/adapters.fasta

### Profiles

*The SGBC cluster uses a module system. Pulling the docker image is not required!*

By default, the pipeline runs locally using docker. If you run the nonpareil pipeline on the SGBC cluster, please pass the option **-profile planet**

Example:

    nextflow run nonpareil.nf -profile planet --reads /proj/my_proj/data/reads.fastq --mode illumina --adapt custom_adapters.fasta

### Citations

If you use this pipeline in your research, please cite:

> * Buffalo Vince (2011), Scythe: A Bayesian adapter trimmer [Software]. Available at https://github.com/vsbuffalo/scythe
> * Joshi NA, Fass JN. (2011). Sickle: A sliding-window, adaptive, quality-based trimming tool for FastQ files
[Software].Available at https://github.com/najoshi/sickle.
> * Rodriguez-R & Konstantinidis. 2014. Nonpareil: a redundancy-based approach to assess the level of coverage in metagenomic datasets. Bioinformatics 30 (5): 629-635. doi: 10.1093/bioinformatics/btt584.
