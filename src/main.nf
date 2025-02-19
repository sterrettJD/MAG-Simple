#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { FASTQC } from './modules/nf-core/fastqc'
include { BOWTIE2_ALIGN } from './modules/nf-core/bowtie2/align'
include { SPADES } from './modules/nf-core/spades'
include { PROKKA } from './modules/nf-core/prokka'

workflow {
    params.host_index = './work/host_index' // Default value, can be overridden
    params.metadata = './work/metadata.csv'   // Path to metadata CSV file

    // Read metadata from CSV
    meta_ch = Channel.fromPath(params.metadata)
                     .splitCsv(header: true, sep: ',')
                     .map { row -> 
                     tuple( 
                        [ id: row.sample_id, 
                        single_end: row.single_end.toBoolean() ],  
                        file(row.forward),  
                        file(row.reverse) ?: null // Handles single-end case
                    ) 
    }

    // Create a meta channel (metadata for each sample)
    reads_ch = meta_ch.map { meta, fwd, rev -> tuple(fwd, rev) }
    pure_meta = meta_ch.map { meta, fwd, rev -> meta }
    
    // FASTQC analysis
    FASTQC(reads_ch)

    // Pass the required inputs to BOWTIE2_ALIGN
    BOWTIE2_ALIGN(
        pure_meta,            // Metadata (sample ID, single_end flag)
        reads_ch,           // FASTQ reads
        file(params.host_index), // Bowtie2 index
        true,               // Output unaligned reads
        false               // Do not sort BAM
    )

/*

        | SPADES(input: it)
        | PROKKA(input: it)
    */
}
