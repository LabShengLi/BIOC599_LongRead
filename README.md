# BIOC599 Functional Genomics and Data Science Course
## Section 1: Software Installation
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

online_file='https://drive.google.com/uc?export=download&id=1fhAYa0uwGnbmeg4vEcFRhmbTxZT4whKG'
pod_file="data/nanopore_demo_data.pod5"
wget --no-check-certificate ${online_file}  -O ${pod_file}
```

#### Inspect POD5 files
```
singularity exec tool/dorado_latest.sif \
    pod5 inspect summary ${pod_file}
```

```
singularity exec tool/dorado_latest.sif \
    pod5 inspect reads ${pod_file}
```
