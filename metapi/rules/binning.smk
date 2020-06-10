if config["params"]["binning"]["metabat2"]["do"]:
    rule binning_metabat2_coverage:
        input:
            bam = os.path.join(
                config["output"]["alignment"],
                "bam/{sample}.{assembler}.out/{sample}.{assembler}.align2scaftigs.sorted.bam"),
            bai = os.path.join(
                config["output"]["alignment"],
                "bam/{sample}.{assembler}.out/{sample}.{assembler}.align2scaftigs.sorted.bam.bai")
        output:
            coverage = os.path.join(
                config["output"]["binning"],
                "coverage/{sample}.{assembler}.out/{sample}.{assembler}.metabat2.coverage")
        priority:
            30
        log:
            os.path.join(config["output"]["binning"],
                         "logs/coverage/{sample}.{assembler}.metabat2.coverage.log")
        params:
            output_dir = os.path.join(config["output"]["binning"],
                                      "coverage/{sample}.{assembler}.out")
        shell:
            '''
            jgi_summarize_bam_contig_depths \
            --outputDepth {output.coverage} \
            {input.bam} \
            2> {log}
            '''


    rule binning_metabat2:
        input:
            scaftigs = os.path.join(
                config["output"]["assembly"],
                "scaftigs/{sample}.{assembler}.out/{sample}.{assembler}.scaftigs.fa.gz"),
            coverage = os.path.join(
                config["output"]["binning"],
                "coverage/{sample}.{assembler}.out/{sample}.{assembler}.metabat2.coverage")
        output:
            bins_dir = directory(os.path.join(config["output"]["binning"],
                                              "bins/{sample}.{assembler}.out/metabat2"))
        priority:
            30
        log:
            os.path.join(config["output"]["binning"],
                         "logs/binning/{sample}.{assembler}.metabat2.binning.log")
        params:
            bin_prefix = os.path.join(
                config["output"]["binning"],
                "bins/{sample}.{assembler}.out/metabat2/{sample}.{assembler}.metabat2.bin"),
            min_contig = config["params"]["binning"]["metabat2"]["min_contig"],
            seed = config["params"]["binning"]["metabat2"]["seed"]
        shell:
            '''
            metabat2 \
            -i {input.scaftigs} \
            -a {input.coverage} \
            -o {params.bin_prefix} \
            -m {params.min_contig} \
            --seed {params.seed} -v \
            > {log}
            '''


    rule binning_metabat2_all:
        input:
            expand(
                os.path.join(
                    config["output"]["binning"],
                    "bins/{sample}.{assembler}.out/metabat2"),
                assembler=ASSEMBLERS,
                sample=SAMPLES.index.unique())

else:
    rule binning_metabat2_all:
        input:


if config["params"]["binning"]["maxbin2"]["do"]:
    rule binning_maxbin2_coverage:
        input:
            bam = os.path.join(
                config["output"]["alignment"],
                "bam/{sample}.{assembler}.out/{sample}.{assembler}.align2scaftigs.sorted.bam"),
            bai = os.path.join(
                config["output"]["alignment"],
                "bam/{sample}.{assembler}.out/{sample}.{assembler}.align2scaftigs.sorted.bam.bai")
        output:
            coverage_bb = os.path.join(
                config["output"]["binning"],
                "coverage/{sample}.{assembler}.out/{sample}.{assembler}.bbmap.coverage"),
            coverage = os.path.join(
                config["output"]["binning"],
                "coverage/{sample}.{assembler}.out/{sample}.{assembler}.maxbin2.coverage")
        priority:
            30
        log:
            os.path.join(config["output"]["binning"],
                         "logs/coverage/{sample}.{assembler}.maxbin2.coverage.log")
        params:
            output_dir = os.path.join(config["output"]["binning"],
                                      "coverage/{sample}.{assembler}.out")
        shell:
            '''
            pileup.sh in={input.bam} out={output.coverage_bb} 2> {log}
            awk '{{print $1 "\t" $5}}' {output.coverage_bb} | grep -v '^#' > {output.coverage}
            '''


    rule binning_maxbin2:
        input:
            scaftigs = os.path.join(
                config["output"]["assembly"],
                "scaftigs/{sample}.{assembler}.out/{sample}.{assembler}.scaftigs.fa.gz"),
            coverage = os.path.join(
                config["output"]["binning"],
                "coverage/{sample}.{assembler}.out/{sample}.{assembler}.maxbin2.coverage")
        output:
            bins_dir = directory(os.path.join(config["output"]["binning"],
                                              "bins/{sample}.{assembler}.out/maxbin2"))
        priority:
            30
        log:
            os.path.join(config["output"]["binning"],
                         "logs/binning/{sample}.{assembler}.maxbin2.binning.log")
        params:
            bin_prefix = os.path.join(
                config["output"]["binning"],
                "bins/{sample}.{assembler}.out/maxbin2/{sample}.{assembler}.maxbin2.bin")
        threads:
            config["params"]["binning"]["threads"]
        shell:
            '''
            mkdir -p {output.bins_dir}
            run_MaxBin.pl \
            -thread {threads} \
            -contig {input.scaftigs} \
            -abund {input.coverage} \
            -out {params.bin_prefix} \
            2> {log}
            /ldfssz1/ST_META/share/User/juyanmei/miniconda3/bin/rename 's/\.fasta$/\.fa/' {params.bin_prefix}.*.fasta
            '''


    rule binning_maxbin2_all:
        input:
            expand(
                os.path.join(
                    config["output"]["binning"],
                    "bins/{sample}.{assembler}.out/maxbin2"),
                assembler=ASSEMBLERS,
                sample=SAMPLES.index.unique())
else:
    rule binning_maxbin2_all:
        input:


if config["params"]["binning"]["dastools"]["do"]:
    rule binning_dastools:
        input:
            bins_dir = expand(
                os.path.join(
                    config["output"]["binning"],
                    "bins/{{sample}}.{{assembler}}.out/{binner}"),
                    binner=BINNERS[:-1]),
            scaftigs = os.path.join(
                config["output"]["assembly"],
                "scaftigs/{sample}.{assembler}.out/{sample}.{assembler}.scaftigs.fa.gz"),
            pep = os.path.join(
                config["output"]["predict"],
                "scaftigs_gene/{sample}.{assembler}.prodigal.out/{sample}.{assembler}.faa")
        output:
            bins_dir = directory(os.path.join(
                config["output"]["binning"],
                "bins/{sample}.{assembler}.out/dastools"))
        log:
            os.path.join(config["output"]["binning"],
                         "logs/binning/{sample}.{assembler}.dastools.binning.log")
        priority:
            30
        params:
            search_engine = config["params"]["binning"]["dastools"]["search_engine"],
            write_bin_evals = config["params"]["binning"]["dastools"]["write_bin_evals"],
            write_bins = config["params"]["binning"]["dastools"]["write_bins"],
            write_unbinned = config["params"]["binning"]["dastools"]["write_unbinned"],
            create_plots = config["params"]["binning"]["dastools"]["create_plots"],
            score_threshold = config["params"]["binning"]["dastools"]["score_threshold"],
            duplicate_penalty = config["params"]["binning"]["dastools"]["duplicate_penalty"],
            megabin_penalty = config["params"]["binning"]["dastools"]["megabin_penalty"],
            bin_suffix = "fa",
            bin_prefix = os.path.join(
                config["output"]["binning"],
                "bins/{sample}.{assembler}.out/dastools/{sample}.{assembler}.dastools.bin")
        threads:
            config["params"]["binning"]["threads"]
        run:
            import glob
            import os

            shell('''mkdir -p {output.bins_dir}''')

            binners = []
            tsv_list = []

            for bin_dir in input.bins_dir:
                binner_id = os.path.basename(bin_dir)
                bins_list = glob.glob(bin_dir + "/*.bin.*.fa")

                if len(bins_list) > 0:
                    binners.append(binner_id)
                    tsv_file = "{params.bin_prefix}.%s.scaftigs2bin.tsv" % binner_id
                    tsv_list.append(tsv_file)

                    shell(
                        '''
                        Fasta_to_Scaffolds2Bin.sh \
                        --input_folder %s \
                        --extension {params.bin_suffix} \
                        > %s
                        ''' % (bin_dir, tsv_file))

            if len(binners) > 0:
                shell(
                    '''
                    pigz -p {threads} -d -c {input.scaftigs} > {output.bins_dir}/scaftigs.fasta
                    ''')

                shell(
                    '''
                    DAS_Tool \
                    --bins %s \
                    --labels %s \
                    --contigs {output.bins_dir}/scaftigs.fasta \
                    --proteins {input.pep} \
                    --outputbasename {params.bin_prefix} \
                    --search_engine {params.search_engine} \
                    --write_bin_evals {params.write_bin_evals} \
                    --write_bins {params.write_bins} \
                    --write_unbinned {params.write_unbinned} \
                    --create_plots {params.create_plots} \
                    --score_threshold {params.score_threshold} \
                    --duplicate_penalty {params.duplicate_penalty} \
                    --megabin_penalty {params.megabin_penalty} \
                    --threads {threads} --debug > {log}
                    ''' % (",".join(tsv_list), ",".join(binners)))

            shell('''rm -rf {output.bins_dir}/scaftigs.fasta''')

            bins_list_dastools = glob.glob(
                os.path.join(
                    params.bin_prefix + "_DASTool_bins" ,
                    "*." + params.bin_suffix))

            if len(bins_list_dastools):
                for bin_fa in bins_list_dastools:
                    bin_id = os.path.basename(bin_fa).split(".")[2]
                    bin_fa_ = os.path.basename(bin_fa).replace(bin_id, bin_id +"_dastools")
                    shell('''mv %s %s''' % (bin_fa, os.path.join(output.bins_dir, bin_fa_)))


    rule binning_dastools_all:
        input:
            expand(
                os.path.join(
                    config["output"]["binning"],
                    "bins/{sample}.{assembler}.out/dastools"),
                assembler=ASSEMBLERS,
                sample=SAMPLES.index.unique())

else:
    rule binning_dastools_all:
        input:


if len(BINNERS) != 0:
    rule binning_report:
        input:
            bins_dir = os.path.join(
                config["output"]["binning"],
                "bins/{sample}.{assembler}.out/{binner}")
        output:
            report_dir = directory(
                os.path.join(
                    config["output"]["binning"],
                    "report/{assembler}_{binner}_stats/{sample}"))
        priority:
            35
        params:
            sample_id = "{sample}",
            assembler = "{assembler}",
            binner = "{binner}"
        run:
            import glob

            shell('''rm -rf {output.report_dir}''')
            shell('''mkdir -p {output.report_dir}''')

            bin_list =  glob.glob(input.bins_dir + "/*bin*fa")
            header_list = ["sample_id", "bin_id", "assembler", "binner",
                           "chr", "length", "#A", "#C", "#G", "#T",
                           "#2", "#3", "#4", "#CpG", "#tv", "#ts", "#CpG-ts"]
            header = "\\t".join(header_list)

            for bin_fa in bin_list:
                bin_id = os.path.basename(os.path.splitext(bin_fa)[0])
                header_ = "\\t".join([params.sample_id, bin_id,
                                      params.assembler, params.binner])
                stats_file = os.path.join(output.report_dir,
                                          bin_id + ".seqtk.comp.tsv.gz")

                shell(
                    '''
                    seqtk comp %s | \
                    awk \
                    'BEGIN \
                    {{print "%s"}}; \
                    {{print "%s" "\t" $0}}' | \
                    gzip -c > %s
                    ''' % (bin_fa, header, header_, stats_file))


    rule binning_report_merge:
        input:
            expand(os.path.join(
                config["output"]["binning"],
                "report/{{assembler}}_{{binner}}_stats/{sample}"),
                   sample=SAMPLES.index.unique())
        output:
            summary = os.path.join(
                config["output"]["binning"],
                "report/assembly_stats_{assembler}_{binner}.tsv")
        params:
            len_ranges = config["params"]["assembly"]["report"]["len_ranges"]
        threads:
            config["params"]["binning"]["threads"]
        run:
            import glob
            comp_list = []
            for i in input:
                comp_list += glob.glob(i + "/*bin*.seqtk.comp.tsv.gz")

            if len(comp_list) != 0:
                metapi.assembler_init(params.len_ranges,
                                      ["sample_id", "bin_id", "assembler", "binner"])
                metapi.merge(comp_list, metapi.parse_assembly,
                             threads, save=True,  output=output.summary)
            else:
                shell('''touch {output.summary}''')


    rule binning_report_all:
        input:
            expand(os.path.join(
                config["output"]["binning"],
                "report/assembly_stats_{assembler}_{binner}.tsv"),
                   assembler=ASSEMBLERS,
                   binner=BINNERS)

else:
    rule binning_report_all:
        input:


rule binning_all:
    input:
        rules.binning_metabat2_all.input,
        rules.binning_maxbin2_all.input,
        rules.binning_dastools_all.input,
        rules.binning_report_all.input,

        rules.alignment_all.input
