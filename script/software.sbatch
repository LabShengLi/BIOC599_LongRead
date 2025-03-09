#!/bin/bash

module avail fastqc
module load fastqc

conda search fastqc
conda install fastqc


fastqc --version
fastqc --help

fastqc Sample1.fastq.gz



module purge
module load conda

mamba init bash
source ~/.bashrc


singularity --version
singularity --help

singularity exec \
    docker://grycap/cowsay \
    /usr/games/cowsay "Hello World"


export LC_ALL=C

singularity exec \
    docker://grycap/cowsay \
    /usr/games/cowsay "Hello Singularity!"


singularity pull docker://grycap/cowsay
singularity run docker://grycap/cowsay
singularity exec docker://grycap/cowsay /usr/games/cowsay "Hello Singularity!"
singularity shell docker://grycap/cowsay


curl -s https://get.nextflow.io | bash
./nextflow -v



curl -s https://get.nextflow.io | bash

./nextflow  -v

./nextflow run nf-core/rnaseq \
    -profile test,singularity \
    --outdir rnaseq_test_output --max_cpus 1
