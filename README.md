# metapi

[![bioconda-badge](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](http://bioconda.github.io)
[![PyPI version](https://badge.fury.io/py/metapi.svg)](https://badge.fury.io/py/metapi)
[![star this repo](http://githubbadges.com/star.svg?user=ohmeta&repo=metapi&style=flat)](https://github.com/ohmeta/metapi)
[![Anaconda-Server Badge](https://anaconda.org/bioconda/metapi/badges/downloads.svg)](https://anaconda.org/bioconda/metapi)

A pipeline to construct genome catalogue from metagenomcis data.

## Installation

metapi works with Python 3.6+.
You can install it via [bioconda](https://bioconda.github.io/):

```
# [WIP]
$ conda install metapi
```

Or via pip:

```
$ pip install metapi
```

## Run

### help

```
$ metapi --help

  .___  ___.  _______ .___________.    ___      .______    __
  |   \/   | |   ____||           |   /   \     |   _  \  |  |
  |  \  /  | |  |__   `---|  |----`  /  ^  \    |  |_)  | |  |
  |  |\/|  | |   __|      |  |      /  /_\  \   |   ___/  |  |
  |  |  |  | |  |____     |  |     /  _____  \  |  |      |  |
  |__|  |__| |_______|    |__|    /__/     \__\ | _|      |__|

            Omics for All, Open Source for All

  A pipeline to construct a genome catalogue from metagenomics data

    optional arguments:
    -h, --help     show this help message and exit
    -v, --version  print software version and exit

    available subcommands:

    init         init project
    denovo_wf    denovo_wf pipeline
```

### init

```
$ metapi init --help

  usage: metapi init [-h] [-d WORKDIR] [-s SAMPLES]
                    [-b {simulate,trimmingrmhost,assembly}]

  arguments:
      -h, --help            show this help message and exit
      -d WORKDIR, --workdir WORKDIR
                            project workdir
      -s SAMPLES, --samples SAMPLES
                            samples list, tsv format required if begin from
                            trimming, rmhost, or assembly: if it is fastq: the
                            header is [id, fq1, fq2], else it is sra: the header
                            is [id, sra] else begin from simulate: the header is
                            [id, genome, abundance, reads_num, model]
    -b {simulate,trimming,rmhost,assembly}, --begin {simulate,trimming,rmhost,assembly}
                            pipeline starting point
```

### denovo_wf

```
$ metapi denovo_wf --help

  usage: metapi denovo_wf [-h] [-d WORKDIR] [--cores CORES] [--jobs JOBS]
                          [--list] [--run] [--debug] [--dry_run] [--qsub]
                          [--wait WAIT] [--snake [SNAKEMAKEARGS]]
                          [TASK]

  positional arguments:
    TASK                  pipeline end point. Allowed values are simulate_all,
                          prepare_reads_all, raw_fastqc_all, trimming_oas1_all,
                          trimming_sickle_all, trimming_fastp_all, trimming_all,
                          rmhost_bwa_all, rmhost_bowtie2_all, rmhost_all, 
                          assebmly_megahit_all, assembly_idba_ud_all,
                          assembly_metaspades_all, assembly_spades_all,
                          assembly_metaquast_all, assembly_report_all, assembly_all,
                          alignment_base_depth_all, alignment_all,
                          binning_metabat2_all, binning_maxbin2_all,
                          binning_report_all, binning_all, cobinning_all,
                          predcit_scafitgs_gene_all, predict_bins_gene_all,
                          predcit_all, checkm_link_bins, checkm_all,
                          dereplicate_drep_all, dereplicate_all,
                          classify_short_reads_kraken2_all,
                          classify_hmq_bins_gtdbtk_all, classify_all,
                          profiling_metaphlan2_all, profiling_jgi_all,
                          profiling_humann2_all, profiling_all,
                          upload_sequencing_all, upload_assembly_all,
                          upload_all, all

  arguments:
    -h, --help            show this help message and exit
    -d WORKDIR, --workdir WORKDIR
                          project workdir, default: ./
    --cores CORES         CPU cores
    --jobs JOBS           qsub job numbers
    --list                list pipeline rules
    --run                 run pipeline
    --debug               debug pipeline
    --dry_run             dry run pipeline
    --qsub                qsub pipeline
    --wait WAIT           wait given seconds
    --snake [SNAKEMAKEARGS]
                          other snakemake command options, if want --touch, just
                          --snake touch
```

## input requirements

The input samples file: `samples.tsv` format:

Note: If `id` col contain same id, then the reads of each sample will be merged.

- begin from trimming, rmhost or assembly:

  - `Paired-end fastq`

  | id  |   fq1   |   fq2   |
  | :-: | :-----: | :-----: |
  | s1  | aa.1.fq | aa.2.fq |
  | s2  | bb.1.fq | bb.2.fq |
  | s2  | cc.1.fq | cc.2.fq |
  | s3  | dd.1.fq | dd.2.fq |

  - `Single-end fastq`

  | id  |   fq1   | fq2 |
  | :-: | :-----: | :-: |
  | s1  | aa.1.fq |     |
  | s2  | bb.1.fq |     |
  | s2  | cc.1.fq |     |
  | s3  | dd.1.fq |     |

  - `SRA`:

  SRA can be dumpped to Paired-end fastq reads

  | id  |  sra   |
  | :-: | :----: |
  | s1  | aa.sra |
  | s2  | bb.sra |
  | s2  | cc.sra |
  | s3  | dd.sra |

- begin from simulate

  | id  | genome | abundance | reads_num | model |
  | :-: | :----: | :-------: | :-------: | :---: |
  | s1  | g1.fa  |    1.0    |    1M     | hiseq |
  | s2  | g1.fa  |    0.5    |    2M     | hiseq |
  | s2  | g2.fa  |    0.5    |    2M     | hiseq |
  | s3  | g1.fa  |    0.2    |    3M     | hiseq |
  | s3  | g2.fa  |    0.3    |    3M     | hiseq |
  | s3  | g3.fa  |    0.5    |    3M     | hiseq |

It means:

The sample s1 contain 1M reads which come from g1, the relatative abundance of
species g1 is 1.0.

The sample s2 contain 2M reads, 1M reads come from g1
and 1M reads come from g2. the relatative abundance of
species g1 is 0.5, the relatative abundance of
species g2 is 0.5.

The sample s3 contain 3M reads, 0.6M reads come from g1, 0.9M reads come from
g2 and 1.5M reads come from g3, the relatative abundance of
species g1 is 0.2, the relatative abundance of
species g2 is 0.3, the relatative abundance of
species g3 is 0.5.

Then metapi will use [InSilicoSeq](https://github.com/HadrienG/InSilicoSeq) to generate metagenomics shutgun reads.

## Getting help

If you want to report a bug or issue, or have problems with installing or
running the software, please create [a new
issue](https://github.com/ohmeta/metapi/issues).
This is the preferred way of getting support. Alternatively, you can [mail me](mailto:alienchuj@gmail.com).

## Contributing

Contributions welcome! Send me a pull request or get in [touch](mailto:alienchuj@gmail.com).

When contributing a PR, please use the [dev](https://github.com/ohmeta/metapi/tree/dev) branch.
For style, code will be checked using flake8,
[black](https://github.com/psf/black), and
[snakefmt](https://github.com/snakemake/snakefmt). These modules can be
installed via conda, `conda install black flake8 flake8-bugbear snakefmt` or via
pip `pip install black flake8 flake8-bugbear snakefmt`.

## Contributors

- Jie Zhu - @alienzj

## License

This module is licensed under the terms of the [GPLv3 license](https://opensource.org/licenses/GPL-3.0).
