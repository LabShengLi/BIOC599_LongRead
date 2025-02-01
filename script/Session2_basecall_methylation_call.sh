#!/bin/bash
#SBATCH --job-name=Session2
#SBATCH -p main
#SBATCH -N 1 # number of nodes
#SBATCH -n 4 # number of cores
#SBATCH --mem 16GB # memory pool for all cores
#SBATCH -t 1:00:00 # time (D-HH:MM:SS)
#SBATCH --output=%x.%j.log

# Usage: sbatch Session2_basecall_methylation_call.sh

# srun --pty -p main --time=02:00:00 -n 2 --mem 16GB bash

wdir="/scratch1/$USER/BIOC599_LongRead"
mkdir -p $wdir
cd $wdir
pwd

ls data/
ls tool/

indir="$wdir/data/"
genome="$wdir/data/hg38_chr11_chr15.fa"

dorado_model_dir="$wdir/tool/models"
dorado_base_model="dna_r9.4.1_e8_fast@v3.4"
dorado_meth_model="dna_r9.4.1_e8_fast@v3.4_5mCG@v0.1"

export SINGULARITY_BIND="/project,/scratch1"

mkdir -p analysis/dorado_call

singularity exec tool/dorado_latest.sif \
    dorado basecaller \
        ${dorado_model_dir}/$dorado_base_model \
        $indir/ \
        --modified-bases-models ${dorado_model_dir}/${dorado_meth_model} \
        -x auto --verbose \
        --reference $genome \
        --output-dir analysis/dorado_call \
        --batchsize 8

ls -lh analysis/dorado_call/

echo "### Session2 Done"
