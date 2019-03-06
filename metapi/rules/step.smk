simulation_output = expand([
    "{simulation}/species_metadata.tsv", "{simulation}/{sample}_genome.fa",
    "{raw}/{sample}_{read}.fq.gz", "{raw}/{sample}_abundance.txt"
],
                           simulation=config["results"]["simulation"],
                           raw=config["results"]["raw"]["reads"],
                           read=["1", "2"],
                           sample=_samples.index)

fastqc_output = expand([
    "{fastqc}/{sample}_{read}_fastqc.{out}",
    "{multiqc}/fastqc_multiqc_report.html",
    "{multiqc}/fastqc_multiqc_report_data"
],
                       fastqc=config["results"]["raw"]["fastqc"],
                       multiqc=config["results"]["raw"]["multiqc"],
                       sample=_samples.index,
                       read=["1", "2"],
                       out=["html", "zip"])

oas1_output = expand([
    "{trimming}/{sample}.trimmed.{read}.fq.gz",
    "{trimming}/{sample}.trimmed.stat_out"
],
                     trimming=config["results"]["trimming"],
                     read=["1", "2", "single"],
                     sample=_samples.index)

sickle_output = expand(
    "{trimming}/{sample}.trimmed.{read}.fq.gz",
    trimming=config["results"]["trimming"],
    sample=_samples.index,
    read=["1", "2", "single"])

fastp_output = expand([
    "{trimming}/{sample}.trimmed.{read}.fq.gz",
    "{trimming}/{sample}.fastp.html", "{trimming}/{sample}.fastp.json",
    "{trimming}/fastp_multiqc_report.html",
    "{trimming}/fastp_multiqc_report_data"
],
                      sample=_samples.index,
                      trimming=config["results"]["trimming"],
                      read=["1", "2"])

rmhost_output = expand([
    "{rmhost}/{sample}.rmhost.flagstat.txt",
    "{rmhost}/{sample}.rmhost.{read}.fq.gz"
],
                       rmhost=config["results"]["rmhost"],
                       sample=_samples.index,
                       read=["1", "2"])

megahit_output = expand(
    "{assembly}/{sample}.megahit_out/{sample}.megahit.scaftigs.fa.gz",
    assembly=config["results"]["assembly"],
    sample=_samples.index)

idba_ud_output = expand(
    "{assembly}/{sample}.idba_ud_out/{sample}.idba_ud.scaftigs.fa.gz",
    assembly=config["results"]["assembly"],
    sample=_samples.index)

metaspades_output = expand(
    "{assembly}/{sample}.metaspades_out/{sample}.metaspades.scaftigs.fa.gz",
    assembly=config["results"]["assembly"],
    sample=_samples.index)

coassembly_megahit_output = expand(
    "{coassembly_megahit}/final.contigs.fa.gz",
    coassembly_megahit=config["results"]["coassembly"]["megahit"])

metaquast_output = expand([
    "{metaquast}/{sample}.{assembler}.metaquast_out/report.html",
    "{metaquast}/{sample}.{assembler}.metaquast_out/icarus.html",
    "{metaquast}/{sample}.{assembler}.metaquast_out/combined_reference/report.tsv",
    "{metaquast}/{sample}.{assembler}.metaquast_out/icarus_viewers",
    "{metaquast}/{sample}.{assembler}.metaquast_out/krona_charts",
    "{metaquast}/{sample}.{assembler}.metaquast_out/not_aligned",
    "{metaquast}/{sample}.{assembler}.metaquast_out/runs_per_reference",
    "{metaquast}/{sample}.{assembler}.metaquast_out/summary",
    "{metaquast}/metaquast_multiqc_report.html",
    "{metaquast}/metaquast_multiqc_report_data"
],
                          metaquast=config["results"]["metaquast"],
                          assembler=config["params"]["assembler"],
                          sample=_samples.index)

alignment_output = expand([
    "{alignment}/{sample}.bwa_out/{sample}.{assembler}.flagstat",
    "{alignment}/{sample}.bwa_out/{sample}.{assembler}.sorted.bam",
    "{alignment}/{sample}.bwa_out/{sample}.{assembler}.sorted.bam.bai",
    "{alignment}/scaftigs_flagstat_summary.tsv"
],
                          alignment=config["results"]["alignment"],
                          assembler=config["params"]["assembler"],
                          sample=_samples.index)

metabat2_output = expand([
    "{depth}/{sample}.{assembler}.metabat2.depth.txt",
    "{bins}/{sample}.{assembler}.metabat2_out",
    "{logs}/{sample}.{assembler}.metabat2.done",
    "{logs}/{sample}.{assembler}.metabat2.log"
],
                         depth=config["results"]["binning"]["depth"],
                         bins=config["results"]["binning"]["bins"],
                         logs=config["logs"]["binning"]["metabat2"],
                         assembler=config["params"]["assembler"],
                         sample=_samples.index)

maxbin2_output = expand([
    "{depth}/{sample}.{assembler}.bbmap.depth.txt",
    "{depth}/{sample}.{assembler}.maxbin2.depth.txt",
    "{bins}/{sample}.{assembler}.maxbin2_out/{sample}.bin.summary"
],
                        depth=config["results"]["binning"]["depth"],
                        bins=config["results"]["binning"]["bins"],
                        assembler=config["params"]["assembler"],
                        sample=_samples.index)

checkm_lineage_wf_output = expand(
    ["{out}/{sample}.{assembler}.checkm.txt", "{data}/{sample}.{assembler}"],
    out=config["results"]["checkm"]["out"],
    data=config["results"]["checkm"]["data"],
    assembler=config["params"]["assembler"],
    sample=_samples.index)

checkm_coverage_output = expand(
    "{coverage}/{sample}.{assembler}.checkm_coverage.tsv",
    coverage=config["results"]["checkm"]["coverage"],
    assembler=config["params"]["assembler"],
    sample=_samples.index)

checkm_profile_output = expand(
    "{profile}/{sample}.{assembler}.checkm_profile.tsv",
    profile=config["results"]["checkm"]["profile"],
    assembler=config["params"]["assembler"],
    sample=_samples.index)
'''
dereplication_output = expand(

)

classification_output = expand(

)
'''
annotation_output = expand(
    [
        "{prokka}/{sample}.{assembler}.prokka_out/done",
        "{multiqc_prokka}/prokka_multiqc_report.html",
        "{multiqc_prokka}/prokka_multiqc_report_data"
    ],
    prokka=config["results"]["annotation"]["prokka"],
    multiqc_prokka=config["results"]["annotation"]["multiqc_prokka"],
    assembler=config["params"]["assembler"],
    sample=_samples.index)

profilling_output = expand(
    [
        "{bowtie2out}/{sample}.bowtie2.gz",
        "{profile}/{sample}.metaphlan2.profile",
        "{metaphlan2}/metaphlan2.merged.profile"
    ],
    bowtie2out=config["results"]["profilling"]["metaphlan2"]["bowtie2_out"],
    profile=config["results"]["profilling"]["metaphlan2"]["profile"],
    metaphlan2=config["results"]["profilling"]["metaphlan2"]["base_dir"],
    sample=_samples.index)

burst_output = expand(
    "{burst}/{sample}.reads.burst.b6",
    burst=config["results"]["burst"],
    sample=_samples.index)

if config["params"]["trimming"]["oas1"]["do"]:
    trimming_output = (oas1_output)
if config["params"]["trimming"]["sickle"]["do"]:
    trimming_output = (sickle_output)
if config["params"]["trimming"]["fastp"]["do"]:
    trimming_output = (fastp_output)
trimming_target = (fastqc_output + trimming_output)

# rmhost_target = (trimming_target + rmhost_output)
rmhost_target = (rmhost_output)

assembly_output = ([])
if config["params"]["assembly"]["megahit"]["do"]:
    assembly_output = (megahit_output)
if config["params"]["assembly"]["idba_ud"]["do"]:
    assembly_output = (assembly_output + idba_ud_output)
if config["params"]["assembly"]["metaspades"]["do"]:
    assembly_output = (assembly_output + metaspades_output)

if config["params"]["coassembly"]["megahit"]["do"]:
    assembly_output = (assembly_output + coassembly_megahit_output)

if config["params"]["begin"] == "assembly":
    assembly_target = (assembly_output)
elif config["params"]["rmhost"]["do"]:
    assembly_target = (rmhost_target + assembly_output)
else:
    assembly_target = (trimming_target + assembly_output)

if config["params"]["metaquast"]["do"]:
    assembly_target = (assembly_target + metaquast_output)

alignment_target = (assembly_target + alignment_output)

binning_output = ([])
if config["params"]["binning"]["metabat2"]["do"]:
    binning_output = (metabat2_output)
if config['params']["binning"]["maxbin2"]["do"]:
    binning_output = (binning_output + maxbin2_output)

binning_target = (alignment_target + binning_output)

checkm_output = checkm_lineage_wf_output + checkm_coverage_output + checkm_profile_output
checkm_target = (binning_target + checkm_output)

annotation_target = (checkm_target + annotation_output)

profilling_target = (annotation_target + profilling_output)

burst_target = (profilling_target + burst_output)
'''
dereplication_target = (cehckm_target + dereplication_output)
classification_target = (drep_target + classification_output)
annotation_target = (classification_target + annotation_output)
'''

all_target = (
    fastqc_output + trimming_output + rmhost_output + assembly_output +
    alignment_output + binning_output + checkm_output + annotation_output)
