# BIOC599 Functional Genomics and Data Science Course
## Section 1: Software Installation

### Enter into interactive mode
```
srun --pty -p main --time=02:00:00 -n 2 --mem 16GB bash
```

### Installation of long read Nanopore sequencing analysis tools

We will install tools using Conda and Singularity. Firstly, create a folder for tool installation:
```
wdir="/scratch1/$USER/BIOC599_LongRead"
mkdir -p $wdir
cd $wdir
pwd
```

#### Basecall and Methylation call tool: Dorado

```
mkdir -p tool
# singluarity pull docker://nanoporetech/dorado
singularity pull --dir tool/ docker://nanoporetech/dorado
```

#### Genetic Variant Call tool: Clair3

```
# singularity pull docker://hkubal/clair3
singularity pull --dir tool/ docker://hkubal/clair3
```

#### Verify installation

```
singularity exec tool/dorado_latest.sif     dorado -vv
```

```
singularity exec tool/clair3_latest.sif run_clair3.sh --version
```

#### Download basecall and methylation call models for Dorado

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
```
singularity exec tool/dorado_latest.sif \
    pod5 inspect summary ${pod5_file}
```

```
singularity exec tool/dorado_latest.sif \
    pod5 inspect reads ${pod5_file}
```

```
singularity exec tool/dorado_latest.sif \
    pod5 inspect read ${pod_file}  f84e44c5-15d2-4227-adb7-fb1b206dc128
```



## Session 2: Long read basecall and methylation call

### Dorado basecall and methylation call
#### Prerequisite files

```
wdir="/scratch1/$USER/BIOC599_LongRead"
mkdir -p $wdir
cd $wdir
pwd
```

```
ls data/
```

**output**
```
hg38_chr11_chr15.fa  hg38_chr11_chr15.fa.fai  nanopore_demo_data.pod5
```

```
ls tool/

```
**output**
```
clair3_latest.sif  dorado_latest.sif  models
```

#### Basecall and methylation call

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
**output**
```
total 2.5K
-rw-rw-r-- 1 yliu8962 yliu8962 2.7M Jan 31 23:12 calls_2025-02-01_T07-01-17.bam
-rw-rw-r-- 1 yliu8962 yliu8962  47K Jan 31 23:12 calls_2025-02-01_T07-01-17.bam.bai
```


#### IGV visualization of methylation states in BAM file

![IGV Snapshot of KCNQ1](https://github.com/LabShengLi/BIOC599_LongRead/blob/tutorial/pic/igv_snapshot_KCNQ1.png)

![IGV Snapshot of SNRPN](https://github.com/LabShengLi/BIOC599_LongRead/blob/tutorial/pic/igv_snapshot_SNRPN.png)

## Session 3: Haplotype phasing

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

singularity exec tool/clair3_latest.sif \
    samtools index -@ ${cpus} ${outdir}/${dsname}_split_HP1.bam

singularity exec tool/clair3_latest.sif \
    samtools index -@ ${cpus} ${outdir}/${dsname}_split_HP2.bam
```


**output** for haplotype
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

**output** for split
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
**output**
```
full_alignment.vcf.gz      Human1_split_HP1.bam       merge_output.vcf.gz             pileup.vcf.gz
full_alignment.vcf.gz.tbi  Human1_split_HP2.bam       merge_output.vcf.gz.tbi         pileup.vcf.gz.tbi
haplotag.bam               Human1_split_untagged.bam  phased_merge_output.vcf.gz      run_clair3.log
haplotag.tsv               log                        phased_merge_output.vcf.gz.tbi  tmp
```
