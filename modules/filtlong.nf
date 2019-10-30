process filtlong {
      publishDir "${params.output}/${name}/filtlong/", mode: 'copy', pattern: "${name}_filtered.fastq"
      label 'filtlong'
    input:
      tuple val(name), file(read)  // val(name) basename von file; file(read) Path to read (ist  das .map von .nf)
    output:
      tuple val(name), file(read), file("${name}_filtered.fastq") // dem channel den output hinzufügen damit vers. inputs nicht vertauscht werden wenn prozesse früher fertig sind
    script:
      """
      filtlong --min_length ${params.filterlenght} ${read} > ${name}_filtered.fastq
      """
}


