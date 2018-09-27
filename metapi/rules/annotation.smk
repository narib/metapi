rule prokka_bins:
    input:
        directory(os.path.join(config["results"]["binning"]["bins"], "{sample}.metabat2_out"))
    output:
        default = os.path.join(config["results"]["annotation"]["prokka"], "{sample}.prokka_out/done")
    params:
        outdir = directory(os.path.join(config["results"]["annotation"]["prokka"], "{sample}.prokka_out")),
        logdir = config["logs"]["annotation"]["prokka"],
        kingdom = config["params"]["annotation"]["prokka"]["kingdom"],
        metagenome = "--metagenome" if config["params"]["annotation"]["prokka"]["metagenome"] else ""
    threads:
        config["params"]["annotation"]["prokka"]["threads"]
    run:
        import glob
        import os
        import time
        import subprocess
        bin_list = glob.glob(input[0] + "/*bin*fa")

        cmd_list = []
        for bin in bin_list:
            bin_id = os.path.basename(bin.strip()).rstrip(".fa")
            prokka_dir = os.path.join(params.outdir, bin_id)
            log_file= os.path.join(params.logdir, bin_id + ".prokka.log")
            os.makedirs(params.logdir, exist_ok=True)
            cmd = "prokka %s --outdir %s --locustag %s --prefix %s --kingdom %s %s --cpus %d 2> %s" % (bin.strip(), prokka_dir, bin_id, bin_id, params.kingdom, params.metagenome, threads, log_file)
            print(cmd)
            cmd_list.append(cmd)

        rc = subprocess.check_call("&&".join(cmd_list), shell=True)
        time.sleep(60)

        if rc == 0:
            with open(output.default, 'w') as out:
                out.write("Hello, Prokka!")
