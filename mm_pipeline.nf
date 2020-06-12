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

// dir input or via csv file
    if (params.dir && params.list) { dir_input_ch = Channel
            .fromPath( params.dir, checkIfExists: true )
            .splitCsv()
            .map { row -> [row[0], file("${row[1]}", checkIfExists: true , type: 'dir')] }
            .view() }
    else if (params.dir) { dir_input_ch = Channel
            .fromPath( params.dir, checkIfExists: true, type: 'dir')
            // .map { file -> tuple(file.name, file) }
                }

/************************** 
* MODULES
**************************/
// include centrifuge from './modules/centrifuge'
// include gtdbtk_download_db from './modules/gtdbtkgetdatabase'
include flye from './modules/flye'
include spades from './modules/spades'
include canu from './modules/canu'
include rename_barcodes from './modules/rename_barcodes.nf'
include centrifuge from './modules/centrifuge.nf'
include centrifuge_download_db from './modules/centrifuge_download_db.nf'



/************************** 
* DATABASES
**************************/
workflow centrifuge_database_wf {
    main:
        if (params.centrifuge_db) { database_centrifuge = file( params.centrifuge_db ) }
        else if (!params.cloudProcess) { centrifuge_download_db() ; database_centrifuge = centrifuge_download_db.out}
        else if (params.cloudProcess) { 
            centrifuge_preload = file("gs://databases-nextflow/databases/centrifuge/gtdb_r89_54k_centrifuge.tar")
            if (centrifuge_preload.exists()) { database_centrifuge = centrifuge_preload }   
            else  { centrifuge_download_db()  ; database_centrifuge = centrifuge_download_db.out }
        }
    emit: database_centrifuge
} 



// Sub-workflows



 
workflow flye_wf {
    take: fastq
    main: flye(fastq)
}

workflow spades_wf {
    take: fastq
    main: spades(fastq)
}

workflow canu_wf {
    take: fastq
    main: canu(fastq)
}

workflow centrifuge_wf {
    take:   fastq_input_ch
            centrifuge_DB
    main:   centrifuge(fastq_input_ch,centrifuge_DB) 
    emit:   centrifuge.out.view()
}

workflow rename_barcodes_wf {
    take:   barcode_dir
    main:   rename_barcodes(barcode_dir)                             
    emit:   rename_barcodes.out
                .map { file -> tuple(file.baseName, file)}
                .view()
}




//mainworkflow

workflow {
 // if (params.centrifuge && params.fastq) { centrifuge_wf(fastq_input_ch, centrifuge_database_wf()) }

/*******************
* Assembly workflows
********************/
if (params.flye && params.fastq) { flye_wf(fastq_input_ch) }
if (params.spades && params.fastq) { spades_wf(fastq_input_ch) }
if (params.canu && params.fastq) { canu_wf(fastq_input_ch) }




/*******************
* classification workflows
********************/
//if (params.centrifuge && params.fastq) {centrifuge_wf(fastq_input_ch, centrifuge_database_wf())}
// if (params.dir && centrifuge) {centrifuge_wf(rename_barcodes_wf(dir_input_ch),centrifuge_database_wf()) }
if (params.dir) {rename_barcodes_wf(dir_input_ch)}



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
