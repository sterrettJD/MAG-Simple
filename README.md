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
To run the pipeline locally, run:
```
nextflow run main.nf
```


To run the pipeline on a Slurm-managed cluster, run:
```
nextflow run main.nf -profile cluster
```

