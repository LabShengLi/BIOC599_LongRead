#!/bin/bash
#SBATCH --job-name=nextflow_demo
#SBATCH -p main
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mem 30G
#SBATCH -t 2-00:00:00
#SBATCH --output=/project/sli68423_1316/users/yang/log/%x.%j.log
#SBATCH --mail-user=yliu8962@usc.edu
#SBATCH --mail-type=FAIL

# deeptools to plot atac peaks at 3 CUT&RUN peak regions

source $(conda info --base)/etc/profile.d/conda.sh
conda activate nextflow2

set -ex

cd /project/sli68423_1316/users/yang/long_read_tutorial/nextflow_demo

# run ok in sbatch with more memory, 1 cpu
nextflow run nf-core/rnaseq -profile test,singularity --outdir test1 --max_cpus 1


exit 0

# ref: https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/slurm-templates.html
srun --pty -p main --time=08:00:00 -n 2 --mem 16GB bash

# ref: https://www.carc.usc.edu/user-guides/advanced-hpc-programming/programming-languages/java.html
module avail jdk

module load openjdk/21.0.0_35

# ref: https://www.nextflow.io/docs/latest/install.html#install-nextflow
curl -s https://get.nextflow.io | bash

./nextflow  -v
nextflow version 24.10.4.5934


# ref: https://nf-co.re/rnaseq/3.18.0/
./nextflow run nf-core/rnaseq -profile test,singularity --outdir test1 --max_cpus 1
