process flye {
      publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}.fasta"
      publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}_graph.gfa"
      publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}_graph.gv"  
      label 'flye'
    input:
      tuple val(name), file(read)  // val(name) basename von file; file(read) Path to read (ist  das .map von .nf)
    output:
      tuple val(name), file(read), file("${name}.fasta"), file("${name}_graph.gfa"), file ("${name}_graph.gv")// dem channel den output hinzufügen damit vers. inputs nicht vertauscht werden wenn prozesse früher fertig sind
    script:
    //example github
    """
    flye --nano-raw ${read} --genome-size ${params.size} -t ${params.cores}  --meta --plasmids -o flye_output 

    mv flye_output/assembly.fasta ${name}.fasta
    mv flye_output/assembly_*.gfa ${name}_graph.gfa
    mv flye_output/assembly_*.gv ${name}_graph.gv
    """


      // if (params.meta == '')
      // """
      // flye --nano-raw ${read} -g {params.g} -m 1500 --t ${task.cpus} -o assembly
      // mv assembly/assembly.fasta ${name}.fasta 
      // """
      // // else
      // // """
      // flye --nano-raw ${read} --meta -g ${params.g} -m 1500 --t ${task.cpus} -o assembly
      // mv assembly/assembly.fasta ${name}.fasta 
      // """
      // //  """
      // //  echo "test1------${name}" > ${name}.fasta
      // //  """
}

//script : befehle im script bzw. inputparameter aus channel geben
