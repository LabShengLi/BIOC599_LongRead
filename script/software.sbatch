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




ln -s /scratch1/yliu8962/BIOC599_Software/Sample1_R1.fastq.gz .
conda create --name myenv python=3.10


srun --pty -p main --time=02:00:00 -n 2 --mem 16GB bash


singularity exec docker://biocontainers/fastqc:v0.11.9_cv8 fastqc -v



conda create -n py2 python=2.7
conda create -n py3 python=3.11
conda activate py2
# or
conda activate py3


ssh yliu8962@discovery1.usc.edu





module load apptainer
module load openjdk/21.0.0_35
export LC_ALL=C
curl -s https://get.nextflow.io | bash
./nextflow run nf-core/rnaseq \
    -profile test,singularity \
    --outdir rnaseq_test_output --max_cpus 1
