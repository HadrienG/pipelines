#!/usr/bin/env bash

## Annotation script. In order to order contigs with abacas a reference is needed

# abacas.pl -r <reference file: single fasta> -q <query sequence file: fasta> \
# -p <nucmer/promer>  [OPTIONS]
# merge contigs with adapter GATCGGAAGAGCACACGTCTGAACTCCAGTCACCGATGTATCTCGTATGC
# run oriloc
# shift assembly to start at the origin of replication
# annotate the genome

# requirements
# Abacas: mummer, perl, (primer3)
# merge contigs: python, fastx_toolit
# oriloc: R
# switch: python
# prokka: ...

Usage="$(basename "$0") [-h] [-k k-mer size] [-1 R1.fastq] [-2 R2.fastq] \
[-o Output] -- Annotation script

		-h show this useful help
		-r <fasta> Reference file
		-c <Input> Contig file
		-o <Outdir> Output directory name"

while getopts ":hr:c:o:" option
do
	case $option in
		h) echo "$Usage"
		exit
			;;
        r) reference=$OPTARG
            ;;
        c) contigs=$OPTARG
		ctg_base=$(basename $contigs)
            ;;
        o) out_dir=$OPTARG
		if [[ ! -d $out_dir ]]
	      then
	        echo "Creating Output Directory"
	        mkdir -p "$out_dir"
	    fi
            ;;
        :) printf "missing argument for -%s\n" "$OPTARG" >&2
        echo "$Usage" >&2
        exit 1
            ;;
        \?) printf "illegal option -%s\n" "$OPTARG" >&2
        echo "$Usage">&2
        exit 1
            ;;
    esac
done
shift $((OPTIND-1))
# WorkDir=$(pwd)
pushd "$(dirname "$0")" >/dev/null
ScriptPath=$(pwd)
popd > /dev/null

# parameters check
if [ -z "${reference+x}" ]; then echo "$Usage" >&2; printf "\nPlease provide \
a reference genome\n" >&2; exit 1; else echo "Reference is set to \
'$reference'"; fi
if [ -z "${contigs+x}" ]; then echo "$Usage" >&2; printf "\nPlease provide \
a contig file\n" >&2; exit 1; else echo "Contigs is set to '$contigs'"; fi
if [ -z "${out_dir+x}" ]; then echo "$Usage" >&2; printf "\nPlease provide \
an output directory\n" >&2; exit 1; else echo "Output directory is set to \
'$out_dir'"; fi

# requirements check
command -v perl >/dev/null 2>&1 || { printf "perl is not installed or is not \
in the PATH. Aborting\n" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { printf "python3 is not installed or is \
not in the PATH. Aborting\n" >&2; exit 1; }
python -c "from Bio import SeqIO" >/dev/null 2>&1 || { printf "Biopython is \
not installed. Aborting\n" >&2; exit 1; }
command -v abacas >/dev/null 2>&1 || { printf "abacas is not installed or is \
not in the PATH. Aborting\n" >&2; exit 1; }
command -v nucmer >/dev/null 2>&1 || { printf "nucmer is not installed or is \
not in the PATH. Aborting\n" >&2; exit 1; }
command -v fasta_formatter >/dev/null 2>&1 || { printf "fastx_toolkit is not \
installed or is not in the PATH. Aborting\n" >&2; exit 1; }
command -v prokka >/dev/null 2>&1 || { printf "prokka is not installed or is \
not in the PATH. Aborting\n" >&2; exit 1; }
command -v primer3 >/dev/null 2>&1 || { printf "Warning: primer3 is not \
installed or is not in the PATH.\n" >&2; }

# run abacas
cd "$out_dir"
abacas -r "$reference" -q "$contigs" -p nucmer -m >/dev/null 2>&1
if [ "$?" != 0 ]
 	then
		echo "abacas.pl: re-ordering failed." >&2
		exit 1
	else echo "abacas: Contig ordering Done."
fi
cd ..

# merge contigs
fasta_formatter -i "$out_dir/"*MULTIFASTA.fa \
	-o "$out_dir/$ctg_base.formatted.fa" -w 0
python3 "$ScriptPath/contig_merger.py" "$out_dir/$ctg_base.formatted.fa" \
	"$out_dir/$ctg_base.merged.fa" "$ctg_base"
fasta_formatter -i "$out_dir/$ctg_base.merged.fa" \
	-o "$out_dir/$ctg_base.formatted.merged.fa" -w 80
if [ "$?" != 0 ]
 	then
		echo "contig_merger: merging failed." >&2
		exit 1
	else echo "contig_merger: Contig merging Done."
fi

echo $ctg_base
# annotate genome
prokka \
	--outdir "$out_dir/${ctg_base%.fasta}" --force \
	--genus Mycoplasma --species mycoides --strain "${ctg_base%.fasta}" \
	--usegenus --gcode 4 --cpus 4 --locustag "${ctg_base%.fasta}" \
	"$out_dir/$ctg_base.formatted.merged.fa"

# find DnaA and reannotate
python3 "$ScriptPath/dnaa_finder.py" "$out_dir/${ctg_base%.fasta}/"*.gbf \
"$out_dir/${ctg_base%.fasta}/$ctg_base.to_format.fasta" "${ctg_base%.fasta}"
fasta_formatter -i "$out_dir/${ctg_base%.fasta}/$ctg_base.to_format.fasta" \
	-o "$out_dir/${ctg_base%.fasta}/$ctg_base.shifted.fa" -w 80
mv "$out_dir/${ctg_base%.fasta}/$ctg_base.shifted.fa" \
"$out_dir/$ctg_base.shifted.fa"
# rm -rf "${out_dir:?}/${ctg_base%.fasta}/"
prokka \
	--outdir "$out_dir/${ctg_base%.fasta}_new" --force \
	--genus Mycoplasma --species mycoides --strain "${ctg_base%.fasta}" \
	--usegenus --gcode 4 --cpus 4 --locustag "${ctg_base%.fasta}" \
	"$out_dir/$ctg_base.shifted.fa"
