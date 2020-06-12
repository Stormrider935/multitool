process canu {
      publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}.fasta"
    //   publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}.gfa"
    //   publishDir "${params.output}/${name}/flye/", mode: 'copy', pattern: "${name}.gv"  
      label 'canu'
    input:
      tuple val(name), file(read)  
    output:
      tuple val(name), file(read), file("${name}.fasta")
    script:

    """
    canu -p ${name} -d meta useGrid=false genomeSize=${params.size} -nanopore-raw ${read}
    """
}