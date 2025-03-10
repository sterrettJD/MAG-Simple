#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { FASTP } from './modules/nf-core/fastp/main'
include { FASTQC } from './modules/nf-core/fastqc'
include { BOWTIE2_ALIGN } from './modules/nf-core/bowtie2/align'
include { MEGAHIT } from './modules/nf-core/megahit/main'
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
    
    // Trim adapters and low quality regions from reads
    FASTP(meta_ch, 
          file(params.adapters),
          false,
          false,
          false)
    
    // FASTQC on trimmed reads
    FASTQC(FASTP.out.reads)

    // Align trimmed reads to host genome
    BOWTIE2_ALIGN(
        FASTP.out.reads,
        [pure_meta, file(params.host_index)], // Bowtie2 index
        [pure_meta, file(params.host_genome)], // Host FASTA
        true,               // Output unaligned reads
        false               // Do not sort BAM
    )

/*

        MEGAHIT()
        PROKKA()
    */
}
