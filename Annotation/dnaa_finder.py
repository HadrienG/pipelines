#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
from Bio import SeqIO


def arg_parser():
    Description = 'DnaA finder.'
    parser = argparse.ArgumentParser(description=Description)
    parser.add_argument(
                        'input',
                        help='input',
                        metavar='<gbk>')
    parser.add_argument(
                        'output',
                        help='output',
                        metavar='<fasta>')
    parser.add_argument(
                        'ctg_name',
                        help='ctg_name')
    args = parser.parse_args()
    return args


def dnaa_finder(Input, Output, ctg_name):
    for record in SeqIO.parse(Input, "genbank"):
        for feature in record.features:
            if feature.type == 'CDS':
                if 'product' in feature.qualifiers:
                    if 'DnaA' in feature.qualifiers['product'][0]:
                        dnaa_start = feature.location.start
                        print('DnaA starts at position %s' % dnaa_start)
                        with open(Output, 'w') as fasta:
                            fasta.write(str(
                                '>%s\n' % ctg_name +
                                record.seq[dnaa_start:] +
                                record.seq[:dnaa_start] +
                                '\n'))


def main():
    args = arg_parser()
    dnaa_finder(args.input, args.output, args.ctg_name)


if __name__ == '__main__':
    main()
