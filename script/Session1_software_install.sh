#!/bin/bash
#SBATCH --job-name=Session1
#SBATCH -p main
#SBATCH -N 1 # number of nodes
#SBATCH -n 4 # number of cores
#SBATCH --mem 4GB # memory pool for all cores
#SBATCH -t 1:00:00 # time (D-HH:MM:SS)
#SBATCH --output=%x.%j.log

# Usage: sbatch Session1_software_install.sh

# srun --pty -p main --time=02:00:00 -n 2 --mem 16GB bash

wdir="/scratch1/$USER/BIOC599_LongRead"
mkdir -p $wdir
cd $wdir
pwd

mkdir -p tool

singularity pull --dir tool/ docker://nanoporetech/dorado

singularity pull --dir tool/ docker://hkubal/clair3

singularity exec tool/dorado_latest.sif     dorado -vv

singularity exec tool/clair3_latest.sif run_clair3.sh --version


# download dorado models
dorado_model_dir="$wdir/tool/models"
dorado_base_model="dna_r9.4.1_e8_fast@v3.4"
dorado_meth_model="dna_r9.4.1_e8_fast@v3.4_5mCG@v0.1"

mkdir -p $dorado_model_dir

singularity exec tool/dorado_latest.sif \
    dorado -vv

singularity exec tool/dorado_latest.sif \
    dorado download --model ${dorado_base_model} --models-directory ${dorado_model_dir}

singularity exec tool/dorado_latest.sif \
    dorado download --model ${dorado_meth_model} --models-directory ${dorado_model_dir}

mkdir -p data

# download nanopore input file
online_pod5_file='https://drive.google.com/uc?export=download&id=1fhAYa0uwGnbmeg4vEcFRhmbTxZT4whKG'
pod5_file="data/nanopore_demo_data.pod5"

wget --no-check-certificate ${online_pod5_file}  -O ${pod5_file}

# load genome reference
ln -s /scratch1/yliu8962/shared/hg38_chr11_chr15.fa.fai data/
ln -s /scratch1/yliu8962/shared/hg38_chr11_chr15.fa data/


singularity exec tool/dorado_latest.sif \
    pod5 inspect summary ${pod5_file}

singularity exec tool/dorado_latest.sif \
    pod5 inspect reads ${pod5_file}

singularity exec tool/dorado_latest.sif \
    pod5 inspect read ${pod5_file}  \
    f84e44c5-15d2-4227-adb7-fb1b206dc128

echo "### Session1 Done"
