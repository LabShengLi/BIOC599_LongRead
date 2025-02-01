#!/bin/bash
#SBATCH --job-name=Session3
#SBATCH -p main
#SBATCH -N 1 # number of nodes
#SBATCH -n 4 # number of cores
#SBATCH --mem 4GB # memory pool for all cores
#SBATCH -t 1:00:00 # time (D-HH:MM:SS)
#SBATCH --output=%x.%j.log

# Usage: sbatch Session3_haplotype_phasing.sh

# srun --pty -p main --time=02:00:00 -n 2 --mem 16GB bash

wdir="/scratch1/$USER/BIOC599_LongRead"
mkdir -p $wdir
cd $wdir
pwd

dsname="Human1"
inbam_fn=$(ls -t analysis/dorado_call/calls_*.bam | head -n 1)
genome="$wdir/data/hg38_chr11_chr15.fa"
outdir="analysis/clair3_phasing"

CLAIR3_MODEL_NAME="/opt/models/r941_prom_hac_g360+g422"

cpus=4

# intermediate files
phased_vcf_fn="${outdir}/phased_merge_output.vcf.gz"
tsvFile="${outdir}/haplotag.tsv"
haplotagBamFile="${outdir}/haplotag.bam"

export SINGULARITY_BIND="/project,/scratch1"

mkdir -p $outdir
singularity exec tool/clair3_latest.sif \
    run_clair3.sh \
        --sample_name=${dsname} \
          --bam_fn=${inbam_fn} \
          --ref_fn=${genome} \
          --threads=${cpus} \
          --platform="ont" \
          --model_path="${CLAIR3_MODEL_NAME}" \
          --enable_phasing \
          --output=$outdir \
          --ctg_name=chr11,chr15


singularity exec tool/clair3_latest.sif \
    whatshap --version

singularity exec tool/clair3_latest.sif \
    whatshap  haplotag \
        --ignore-read-groups\
        --reference ${genome}\
        --output-haplotag-list ${tsvFile} \
        -o ${haplotagBamFile} \
        ${phased_vcf_fn}  ${inbam_fn}

# Extract h1 and h2 haplotype reads
singularity exec tool/clair3_latest.sif \
whatshap split \
    --output-h1 ${outdir}/${dsname}_split_HP1.bam \
    --output-h2 ${outdir}/${dsname}_split_HP2.bam \
    --output-untagged ${outdir}/${dsname}_split_untagged.bam  \
    ${inbam_fn} \
    ${tsvFile}

# Index haplotype BAM files:
singularity exec tool/clair3_latest.sif \
    samtools index -@ ${cpus} ${outdir}/${dsname}_split_HP1.bam

singularity exec tool/clair3_latest.sif \
    samtools index -@ ${cpus} ${outdir}/${dsname}_split_HP2.bam

ls analysis/clair3_phasing/

echo "### Session3 Done"
