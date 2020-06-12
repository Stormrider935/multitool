process spades {
      publishDir "${params.output}/${name}/spades/", mode: 'copy', pattern: "assembly_${name}.fasta"
    //   publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}.gfa"
    //   publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}.gv"  
      label 'spades'
    input:
      tuple val(name), file(read)  // val(name) basename von file; file(read) Path to read (ist  das .map von .nf)
    output:
      tuple val(name), file(read), file("assembly_${name}.fasta")//, file("${name}.gfa"), file ("${name}.gv")// dem channel den output hinzufügen damit vers. inputs nicht vertauscht werden wenn prozesse früher fertig sind
    script:
    """
    spades.py -o spades_result --meta --plasmids --nanopore ${read} -s ${read} -t ${task.cpus}
    mv spades_result/contigs.fasta  assembly_${name}.fasta
    """
}
    // meta   (same as metaspades.py)     This flag is recommended when assembling metagenomic data sets 
    // (runs metaSPAdes, see paper for more details). Currently metaSPAdes supports only a single short-read 
    // library which has to be paired-end (we hope to remove this restriction soon). In addition, you can provide 
    // long reads (e.g. using --pacbio or --nanopore options), but hybrid assembly for metagenomes remains an experimental 
    // pipeline and optimal performance is not guaranteed. It does not support careful mode (mismatch correction is not available)