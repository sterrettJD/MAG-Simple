#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { FASTQC } from 'nf-core/fastqc'
include { BOWTIE2 } from 'nf-core/bowtie2'
include { SPADES } from 'nf-core/spades'
include { PROKKA } from 'nf-core/prokka'

workflow {
    params.reads = 'reads/*.fastq.gz' // Default value, can be overridden
    params.host_index = '/path/to/host_index' // Default value, can be overridden

    Channel.fromPath(params.reads)
        | FASTQC(input: it) 
        | BOWTIE2(
            input: it, 
            index: file(params.host_index), 
            unaligned: true
        ) 
        | SPADES(input: it)
        | PROKKA(input: it)
}
