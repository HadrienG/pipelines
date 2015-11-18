#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse


def arg_parser():
    Description = 'contig merger.'
    parser = argparse.ArgumentParser(description=Description)
    parser.add_argument(
                        'input',
                        help='input',
                        metavar='<fasta>')
    parser.add_argument(
                        'output',
                        help='output',
                        metavar='<fasta>')
    parser.add_argument(
                        'ctg_name',
                        help='ctg_name')
    args = parser.parse_args()
    return args


def ctg_merger(Input, Output, ctg_name):
    N = 'NNNNNCACACACTTAATTAATTAAGTGTGTGNNNNN'
    f = open(Input)
    of = open(Output, 'w')
    name_ctg = f.readline()
    seq = f.readline()
    of.writelines('>%s\n' % ctg_name[:-6])
    of.writelines(N)
    while seq:
        of.writelines(seq)
        of.writelines(N)
        name_ctg = f.readline()
        seq = f.readline()
    of.writelines(N)
    of.close()


def main():
    args = arg_parser()
    ctg_merger(args.input, args.output, args.ctg_name)

if __name__ == '__main__':
    main()
