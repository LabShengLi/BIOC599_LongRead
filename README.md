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
hg38_chr11_chr15.fa  hg38_chr11_chr15.fa.fai  nanopore_demo_data.pod5
```

```
ls tool/
clair3_latest.sif  dorado_latest.sif  models
```

#### Basecall and methylation call

```
indir="$wdir/data/"
ref="$wdir/data/hg38_chr11_chr15.fa"

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
        --reference $ref \
        --output-dir analysis/dorado_call \
        --batchsize 8
```
