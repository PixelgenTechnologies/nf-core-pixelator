process PIXELATOR_ANALYSIS {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pixelator:0.19.0--pyhdfd78af_0' :
        'biocontainers/pixelator:0.19.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(data)

    output:
    tuple val(meta), path("analysis/*dataset.pxl")  , emit: dataset
    tuple val(meta), path("analysis/*report.json")  , emit: report_json
    tuple val(meta), path("analysis/*.meta.json")   , emit: metadata
    tuple val(meta), path("analysis/*")             , emit: all_results
    tuple val(meta), path("*pixelator-analysis.log"), emit: log

    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''

    """
    pixelator \\
        --cores $task.cpus \\
        --log-file ${prefix}.pixelator-analysis.log \\
        --verbose \\
        single-cell \\
        analysis \\
        --output . \\
        $args \\
        $data

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pixelator: \$(echo \$(pixelator --version 2>/dev/null) | sed 's/pixelator, version //g' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir analysis
    touch "${prefix}.pixelator-analysis.log"
    touch "analysis/${prefix}.dataset.pxl"
    touch "analysis/${prefix}.report.json"
    touch "analysis/${prefix}.meta.json"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pixelator: \$(echo \$(pixelator --version 2>/dev/null) | sed 's/pixelator, version //g' )
    END_VERSIONS
    """
}
