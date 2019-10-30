process spades {
      publishDir "${params.output}/${name}/spades/", mode: 'copy', pattern: "${name}.fasta"
      label 'spades'
    input:
      tuple val(name), file(read)  // val(name) basename von file; file(read) Path to read (ist  das .map von .nf)
    output:
      tuple val(name), file(read), file("${name}.fasta") // dem channel den output hinzufügen damit vers. inputs nicht vertauscht werden wenn prozesse früher fertig sind
    script:
      """
      spades.py -s ${read} -o assembly
      mv assembly/assembly.fasta ${name}.fasta 
      """
}