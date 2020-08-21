process baloonplot {
      label 'baloonplot'
    input:
      tuple val(name), file(bandage)  // val(name) basename von file; file(read) Path to read (ist  das .map von .nf)
    output:
      tuple val(name), file(bandage), file("${name}.svg") // dem channel den output hinzufügen damit vers. inputs nicht vertauscht werden wenn prozesse früher fertig sind
    script:
    """
    combine_bloonplot_centrifuge.sh

    baloonrplot_coverage_count.R
    """