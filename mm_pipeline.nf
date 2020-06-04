#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/************* 
* ERROR HANDLING
*************/
// profiles
if ( workflow.profile == 'standard' ) { exit 1, "NO VALID EXECUTION PROFILE SELECTED, use e.g. [-profile local,docker]" }

if (
    workflow.profile.contains('docker')
    ) { "engine selected" }
else { exit 1, "No engine selected:  -profile EXECUTER,ENGINE" }

if (
    workflow.profile.contains('local') ||

    workflow.profile.contains('git_action')
    ) { "executer selected" }
else { exit 1, "No executer selected:  -profile EXECUTER,ENGINE" }

}


/************* 
* INPUT HANDLING
*************/

// fasta input or via csv file
    if (params.fasta && params.list) { fasta_input_ch = Channel
            .fromPath( params.fasta, checkIfExists: true )
            .splitCsv()
            .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
                }
    else if (params.fasta) { fasta_input_ch = Channel
            .fromPath( params.fasta, checkIfExists: true)
            .map { file -> tuple(file.baseName, file) }
                }
    
// fastq input or via csv file
    if (params.fastq && params.list) { fastq_input_ch = Channel
            .fromPath( params.fastq, checkIfExists: true )
            .splitCsv()
            .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
                }
    else if (params.fastq) { fastq_input_ch = Channel
            .fromPath( params.fastq, checkIfExists: true)
            .map { file -> tuple(file.baseName, file) }
                }

//moduls

include './modules/flye' params(output: params.output, meta: params.meta, g: params.g)


// include './modules/fastqtofasta' params(output: params.output)
// include './modules/filtlong' params(output: params.output, filterlenght: params.filterlenght)
// include './modules/nanoplot' params(output: params.output)
// include './modules/spades' params(output: params.output)
// include './modules/bandage' params(output: params.output)


// Sub-workflows




workflow flye_wf {
        get:    fastq
        main:   flye(fastq)
        emit:   flye.out   








//mainworkflow

workflow {
                if (params.flye && params.fastq)                { flye_wf(fastq_input_ch) }

}



def helpMSG() {

 c_light_green = "\033[0;92m";
 c_reset = "\033[0m";
 c_light_magenta = "\033[0;95m";
 c_cyan = "\033[0;36m";
 c_dim = "\033[2m";
    
    log.info """
    ____________________________________________________________________________________________

    
    
    Nextflow Multitool for easy use, by Mike Marquet
    
    Nextflow implementation = 19.10
    
    ${c_light_magenta}Usage example:${c_reset}
    nextflow run Stormrider935/multitool --fastq '*/*.fastq' --nanoplot 
    ${c_light_green}Input:${c_reset}
    ${c_light_green} --fastq ${c_reset}            '*.fastq'   -> read file(s) in fastq, one sample per file - uses filename

    ${c_cyan} Workflow    ${c_reset}                                             ${c_light_green}Input:${c_reset}
    ${c_cyan} --flye  ${c_reset}             assembly via flye-assembler         ${c_light_green}[--fastq]${c_reset}
    ${c_dim}  ..option/mandatory flags:      [--meta] for metagenomes  [--g] mandatory! estimated genome size for ${c_reset}

    ${c_cyan} --nanoplot  ${c_reset}         read quality via nanoplot           ${c_light_green}[--fastq]${c_reset}
    ${c_cyan} --fastqtofasta  ${c_reset}     converts fastq to fasta             ${c_light_green}[--fastq]${c_reset}
    ${c_cyan} --filtlong  ${c_reset}         filters fastq-files for length      ${c_light_green}[--fastq]${c_reset}
    ${c_dim}  ..option flag:                 [--filterlenght] 2000  (your desired cut-off) ${c_reset}
    """.stripIndent()
}
