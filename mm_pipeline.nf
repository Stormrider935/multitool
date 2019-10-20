#!/usr/bin/env nextflow
nextflow.preview.dsl=2


if (params.help) {exit 0, helpMSG ()}
if (!params.fastq) {exit 1, "input missing, use [--fastq]"}


// daten in chanel laden
if (params.fastq) {
fastq_input_ch = Channel
                .fromPath( params.fastq, checkIfExists:true) //schaut ob es auch wirklich eine file ist
                .map  { file -> tuple(file.baseName, file)} // map: (name_file, /Path) baseName ist ne funktion
                .view()
}


//modul hinzufügen

//start flye
if (params.flye && params.fastq) { 
        include 'modules/flye' params(output: params.output, meta: params.meta, g: params.g)
        flye(fastq_input_ch)}


//start fastqtofasta
if (params.fastqtofasta && params.fastq) { 
        include 'modules/fastqtofasta' params(output: params.output)
        fastqtofasta(fastq_input_ch)}


if (params.nanoplot && params.fastq) { 
        include 'modules/nanoplot' params(output: params.output)
        nanoplot(fastq_input_ch)}


def helpMSG() {

 c_light_green = "\033[0;92m";
 c_reset = "\033[0m";
 c_light_magenta = "\033[0;95m";
 c_cyan = "\033[0;36m";
 c_dim = "\033[2m";
    
    log.info """
    ____________________________________________________________________________________________
    
    Nextflow Multitool for easy use, by Mike Marquet
    
    ${c_light_magenta}Usage example:${c_reset}
    nextflow run Stormrider935/multitool --fastq '*/*.fastq' --nanoplot 
    ${c_light_green}Input:${c_reset}
    ${c_light_green} --fastq ${c_reset}            '*.fastq'   -> read file(s) in fastq, one sample per file - uses filename

    ${c_cyan} Workflow    ${c_reset}                                             ${c_light_green}Input:${c_reset}
    ${c_cyan} --flye  ${c_reset}             assembly via flye-assembler         ${c_light_green}[--fastq]${c_reset}
    ${c_dim}  ..option/mandatory flags:      [--meta] for metagenomes  [--g] mandatory! estimated genome size for ${c_reset}

    ${c_cyan} --nanoplot  ${c_reset}         read quality via nanoplot           ${c_light_green}[--fastq]${c_reset}
    ${c_cyan} --fastqtofasta  ${c_reset}     converts fastq to fasta             ${c_light_green}[--fastq]${c_reset}
    
    """.stripIndent()
}
