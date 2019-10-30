#!/usr/bin/env nextflow
nextflow.preview.dsl=2


if (params.help) {exit 0, helpMSG ()}
if (!params.fastq) {exit 1, "input missing, use [--fastq]"}


// Channel input Handling
if (params.fastq) {
fastq_input_ch = Channel
                .fromPath( params.fastq, checkIfExists:true) //schaut ob es auch wirklich eine file ist
                .map  { file -> tuple(file.baseName, file)} // map: (name_file, /Path) baseName ist ne funktion
                .view()
}


//moduls



include './modules/fastqtofasta' params(output: params.output)
include './modules/filtlong' params(output: params.output, filterlenght: params.filterlenght)
include './modules/flye' params(output: params.output, meta: params.meta, g: params.g)
include './modules/nanoplot' params(output: params.output)
include './modules/spades' params(output: params.output)

// Sub-workflows

workflow flye_wf {
        get:    fasta
        main:   flye(fasta)
        emit:   flye.out   
}


workflow fastqtofasta_wf {
        get:    fasta
        main:   fastqtofasta(fasta)
        emit:   fastqtofasta.out   
}


workflow nanoplot_wf {
        get:    fasta
        main:   nanoplot(fasta)
        emit:   nanoplot.out   
}


workflow spades_wf {
        get:    fasta
        main:   spades(fasta)
        emit:   spades.out   
}

workflow filtlong_wf {
        get:    fasta
        main:   filtlong(fasta)
        emit:   filtlong.out   
}


//mainworkflow

workflow {
if (params.flye && params.fastq)                { flye_wf(fastq_input_ch) }
if (params.fastqtofasta && params.fastq)        { fastqtofasta_wf(fastq_input_ch) }
if (params.nanoplot && params.fastq)            { nanoplot_wf(fastq_input_ch) }
if (params.filtlong && params.fastq)            { filtlong_wf(fastq_input_ch) }
if (params.spades && params.fastq)              { spades_wf(fastq_input_ch) }
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
