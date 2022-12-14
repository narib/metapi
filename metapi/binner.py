#!/usr/bin/env python3

import os
import subprocess
import resource
import gzip
from Bio import SeqIO
import pandas as pd


def get_binning_info(mags_dir, cluster_file, assembler):
    if assembler.lower() in ["spades", "metaspades", "megahit"]:
        with os.scandir(mags_dir) as itr, open(cluster_file, "w") as oh:
            for entry in itr:
                if entry.name.endswith(".fa.gz"):
                    bin_id = entry.name.split(".fa.gz")[0]
                    cluster_num = bin_id.split(".")[-1]
                    bin_fa = os.path.join(mags_dir, entry.name)
                    with gzip.open(bin_fa, "rt") as ih:
                        for seq in SeqIO.parse(ih, "fasta"):
                            # graphbin
                            # oh.write("%s,%s" %
                            #         ("_".join(seq.id.split("_")[:2]), cluster_num))
                            # graphbin 2
                            oh.write(f"{seq.id},{cluster_num}\n")


def generate_mags(cluster_file, scaftigs, prefix):

    def get_accession(identifier):
        return "_".join(identifier.split("_")[:2])

    # graphbin
    # scaftigs_index = SeqIO.index(scaftigs, "fasta", key_function=get_accession)

    # graphbin2
    scaftigs_index = SeqIO.index(scaftigs, "fasta")

    df = pd.read_csv(cluster_file, names=["scaftigs_id", "bin_id"])\
           .astype({"scaftigs_id": str,
                    "bin_id": str})\
           .set_index("bin_id")

    for i in df.index.unique():
        scaftigs_id_list = df.loc[[i], "scaftigs_id"]\
                             .dropna().tolist()
        bin_fa = prefix + "." + i + ".fa.gz"
        with gzip.open(bin_fa, 'wt') as oh:
            for scaftigs_id in scaftigs_id_list:
                SeqIO.write(scaftigs_index[scaftigs_id], oh, "fasta")


def extract_mags_report(mags_report_table):
    if os.path.getsize(mags_report_table) > 0:
        mags_report = pd.read_csv(mags_report_table, sep='\t', header=[0, 1])\
                        .rename(columns={
                            "Unnamed: 0_level_1": "binning_group",
                            "Unnamed: 1_level_1": "assembly_group",
                            "Unnamed: 2_level_1": "bin_id",
                            "Unnamed: 3_level_1": "bin_file",
                            "Unnamed: 4_level_1": "assembler",
                            "Unnamed: 5_level_1": "binner"}, level=1)

        mags_report = mags_report[[
            ("binning_group", "binning_group"),
            ("assembly_group", "assembly_group"),
            ("bin_id", "bin_id"),
            ("bin_file", "bin_file"),
            ("assembler", "assembler"),
            ("binner", "binner"),
            ("length", "sum"),
            ("length", "N50")]]
    
        mags_report.columns = ["binning_group", "assembly_group", "bin_id", "bin_file", "assembler", "binner", "length", "N50"]
        return mags_report
    else:
        return pd.DataFrame(columns=["binning_group", "assembly_group", "bin_id", "bin_file", "assembler", "binner", "length", "N50"])


'''
            table_mags = pd.read_csv(input.table_mags, sep="\t", header=[0, 1])
            table_mags = table_mags[
                [
                    ("bin_id", "Unnamed: 1_level_1"),
                    ("chr", "count"),
                    ("length", "sum"),
                    ("length", "min"),
                    ("length", "max"),
                    ("length", "std"),
                    ("length", "N50")
                ]
            ]
            table_mags.columns = [
                "user_genome",
                "contig_number",
                "contig_length_sum",
                "contig_length_min",
                "contig_length_max",
                "contig_length_std",
                "N50"
            ]
'''


def combine_jgi(jgi_list, output_file):
    #first = False
    #jgi_df_list = []
    #for jgi in input.jgi:
    #    if not first:
    #        # jgi format
    #        # contigName\tcontigLen\ttotalAvgDepth\t{sample_id}.align2combined_scaftigs.sorted.bam
    #        jgi_df_first = pd.read_csv(jgi, sep="\t")\
    #                     .loc[:, ["contigName", "contigLen", "totalAvgDepth"]]\
    #                     .dtype({"contigName": str, "contigLen": np.int32, "totalAvgDepth": np.float32})\
    #                     .set_index("contigName")
    #        jgi_df = pd.read_csv(jgi, sep="\t").iloc[:, [0, 3]]\
    #                   .dtype({"contigName": str})
    #        jgi_df[jgi_df.columns[1]] = jgi_df[jgi_df.columns[1]].astype(np.float32)
    #        jgi_df_list = [jgi_df_first, jgi_df.set_index("contigName")]
    #        first = True
    #    else:
    #        jgi_df = pd.read_csv(jgi, sep="\t").iloc[:, [0, 3]]\
    #                   .dtype({"contigName": str})
    #        jgi_df[jgi_df.columns[1]] = jgi_df[jgi_df.columns[1]].astype(np.float32)
    #        jgi_df_list.append(jgi_df.set_index("contigName"))
    ## big table, huge memory
    #pd.concat(jgi_df_list, axis=1).reset_index().to_csv(output.matrix, sep="\t", index=False)

    #matrix_list = []
    #for jgi in input.jgi:
    #    if not first:
    #        first = True
    #        with open(jgi, 'r') as ih:
    #            for line in ih:
    #                line_list = line.strip().split("\t")
    #                matrix_list.append(line_list)
    #    else:
    #        with open(jgi, 'r') as ih:
    #            count = -1
    #            for line in ih:
    #                count += 1
    #                line_list = line.strip().split("\t")
    #                matrix_list[count].append(line_list[3])

    #with open(output.matrix, 'w') as oh:
    #    for i in matrix_list:
    #        oh.write("\t".join(i) + "\n")

    # aovid OSError: Too many open files
    max_num_file = resource.getrlimit(resource.RLIMIT_NOFILE)[0]
    if len(jgi_list) > max_num_file:
        max_num_file += len(jgi_list)
        resource.setrlimit(resource.RLIMIT_NOFILE, (max_num_file, max_num_file))

    outdir = os.path.dirname(output_file)
    os.makedirs(outdir, exist_ok=True)

    files_handle = []
    for jgi in jgi_list:
        files_handle.append(gzip.open(jgi, 'rt'))

    with gzip.open(output_file, 'wt') as oh:
        for line in files_handle[0]:
            oh.write(line.strip())
            for handle in files_handle[1:]:
                depth = handle.readline().strip().split("\t")[3]
                oh.write(f'''\t{depth}''')
            oh.write("\n")

    for handle in files_handle:
        handle.close()