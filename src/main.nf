#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { FASTQC } from './modules/nf-core/fastqc'
include { BOWTIE2_ALIGN } from './modules/nf-core/bowtie2/align'
include { SPADES } from './modules/nf-core/spades'
include { PROKKA } from './modules/nf-core/prokka'

workflow {
    // Read metadata from CSV
    meta_ch = Channel.fromPath(params.metadata)
                     .splitCsv(header: true, sep: ',')
                     .map { row -> 
                     tuple( 
                        [ id: row.sample_id, 
                        single_end: row.single_end.toBoolean() ],  
                        [file(row.forward),  file(row.reverse)]
                    ) 
    }

    // Create a meta channel (metadata for each sample)
    reads_ch = meta_ch.map { meta, files -> files }
    pure_meta = meta_ch.map { meta, files -> meta }
    
    // FASTQC analysis
    FASTQC(meta_ch)

    // Pass the required inputs to BOWTIE2_ALIGN
    BOWTIE2_ALIGN(
        meta_ch,            // Metadata (sample ID, single_end flag)
        [pure_meta, file(params.host_index)], // Bowtie2 index
        [pure_meta, file(params.host_genome)], // Host FASTA
        true,               // Output unaligned reads
        false               // Do not sort BAM
    )

/*

        | SPADES(input: it)
        | PROKKA(input: it)
    */
}
