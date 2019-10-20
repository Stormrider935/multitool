process fastqtofasta {
      publishDir "${params.output}/${name}/fastqtofasta", mode: 'copy', pattern: "${name}.fasta"
      label 'fastqtofasta'
    input:
      set val(name), file(fastq)
    output:
      set val(name), file("${name}.fasta")
    script:
      """
      seqtk seq -a ${fastq} > ${name}.fasta
      """
}