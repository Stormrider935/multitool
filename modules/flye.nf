process flye {
      publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}.fasta"
      label 'flye'
    input:
      tuple val(name), file(read)  // val(name) basename von file; file(read) Path to read (ist  das .map von .nf)
    output:
      tuple val(name), file(read), file("${name}.fasta") // dem channel den output hinzufügen damit vers. inputs nicht vertauscht werden wenn prozesse früher fertig sind
    script:
      if (params.meta == '')
      """
      flye --nano-raw ${read} -g {params.g} -m 1500 --t ${task.cpus} -o assembly
      mv assembly/assembly.fasta ${name}.fasta 
      """
      else
      """
      flye --nano-raw ${read} --meta -g ${params.g} -m 1500 --t ${task.cpus} -o assembly
      mv assembly/assembly.fasta ${name}.fasta 
      """
      //  """
      //  echo "test1------${name}" > ${name}.fasta
      //  """
}

//script : befehle im script bzw. inputparameter aus channel geben
