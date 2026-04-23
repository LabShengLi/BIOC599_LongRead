# Long read sequencing analysis pipeline

## Section 1: Software Installation

### Prerequisite

You must have access to [CARC OnDemand](https://ondemand.carc.usc.edu/pun/sys/dashboard/) and be able to start a Cluster Shell Access session.

![On_Demand_Shell](https://raw.githubusercontent.com/LabShengLi/BIOC599_LongRead/tutorial/pic/ondemand_shell_app.png)

### Enter into interactive mode

**Note**: if you already in compute node mode, you don't need to do this step.

This command starts an interactive session on the cluster with multiple CPU cores and memory. More information check [Slurm Job documents](https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/slurm-templates.html) in CARC HPC.

```
## srun --pty -p main --time=02:00:00 -n 2 --mem 8GB bash
salloc -p debug -c 4
```

**Note: You must enter into the `compute` (`interactive`) mode to load/run most of the software, instead of the `log` mode.**

---

Create and enter into a directory for this session's work:

```angular2html
basedir="/project2/rhie_131/bioc599/shared/long_read_nanome/inclass_activity"
wdir="$basedir/${USER}_results"
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
ln -s /project2/rhie_131/bioc599/shared/long_read_nanome/software_install/Sample1_R1.fastq.gz .

# run fastqc
fastqc Sample1_R1.fastq.gz
```


#### Singularity container
[**Singularity**](https://docs.sylabs.io/guides/3.5/user-guide/introduction.html) is a container technology designed to run applications in a portable and reproducible way, especially in high-performance computing (HPC) environments. Unlike Docker, which often requires administrator (root) privileges, Singularity is built to work securely on shared systems where users do not have root access.

Singularity allows you to package all the necessary software, libraries, and dependencies of a workflow into a single container file. This ensures that your analysis runs the same way on any system, regardless of the underlying operating system or installed software.


![singularity_shema](https://biocorecrg.github.io/PHIND_course_nextflow_Feb_2022/_images/singularity_architecture.png)

<div align="center"> Source: https://tin6150.github.io/psg/blogger_container_hpc.html </div>


#### Run software using Singularity 

Load singularity from HPC:
```angular2html
module load apptainer
```

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
singularity exec -B /project2 docker://biocontainers/fastqc:v0.11.9_cv8 \
    fastqc Sample1_R1.fastq.gz
```

### Nextflow pipeline technology
Nextflow is a workflow management system that enables scalable and reproducible scientific workflows. Before installing Nextflow, make sure Java is installed on your system.

**Reference paper:**

Di Tommaso P, Chatzou M, Floden EW, Barja PP, Palumbo E, Notredame C. Nextflow enables reproducible computational workflows. Nat Biotechnol. 2017 Apr 11;35(4):316-319. doi: 10.1038/nbt.3820. https://pubmed.ncbi.nlm.nih.gov/28398311/


#### Install Java and Nextflow

Nextflow requires Java 8 or higher. You can install it using the following commands, from [HPC with Java documents](https://www.carc.usc.edu/user-guides/advanced-hpc-programming/programming-languages/java.html) in CARC HPC:
```angular2html
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

Module load methods:
```
module purge
module load ver/2506  gcc/14.3.0 openjdk/21.0.7_6 nextflow/25.04.8 apptainer
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
nextflow run nf-core/rnaseq --help
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
module load apptainer
nextflow run nf-core/rnaseq \
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

### Enter into interactive mode

**Note**: if you already in compute node mode, you don't need to do this step.

This command starts an interactive session on the cluster with multiple CPU cores and memory. More information check [Slurm Job documents](https://www.carc.usc.edu/user-guides/hpc-systems/using-our-hpc-systems/slurm-templates.html) in CARC HPC.

```
## srun --pty -p gpu --time=02:00:00 -n 8 --mem 32GB --gres=gpu:v100:1 bash  
## srun --pty -p main --time=02:00:00 -n 8 --mem 32GB bash
salloc -p debug -c 8 --mem 64GB --time=01:00:00
```

**Note: You must enter into the `compute` (`interactive`) mode to load/run most of the software, instead of the `log` mode.**

### Installation of long read Nanopore sequencing analysis tools

We will install tools using Conda and Singularity. Firstly, create a folder for tool installation:
```
basedir="/project2/rhie_131/bioc599/shared/long_read_nanome/inclass_activity"
wdir="$basedir/${USER}_results"
mkdir -p $wdir
cd $wdir
pwd
```

#### Basecall and Methylation call tool: Dorado
Download the **Dorado** container from DockerHub using Singularity.

```
module load apptainer

mkdir -p tool
singularity pull -F --dir tool/ docker://nanoporetech/dorado
```

Download the **Modkit** container from DockerHub using Singularity.

```
module load apptainer

mkdir -p tool
singularity pull --dir tool/ docker://ontresearch/modkit
```

#### Genetic Variant Call tool: Clair3
Download the **Clair3** container for variant calling.

```
module load apptainer

mkdir -p tool
singularity pull --dir tool/ docker://hkubal/clair3
```

#### Verify installation
Run these commands to check if the installed tools are working correctly.

Verify Dorado:
```
module load apptainer
dorado_image=/project2/rhie_131/bioc599/shared/long_read_nanome/singularity/dorado_latest.sif
singularity exec ${dorado_image} \
    dorado -vv
```

Verify Clair3:
```
clair3_image=/project2/rhie_131/bioc599/shared/long_read_nanome/singularity/clair3_latest.sif
singularity exec  ${clair3_image} \
    run_clair3.sh --version
```

Verify ModKit:
```
modkit=/project2/rhie_131/bioc599/shared/long_read_nanome/singularity/modkit_latest.sif
singularity exec $modkit \
    modkit -V
```

#### Download basecall and methylation call models for Dorado
Download necessary models for **basecalling** and **methylation detection**.
```
# download dorado models
dorado_model_dir="$wdir/tool/models"
dorado_base_model="dna_r9.4.1_e8_fast@v3.4"
dorado_meth_model="dna_r9.4.1_e8_fast@v3.4_5mCG@v0.1"

mkdir -p $dorado_model_dir

singularity exec ${dorado_image}  \
    dorado -vv

singularity exec ${dorado_image}  \
    dorado download --model ${dorado_base_model} --models-directory ${dorado_model_dir}

singularity exec ${dorado_image} \
    dorado download --model ${dorado_meth_model} --models-directory ${dorado_model_dir}
    
ls tool/models/
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
cp /project2/rhie_131/bioc599/shared/long_read_nanome/BIOC599_LongRead/data/hg38_chr11_chr15.fa.fai data/
cp /project2/rhie_131/bioc599/shared/long_read_nanome/BIOC599_LongRead/data/hg38_chr11_chr15.fa data/

ls data/
```

#### Inspect POD5 files

Check the summary of the **POD5** format Nanopore input file:
```
singularity exec ${dorado_image} \
    pod5 inspect summary ${pod5_file}
```

Check read-level details:
```
singularity exec ${dorado_image} \
    pod5 inspect reads ${pod5_file} | head
```

Inspect specific read details:
```
singularity exec ${dorado_image} \
    pod5 inspect read ${pod5_file}  f84e44c5-15d2-4227-adb7-fb1b206dc128
```
---


## Session 3: Long read basecall and methylation call

### Dorado basecall and methylation call
#### Prerequisite files

Navigate to the working directory:
```
basedir="/project2/rhie_131/bioc599/shared/long_read_nanome/inclass_activity"
wdir="$basedir/${USER}_results"
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
<!--
Verify installed tools:
```
ls tool/

```
**Expected output**
```
clair3_latest.sif  dorado_latest.sif  models
```
-->


#### Basecall and methylation call

Run **Dorado** to process the input data:
```
indir="$wdir/data/"
genome="$wdir/data/hg38_chr11_chr15.fa"

dorado_model_dir="$wdir/tool/models"
dorado_base_model="dna_r9.4.1_e8_fast@v3.4"
dorado_meth_model="dna_r9.4.1_e8_fast@v3.4_5mCG@v0.1"

export SINGULARITY_BIND="/project2"

mkdir -p analysis/dorado_call

singularity exec --nv ${dorado_image} \
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


Convert BAM file into BED file format using Modkit:
```angular2html
inbam_fn=$(ls analysis/dorado_call/calls_*.bam  | head -n 1)
echo $inbam_fn

singularity exec $modkit \
    modkit pileup  $inbam_fn analysis/dorado_call/calls_dorado_5mC.bed

head analysis/dorado_call/calls_dorado_5mC.bed
```

Output like below:
```
chr11	2626572	2626573	m	1	+	2626572	2626573	255,0,0	1	100.00	1	0	0	0	00	0
chr11	2626659	2626660	m	1	+	2626659	2626660	255,0,0	1	0.00	0	1	0	0	00	0
chr11	2627308	2627309	m	1	+	2627308	2627309	255,0,0	1	0.00	0	1	0	0	00	0
chr11	2627392	2627393	m	1	+	2627392	2627393	255,0,0	1	100.00	1	0	0	0	00	0
```

Convert BAM file into FASTQ file using samtools:
```angular2html
inbam_fn=$(ls analysis/dorado_call/calls_*.bam  | head -n 1)
echo $inbam_fn

singularity exec $dorado_image \
    samtools fastq $inbam_fn | gzip > analysis/dorado_call/dorado_call.fastq.gz
```

Summary BAM files using Dorado:
```
singularity exec $dorado_image \
    dorado summary $inbam_fn | gzip -f > analysis/dorado_call/dorado_call_sequencing_summary.txt.gz
```

Example output:

```
filename	read_id	run_id	channel	mux	start_time	duration	template_start	template_duration	sequence_length_template	mean_qscore_template	barcode	alignment_genome	alignment_genome_start	alignment_genome_end	alignment_strand_start	alignment_strand_end	alignment_direction	alignment_length	alignment_num_aligned	alignment_num_correct	alignment_num_insertions	alignment_num_deletions	alignment_num_substitutions	alignment_mapq	alignment_strand_coverage	alignment_identity	alignment_accuracy	alignment_bed_hits
nanopore_demo_data.pod5	c852c023-958b-482e-89b3-1069a2dd52da	098c8278671ebb3df841b55ae73e7b7ca551ae8f	239	239631.6	297.494	39631.8	297.351	120484	10.0182	unclassified	chr11	2626537	2749302	26	120484	+	125985	117238	113071	3220	5527	4167	60	0.999784	0.964457	0.897496	0
nanopore_demo_data.pod5	85cf7c07-b4f3-4e14-817b-aefc31eaa130	067f8be7e5b4cac3170a36762e4878ba47eded20	112	12745.78	174.008	2745.8	173.986	72009	12.2644	unclassified	chr11	2631461	2704227	10	71995	-	73842	70909	69693	1076	1857	1216	60	0.999667	0.982851	0.943812	0
```

#### IGV visualization of methylation states in BAM file

Open OnDemand Traveller Desktop, start IGV Viewer, load BAM files to visualize methylation reads in _KCNQ1_ and _SNURF_ gene regions.


![IGV Snapshot of KCNQ1](https://raw.githubusercontent.com/LabShengLi/BIOC599_LongRead/tutorial/pic/igv_snapshot_KCNQ1.png)


![IGV Snapshot of SNRPN](https://raw.githubusercontent.com/LabShengLi/BIOC599_LongRead/tutorial/pic/igv_snapshot_SNRPN.png)

---



## Session 4: Haplotype phasing

Run **Clair3** for haplotype phasing, firstly, run Clair3 Variant calling and Phasing:
```
dsname="Human1"
inbam_fn=$(ls analysis/dorado_call/calls_*.bam  | head -n 1)
genome="$wdir/data/hg38_chr11_chr15.fa"
outdir="analysis/clair3_phasing"

CLAIR3_MODEL_NAME="/opt/models/r941_prom_hac_g360+g422"

cpus=4

# intermediate files
phased_vcf_fn="${outdir}/phased_merge_output.vcf.gz"
tsvFile="${outdir}/haplotag.tsv"
haplotagBamFile="${outdir}/haplotag.bam"

export SINGULARITY_BIND="/project2"

mkdir -p $outdir
singularity exec ${clair3_image} \
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
singularity exec ${clair3_image}  \
    whatshap --version

singularity exec ${clair3_image} \
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
singularity exec ${clair3_image} \
whatshap split \
    --output-h1 ${outdir}/${dsname}_split_HP1.bam \
    --output-h2 ${outdir}/${dsname}_split_HP2.bam \
    --output-untagged ${outdir}/${dsname}_split_untagged.bam  \
    ${inbam_fn} \
    ${tsvFile}

# Index haplotype BAM files:
singularity exec ${clair3_image} \
    samtools index -@ ${cpus} ${outdir}/${dsname}_split_HP1.bam

singularity exec ${clair3_image} \
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

## Session 5: Run the Nanome pipeline for phasing

This section describes how to run the Nanome pipeline in phasing mode using Nextflow with the Singularity/Apptainer profile. The command below loads the required modules, prepares a clean run directory, sets the local Singularity cache, and launches the workflow for a Dorado-based BAM input against the hg38 reference.

Preparation script
```
## srun --pty -p main --time=02:00:00 -n 4 --mem 20GB bash
salloc -p debug -c 4 --mem=20G

WDIR="/project2/rhie_131/bioc599/shared/long_read_nanome/homework/run_nanome_cmd_${USER}"
```

Example script
```
module purge
module load ver/2506  gcc/14.3.0 openjdk/21.0.7_6 nextflow/25.04.8

date
hostname
pwd

module load apptainer

rm -rf $WDIR
mkdir -p $WDIR
cd $WDIR

export NXF_SINGULARITY_CACHEDIR=/project2/rhie_131/bioc599/shared/long_read_nanome/local_singularity_cache

nextflow pull LabShengLi/nanome -r rev6

nextflow run LabShengLi/nanome -r rev6 -resume\
    -profile singularity \
    --dsname hg002 \
    --input_bam  --dorado \
    --input /project2/rhie_131/bioc599/shared/long_read_nanome/in_bam \
    --genome /project2/rhie_131/bioc599/shared/long_read_nanome/hg38 \
    --phasing --cpu_processors 4 \
    --singularity_cache ${NXF_SINGULARITY_CACHEDIR}
```

### Argument description

- `module purge`  
  Clears all previously loaded environment modules to avoid software conflicts.

- `module load ver/2506 gcc/14.3.0 openjdk/21.0.7_6 nextflow/25.04.8`  
  Loads the required software stack, including Java and Nextflow.

- `module load apptainer`  
  Loads Apptainer, which is used by the `singularity` execution profile.

- `date`, `hostname`, `pwd`  
  Print the current date, hostname, and working directory for logging and troubleshooting.

- `set -ex`  
  Enables strict shell execution.  
  - `-e`: stop immediately if a command fails  
  - `-x`: print each command before execution

- `rm -rf /project2/rhie_131/bioc599/shared/long_read_nanome/run_nanome_cmd`  
  Removes the previous run directory to start from a clean workspace.

- `mkdir -p /project2/rhie_131/bioc599/shared/long_read_nanome/run_nanome_cmd`  
  Creates the run directory.

- `cd /project2/rhie_131/bioc599/shared/long_read_nanome/run_nanome_cmd`  
  Changes into the run directory where the workflow will be executed.

- `export NXF_SINGULARITY_CACHEDIR=/project2/rhie_131/bioc599/shared/long_read_nanome/local_singularity_cache`  
  Defines the local cache directory for Singularity/Apptainer images used by Nextflow.

- `nextflow run $NanomeDir`  
  Runs the Nanome workflow located at the path stored in `$NanomeDir`.

- `-resume`  
  Reuses cached results from previous successful runs, which is helpful for restarting interrupted workflows.

- `-profile singularity`  
  Uses the `singularity` profile to run the workflow inside Apptainer/Singularity containers.

- `--dsname hg002`  
  Sets the dataset name to `hg002`. This name is typically used in output directories and output file prefixes.

- `--input_bam`  
  Indicates that the workflow input is BAM-based. This option should be kept only if the pipeline defines it as a boolean flag.

- `--dorado`  
  Indicates that the BAM input was generated from a Dorado-based workflow, or enables Dorado-specific processing depending on the pipeline implementation.

- `--input /project2/rhie_131/bioc599/shared/long_read_nanome/in_bam`  
  Specifies the input directory containing the BAM files.

- `--genome /project2/rhie_131/bioc599/shared/long_read_nanome/hg38`  
  Specifies the reference genome directory for hg38.

- `--phasing`  
  Enables the phasing branch of the Nanome pipeline.

- `--cpu_processors 4`  
  Sets the number of CPU processors to 4 for workflow steps that use this parameter.

- `--singularity_cache ${NXF_SINGULARITY_CACHEDIR}`  
  Passes the Singularity cache directory to the pipeline as a workflow parameter.

### Notes

- `NXF_SINGULARITY_CACHEDIR` is a Nextflow engine-level setting, while `--singularity_cache` is a pipeline-level parameter. In this example, both point to the same cache directory.

- The combination `--input_bam --dorado` is valid only if both are defined as boolean flags in the workflow. If `--input_bam` expects a file path or other value, the command should be adjusted accordingly.

- If the workflow reports errors such as `Process requirement exceeds available CPUs`, the local executor CPU limit may need to be increased in `nextflow.config`, for example:

```groovy
executor {
    cpus = 8
}
```

Expected outputs:

```
Nextflow 25.10.4 is available - Please consider updating your version to it

 N E X T F L O W   ~  version 25.04.8

WARN: It appears you have never run this project before -- Option `-resume` is ignored
Launching `/project2/sli68423_1316/users/yang/workspace/nanome/main.nf` [peaceful_ochoa] DSL2 - revision: 1b3231db17

NANOME - NF PIPELINE (v2.0.0)
by Sheng Li Lab
https://github.com/LabShengLi/nanome
=================================
dsname              : hg002
input               : /project2/rhie_131/bioc599/shared/long_read_nanome/in_bam
genome              : /project2/rhie_131/bioc599/shared/long_read_nanome/hg38

Running settings   : --------
processors          : 2
chrSet              : chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY
dataType            : human
runBasecall         : Yes
runNanopolish       : Yes
runMegalodon        : Yes
runDeepSignal       : Yes
runNANOME           : Yes
tomboResquiggleOptions: --signal-length-range 0 500000  --sequence-length-range 0 50000
outputBam           : true
outputRaw           : true
phasing             : true

Model summary      : --------
GUPPY_BASECALL_MODEL: dna_r9.4.1_450bps_hac.cfg
NANOME_MODEL/CS_MODEL_FILE: nanome_cs/xgboost_basic_w
MEGALODON_MODEL     : Remora:dna_r9.4.1_e8
DEEPSIGNAL2_MODEL_FILE/DEEPSIGNAL2_MODEL_NAME: https://storage.googleapis.com/jax-nanopore-01-project-data/nanome-input/model.dp2.CG.R9.4_1D.human_hx1.bn17_sn16.both_bilstm.b17_s16_epoch4.ckpt.tar.gz/model.dp2.CG.R9.4_1D.human_hx1.bn17_sn16.both_bilstm.b17_s16_epoch4.ckpt
DORADO_BASECALL_MODEL: dna_r10.4.1_e8.2_400bps_hac@v5.0.0
DORADO_METHCALL_MODEL: dna_r10.4.1_e8.2_400bps_hac@v5.0.0_5mCG_5hmCG@v3

Pipeline settings  : --------
Working dir         : /project2/rhie_131/bioc599/shared/long_read_nanome/run_nanome_cmd/work
Output dir          : results
Launch dir          : /project2/rhie_131/bioc599/shared/long_read_nanome/run_nanome_cmd
Script dir          : /project2/sli68423_1316/users/yang/workspace/nanome
User                : yliu8962
Profile             : singularity
Config files        : /project2/sli68423_1316/users/yang/workspace/nanome/nextflow.config
Container           : singularity - [UNTAR|DORADO_UNTAR:docker://liuyangzzu/nanome:v1.4, Tombo|DeepMod|METEORE:docker://liuyangzzu/nanome:v1.4, CLAIR3|CLAIR3_dorado:docker://hkubal/clair3:latest, DEEPSIGNAL2:docker://liuyangzzu/deepsignal2:v1.0, Guppy6|DORADO_CALL_EXTRACT:docker://liuyangzzu/guppy_stable:v6.3.8, DORADO_CALL|DORADO_DEMUX:docker://nanoporetech/dorado:sha268dcb4cd02093e75cdc58821f8b93719c4255ed, default:docker://liuyangzzu/nanome:v2.0.6]
errorStrategy       : ignore
maxRetries          : 5
=================================
executor >  local (5)
[85/34b1db] ENVCHECK (hg002)               | 1 of 1 ✔
[fa/f6bd20] DORADO_QC (hg002)              | 1 of 1 ✔
[81/4fb6a1] DORADO_CALL_EXTRACT (per_read) | 1 of 1 ✔
[65/aa6471] UNIFY (all)                    | 1 of 1 ✔
[8e/775eb1] CLAIR3_dorado (hg002)                       | 1 of 1 ✔
[78/949738] DORADO_CALL_EXTRACT_POST_HP1 (per_read_HP1) | 1 of 1 ✔
[30/6264cd] DORADO_CALL_EXTRACT_POST_HP2 (per_read_HP2) | 1 of 1 ✔
[8f/a659de] UNIFY_POST_HP1 (HP1)                        | 1 of 1 ✔
[b1/f0c091] UNIFY_POST_HP2 (HP2)                        | 1 of 1 ✔
Completed at: 13-Mar-2026 14:11:02
Duration    : 22m 37s
CPU hours   : 0.8
Succeeded   : 9
```

### Reference

+ Liu, Yang, et al. "NANOME: A Nextflow pipeline for haplotype-aware allele-specific consensus DNA methylation detection by nanopore long-read sequencing." bioRxiv (2025). https://pmc.ncbi.nlm.nih.gov/articles/PMC12236756/

## Session 6: Long read final project software installation


Verify Dorado:
```
module load apptainer
dorado_image=/project2/rhie_131/bioc599/shared/long_read_nanome/singularity/dorado_latest.sif
singularity exec ${dorado_image} \
    dorado -vv
```

Verify Clair3:
```
clair3_image=/project2/rhie_131/bioc599/shared/long_read_nanome/singularity/clair3_latest.sif
singularity exec  ${clair3_image} \
    run_clair3.sh --version
```

Verify ModKit:
```
modkit=/project2/rhie_131/bioc599/shared/long_read_nanome/singularity/modkit_latest.sif
singularity exec $modkit \
    modkit -V
```

Fastq QC tool in R package, start the OnDemand RStudio:
```angular2html
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("ShortRead")
```

Verify ShortRead R pakcage in R:
```angular2html
library(ShortRead)
```

Quality control R scripts:
```angular2html
fq <- readFastq("your_file.fastq.gz")  # Can read .fastq or .fastq.gz

fq  # Returns a ShortReadQ object

length(fq)        # Number of reads
sread(fq)         # The actual sequences
quality(fq)       # Quality scores
id(fq)            # Read IDs
```
