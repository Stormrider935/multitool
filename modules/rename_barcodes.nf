process rename_barcodes {
    publishDir "${params.output}/", mode: 'copy', pattern: "${barcode_dir}/*.fastq"
      label 'ubuntu'
    input:
        path(barcode_dir)
    output:
        file("${barcode_dir}/*.fastq")
    script:
    """
    
    cd ${barcode_dir} && \
    for subdir in barcode* ; do cat \$subdir/*.fastq > \$subdir.fastq; done;
    while IFS=, read orig new; do mv "\$orig" "\$new.fastq"; done < ${params.rename}
    """
}

// wie muss die rename barcode file aussehen
// barcode1.fastq,testfile1
// barcode2.fastq,testfile2

