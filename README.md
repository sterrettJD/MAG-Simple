# Simple MAG pipeline using nextflow

## Setup

### Conda Environment
First, let's create a conda environment for the pipeline.
```
conda env create -n mag_simple -f environment.yaml
conda activate mag_simple
```

### Installing NF Core modules
Next, let's install the modules we need from nf-core.
```
cd src
nf-core modules install fastqc
nf-core modules install bowtie2/align
nf-core modules install spades
nf-core modules install prokka
cd ..
```

## Running the pipeline
Here are commands to run the pipeline. Info on the params and metadata files can be found below.
To run the pipeline locally, run:
```
nextflow run ./src -params-file <params.yaml>
```


To run the pipeline on a Slurm-managed cluster, run:
```
nextflow run ./src -params-file <params.yaml> -profile cluster
```

### Metadata
You should provide a metadata CSV file with the following columns:
1. sample_id: string, sample ID name
2. single_end: bool, are reads single or paired?
3. forward: string, filepath to forward reads
4. reverse: string, filepath to forward reads

Here is an example:
```
sample_id,single_end,forward,reverse
sample1,false,./work/reads/sample1_R1.fastq.gz,./work/reads/sample1_R2.fastq.gz
```

### Params YAML
You should pass a YAML-format params file to the pipeline. This should contain the following variables:
1. metadata: filepath to your metadata CSV
2. host_genome: filepath to your host genome FASTA
3. host_index: directory for the host genome bowtie 2 index