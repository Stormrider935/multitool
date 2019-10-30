process fastqtofasta {
      publishDir "${params.output}/${name}/fastqtofasta", mode: 'copy', pattern: "${name}.fasta"
      label 'fastqtofasta'
    input:
      tuple val(name), file(fastq)
    output:
      tuple val(name), file("${name}.fasta")
    script:
      """
      seqtk seq -a ${fastq} > ${name}.fasta
      """
}