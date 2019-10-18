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
        include 'modules/flye' params(output: params.output)
        flye(fastq_input_ch)}


//start fastqtofasta
if (params.fastqtofasta && params.fastq) { 
        include 'modules/fastqtofasta' params(output: params.output)
        fastqtofasta(fastq_input_ch)}


def helpMSG() {


log.info"""
        usage examample
        nextflow run mm_flye_assembler.nf 

""".stripIndent()
}
