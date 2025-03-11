# Long read sequencing analysis pipeline

## Section 1: Software Installation

### Prerequisite

You must have access to [CARC OnDemand](https://ondemand.carc.usc.edu/pun/sys/dashboard/) and be able to start a Cluster Shell Access session.

![On_Demand_Shell](https://raw.githubusercontent.com/LabShengLi/BIOC599_LongRead/tutorial/pic/ondemand_shell_app.png)

### Enter into interactive mode

**Note**: if you already in compute node mode, you don't need to do this step.

This command starts an interactive session on the cluster with 2 CPU cores and 16GB memory for 2 hours. More information check [Slurm Job documents](https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/slurm-templates.html) in CARC HPC.

```
srun --pty -p main --time=02:00:00 -n 2 --mem 16GB bash
```

**Note: You must enter into the `compute` mode to load/run most of the softwares, instead of the `log` mode.**

---

Create and enter into a directory for this session's work:

```angular2html
wdir="/scratch1/$USER/BIOC599_Software"
mkdir -p $wdir
cd $wdir
pwd
```

### Traditional software installation

Use module load to install:
```angular2html
module purge
module load gcc/13.3.0 openjdk/21.0.0_35 fastqc
```

Use Conda to install:
```angular2html
conda search fastqc
conda install fastqc
```

Verify `fastqc` installation:
```angular2html
fastqc -v
```

Test `fastqc` command on example data:
```angular2html
# copy fastq data into current folder
ln -s /scratch1/yliu8962/BIOC599_Software/Sample1_R1.fastq.gz .

# run fastqc
fastqc Sample1_R1.fastq.gz
```


#### Singularity container
[**Singularity**](https://docs.sylabs.io/guides/3.5/user-guide/introduction.html) is a container technology designed to run applications in a portable and reproducible way, especially in high-performance computing (HPC) environments. Unlike Docker, which often requires administrator (root) privileges, Singularity is built to work securely on shared systems where users do not have root access.

Singularity allows you to package all the necessary software, libraries, and dependencies of a workflow into a single container file. This ensures that your analysis runs the same way on any system, regardless of the underlying operating system or installed software.


![singularity_shema](https://biocorecrg.github.io/PHIND_course_nextflow_Feb_2022/_images/singularity_architecture.png)

<div align="center"> Source: https://tin6150.github.io/psg/blogger_container_hpc.html </div>


#### Run software using Singularity 

Verify Singularity command:
```angular2html
singularity --version
singularity --help
```

Run an `Hello World` program using Singularity:
```angular2html
export LC_ALL=C
singularity exec docker://grycap/cowsay \
    /usr/games/cowsay "Hello Singularity!"
```

Run `fastqc` using Singularity:
```angular2html
export LC_ALL=C
singularity exec docker://biocontainers/fastqc:v0.11.9_cv8 \
    fastqc Sample1_R1.fastq.gz
```

### Nextflow pipeline technology
Nextflow is a workflow management system that enables scalable and reproducible scientific workflows. Before installing Nextflow, make sure Java is installed on your system.

**Reference paper:**

Di Tommaso P, Chatzou M, Floden EW, Barja PP, Palumbo E, Notredame C. Nextflow enables reproducible computational workflows. Nat Biotechnol. 2017 Apr 11;35(4):316-319. doi: 10.1038/nbt.3820. https://pubmed.ncbi.nlm.nih.gov/28398311/


#### Install Java and Nextflow

Nextflow requires Java 8 or higher. You can install it using the following commands, from [HPC with Java documents](https://www.carc.usc.edu/user-guides/advanced-hpc-programming/programming-languages/java.html) in CARC HPC:
```angular2html
module avail jdk
module spider openjdk
module load openjdk/21.0.0_35
```

**Note: You must enter into the `compute` mode to load/run most of softwares, instead of the `log` mode.**

[Nextflow](https://www.nextflow.io/docs/latest/install.html#install-nextflow) can be installed with a single command:
```
curl -s https://get.nextflow.io | bash
```

Verify installation:
```angular2html
./nextflow  -v
```

#### Run Nextflow pipeline for RNAseq analysis 

RNA sequencing (RNA-seq) is a powerful technique used to analyze the transcriptome of a biological sample. It helps researchers understand gene expression levels, identify differentially expressed genes, detect novel transcripts, and study alternative splicing events.  

Processing RNA-seq data typically involves multiple complex steps, such as:
- **Quality control** of raw sequencing reads
- **Read alignment** to a reference genome
- **Quantification** of gene or transcript expression levels
- **Normalization and differential expression analysis**
- **Generation of reports and visualizations**

Manually running each of these steps requires careful coordination of tools, reference data, and settings, which can be time-consuming and error-prone.

#### Why use Nextflow for RNA-seq analysis?  
Nextflow simplifies and automates complex bioinformatics workflows, ensuring:
- **Reproducibility**: Same pipeline can run on different systems (local, cluster, cloud).
- **Scalability**: Easily handles large datasets and parallelizes tasks.
- **Portability**: Supports environments like Docker, Singularity, and Conda for consistent software management.

A popular, community-curated RNA-seq workflow is available through [nf-core](https://nf-co.re/), a collection of high-quality Nextflow pipelines, such as `nf-core/rnaseq`, detail in https://nf-co.re/rnaseq/3.18.0/.

![nf_rnaseq](https://raw.githubusercontent.com/nf-core/rnaseq/3.12.0//docs/images/nf-core-rnaseq_metro_map_grey.png)

#### Running the RNA-seq pipeline on CARC HPC

Verify `nf-core/rnaseq` pipelie:
```angular2html
./nextflow run nf-core/rnaseq --help
```

Help document output:
```angular2html
 N E X T F L O W   ~  version 24.10.4

Launching `https://github.com/nf-core/rnaseq` [gigantic_boltzmann] DSL2 - revision: 33df0c05ef [master]



------------------------------------------------------
                                        ,--./,-.
        ___     __   __   __   ___     /,-._.--~'
  |\ | |__  __ /  ` /  \ |__) |__         }  {
  | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                        `._,._,'
  nf-core/rnaseq v3.16.0-g33df0c0
------------------------------------------------------
Typical pipeline command:

  nextflow run nf-core/rnaseq -profile <docker/singularity/.../institute> --input samplesheet.csv --genome GRCh37 --outdir <OUTDIR>

Input/output options
  --input                            [string]  Path to comma-separated file containing information about the samples in the experiment.
  --outdir                           [string]  The output directory where the results will be saved. You have to use absolute paths to storage on Cloud
                                               infrastructure.
  --email                            [string]  Email address for completion summary.
  --multiqc_title                    [string]  MultiQC report title. Printed as page header, used for filename if not otherwise specified.
```

To check that everything is installed and working correctly, run the RNA-seq pipeline with a small built-in test dataset:

```angular2html
./nextflow run nf-core/rnaseq \
    -profile test,singularity \
    --outdir rnaseq_output --max_cpus 1
```

Output logs:
```angular2html
executor >  local (198)
[b9/a5890a] NFCORE_RNASEQ:PREPARE_GENOME:GUNZIP_GTF (genes_with_empty_tid.gtf.gz)        [100%] 1 of 1 ✔
[25/2743a0] NFCORE_RNASEQ:PREPARE_GENOME:GTF_FILTER (genome.fasta)                       [100%] 1 of 1 ✔
[6b/7c07ac] NFCORE_RNASEQ:PREPARE_GENOME:GUNZIP_ADDITIONAL_FASTA (gfp.fa.gz)             [100%] 1 of 1 ✔
[29/5b1a5f] NFCORE_RNASEQ:PREPARE_GENOME:CUSTOM_CATADDITIONALFASTA (null)                [100%] 1 of 1 ✔
[51/40e1e8] NFCORE_RNASEQ:PREPARE_GENOME:GTF2BED (genome_gfp.gtf)                        [100%] 1 of 1 ✔
......
[1a/866a33] NFCORE_RNASEQ:RNASEQ:DESEQ2_QC_PSEUDO                                        [100%] 1 of 1 ✔
[d2/11ee25] NFCORE_RNASEQ:RNASEQ:MULTIQC (1)                                             [100%] 1 of 1 ✔
-[nf-core/rnaseq] Pipeline completed successfully -
Completed at: 02-Mar-2025 21:53:10
Duration    : 24m 29s
CPU hours   : 0.4
Succeeded   : 198
```

##### Why use Singularity with Nextflow?
- **Reproducibility**: Ensures the same software environment is used every time.
- **Portability**: Easily move workflows between different systems or clusters.
- **No root needed**: Works on servers where Docker may not be available.

##### Example usage in Nextflow:
If a pipeline supports Singularity, you can enable it with the `-profile singularity` option:
```bash
nextflow run nf-core/rnaseq -profile singularity
```
---
## Section 2: Long-read Software

### Installation of long read Nanopore sequencing analysis tools

We will install tools using Conda and Singularity. Firstly, create a folder for tool installation:
```
wdir="/scratch1/$USER/BIOC599_LongRead"
mkdir -p $wdir
cd $wdir
pwd
```

#### Basecall and Methylation call tool: Dorado
Download the **Dorado** container from DockerHub using Singularity.

```
mkdir -p tool
singularity pull --dir tool/ docker://nanoporetech/dorado
```

#### Genetic Variant Call tool: Clair3
Download the **Clair3** container for variant calling.

```
singularity pull --dir tool/ docker://hkubal/clair3
```

#### Verify installation
Run these commands to check if the installed tools are working correctly.

Verify Dorado:
```
singularity exec tool/dorado_latest.sif     dorado -vv
```

Verify Clair3:
```
singularity exec tool/clair3_latest.sif run_clair3.sh --version
```

#### Download basecall and methylation call models for Dorado
Download necessary models for **basecalling** and **methylation detection**.
```
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
```


#### Download Nanopore input files

Download a **POD5 format** demo dataset and link genome reference files.
```
mkdir -p data

# download nanopore input file
online_pod5_file='https://drive.google.com/uc?export=download&id=1fhAYa0uwGnbmeg4vEcFRhmbTxZT4whKG'
pod5_file="data/nanopore_demo_data.pod5"

wget --no-check-certificate ${online_pod5_file}  -O ${pod5_file}

# load genome reference
ln -s /scratch1/yliu8962/shared/hg38_chr11_chr15.fa.fai data/
ln -s /scratch1/yliu8962/shared/hg38_chr11_chr15.fa data/
```

#### Inspect POD5 files

Check the summary of the **POD5** format Nanopore input file:
```
singularity exec tool/dorado_latest.sif \
    pod5 inspect summary ${pod5_file}
```

Check read-level details:
```
singularity exec tool/dorado_latest.sif \
    pod5 inspect reads ${pod5_file}
```

Inspect specific read details:
```
singularity exec tool/dorado_latest.sif \
    pod5 inspect read ${pod5_file}  f84e44c5-15d2-4227-adb7-fb1b206dc128
```
---


## Session 3: Long read basecall and methylation call

### Dorado basecall and methylation call
#### Prerequisite files

Navigate to the working directory:
```
wdir="/scratch1/$USER/BIOC599_LongRead"
mkdir -p $wdir
cd $wdir
pwd
```

Check if required files are available:
```
ls data/
```

**Expected output**
```
hg38_chr11_chr15.fa  hg38_chr11_chr15.fa.fai  nanopore_demo_data.pod5
```

Verify installed tools:
```
ls tool/

```
**Expected output**
```
clair3_latest.sif  dorado_latest.sif  models
```

#### Basecall and methylation call

Run **Dorado** to process the input data:
```
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
```

**Expected output**
```
total 2.5K
-rw-rw-r-- 1 yliu8962 yliu8962 2.7M Jan 31 23:12 calls_2025-02-01_T07-01-17.bam
-rw-rw-r-- 1 yliu8962 yliu8962  47K Jan 31 23:12 calls_2025-02-01_T07-01-17.bam.bai
```


#### IGV visualization of methylation states in BAM file

![IGV Snapshot of KCNQ1](https://raw.githubusercontent.com/LabShengLi/BIOC599_LongRead/tutorial/pic/igv_snapshot_KCNQ1.png)

![IGV Snapshot of SNRPN](https://raw.githubusercontent.com/LabShengLi/BIOC599_LongRead/tutorial/pic/igv_snapshot_SNRPN.png)

---
## Session 4: Haplotype phasing

Run **Clair3** for haplotype phasing, firstly, run Clair3 Variant calling and Phasing:
```
dsname="Human1"
inbam_fn="analysis/dorado_call/calls_2025-01-31_T23-20-55.bam"
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
```

Next, run haplotag for BAM file:
```
singularity exec tool/clair3_latest.sif \
    whatshap --version

singularity exec tool/clair3_latest.sif \
    whatshap  haplotag \
        --ignore-read-groups\
        --reference ${genome}\
        --output-haplotag-list ${tsvFile} \
        -o ${haplotagBamFile} \
        ${phased_vcf_fn}  ${inbam_fn}
```

**Expected output**:
```
Found 1 sample(s) in input VCF
Found 22 sample(s) in BAM file
Found 28 reads covering 114 variants
Found 21 reads covering 95 variants

== SUMMARY ==
Total alignments processed:                        51
Alignments that could be tagged:                   49
Alignments spanning multiple phase sets:            0
Finished in 1.3 s
```

Then, extract **haplotype 1 (HP1)** and **haplotype 2 (HP2)** reads from BAM:
```
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
```

**Expected output**:
```
Total number of reads in haplotag list: 49
Total number of haplo-tagged reads: 49
Total number of untagged reads: 0

== SUMMARY ==
Total reads processed: 51
Number of output reads "untagged": 0
Number of output reads haplotype 1: 29
Number of output reads haplotype 2: 22
Number of unknown (dropped) reads: 0
Number of skipped reads (per user request): 0
Time for processing haplotag list: 0.0 sec
Time for total initial setup: 0.054 sec
Time for iterating input reads: 0.136 sec
Total run time: 0.363 sec
```

```
ls analysis/clair3_phasing/
```
**Expected output**
```
full_alignment.vcf.gz      Human1_split_HP1.bam       merge_output.vcf.gz             pileup.vcf.gz
full_alignment.vcf.gz.tbi  Human1_split_HP2.bam       merge_output.vcf.gz.tbi         pileup.vcf.gz.tbi
haplotag.bam               Human1_split_untagged.bam  phased_merge_output.vcf.gz      run_clair3.log
haplotag.tsv               log                        phased_merge_output.vcf.gz.tbi  tmp
```


#### IGV visualization of haplotype phasing

![IGV Snapshot of MethPhase](https://raw.githubusercontent.com/LabShengLi/BIOC599_LongRead/tutorial/pic/igv_snapshot_methphase.png)
