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

