process PIXELATOR_LIST_OPTIONS {
    label 'process_single'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pixelator:0.19.0--pyhdfd78af_0' :
        'biocontainers/pixelator:0.19.0--pyhdfd78af_0' }"

    output:
    path "design_options.txt"     , emit: designs
    path "panel_options.txt"      , emit: panels
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''

    """
    pixelator single-cell --list-designs $args > design_options.txt
    pixelator single-cell --list-panels $args2 > panel_options.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pixelator: \$(echo \$(pixelator --version 2>/dev/null) | sed 's/pixelator, version //g' )
    END_VERSIONS
    """

    stub:
    """
    cat <<-END_DESIGN > design_options.txt
    D21
    END_DESIGN

    cat <<-END_PANELS > panel_options.txt
    human-sc-immunology-spatial-proteomics-1
    human-sc-immunology-spatial-proteomics-2
    human-sc-immunology-spatial-proteomics
    END_PANELS

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pixelator: \$(echo \$(pixelator --version 2>/dev/null) | sed 's/pixelator, version //g' )
    END_VERSIONS
    """
}
