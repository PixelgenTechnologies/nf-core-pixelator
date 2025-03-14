process PIXELATOR_COLLAPSE {
    tag "$meta.id"
    label 'process_medium'
    label 'process_long'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pixelator:0.19.0--pyhdfd78af_0' :
        'biocontainers/pixelator:0.19.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(reads), path(panel_file), val(panel)

    output:
    tuple val(meta), path("collapse/*.collapsed.parquet"), emit: collapsed
    tuple val(meta), path("collapse/*.report.json")      , emit: report_json
    tuple val(meta), path("collapse/*.meta.json")        , emit: metadata
    tuple val(meta), path("*pixelator-collapse.log")     , emit: log

    path "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    assert meta.design != null

    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    def readsArg = reads.join(' ')
    def panelOpt = (
        panel      ? "--panel $panel"      :
        panel_file ? "--panel $panel_file" :
        ""
    )

    """
    pixelator \\
        --cores $task.cpus \\
        --log-file ${prefix}.pixelator-collapse.log \\
        --verbose \\
        single-cell \\
        collapse \\
        --output . \\
        --design ${meta.design} \\
        $panelOpt \\
        $args \\
        $readsArg

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pixelator: \$(echo \$(pixelator --version 2>/dev/null) | sed 's/pixelator, version //g' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir collapse
    touch "${prefix}.pixelator-collapse.log"
    touch "collapse/${prefix}.collapsed.parquet"
    touch "collapse/${prefix}.report.json"
    touch "collapse/${prefix}.meta.json"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pixelator: \$(echo \$(pixelator --version 2>/dev/null) | sed 's/pixelator, version //g' )
    END_VERSIONS
    """
}
