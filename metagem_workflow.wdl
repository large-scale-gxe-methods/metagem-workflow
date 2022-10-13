workflow metagem_wf {

	Array[File] inputfiles
	String exposure_names
	Int meta_option
	Int? memory = 5
	Int? cpu = 1
	Int? disk = 10
	Int? preemptible = 0

	call run_metagem {
		input:
			inputfiles = inputfiles,
			exposure_names = exposure_names,
			meta_option = meta_option,
			memory = memory,
			cpu = cpu,
			disk = disk,
			preemptible = preemptible
	}

	output {
		File output_sumstats = run_metagem.out
	}

	parameter_meta {
		inputfiles: "Tabular output files containing summary statistics from GEM runs (must have been run using --output-style 'meta' or 'full')."
		exposure_names: "Name(s) of the exposures whose interaction should be meta-analyzed (space-delimited)."
		meta_option: "Integer indicating the type of standard errors to be used (0: both model-based and robust; 1: model-based only; 2: robust only)."
		memory: "Requested memory (in GB)."
		cpu: "Minimum number of requested cores."
		disk: "Requested disk space (in GB)."
		preemptible: "Optional number of attempts using a preemptible machine from Google Cloud prior to falling back to a standard machine (default = 0, i.e., don't use preemptible)."
	}
}

task run_metagem {

	Array[File] inputfiles
	String exposure_names
	Int meta_option
	Int? memory
	Int? cpu
	Int? disk
	Int? preemptible

	command {
		dstat -c -d -m --nocolor > system_resource_usage.log &
		atop -x -P PRM | grep '(METAGEM)' > process_resource_usage.log &

		/METAGEM/METAGEM \
			--input-files ${sep=" " inputfiles} \
			--exposure-names ${exposure_names} \
			--meta-option ${meta_option} \
			--out metagem_res
	}

	runtime {
		docker: "quay.io/large-scale-gxe-methods/metagem-workflow:latest"
		memory: "${memory} GB"
		cpu: "${cpu}"
		disks: "local-disk ${disk} HDD"
		preemptible: "${preemptible}"
		gpu: false
		dx_timeout: "7D0H00M"
	}

	output {
		File out = "metagem_res"
		File system_resource_usage = "system_resource_usage.log"
		File process_resource_usage = "process_resource_usage.log"
	}
}

