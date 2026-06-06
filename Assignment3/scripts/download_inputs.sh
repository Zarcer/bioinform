#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-data}"
SRA_RUN="${SRA_RUN:-ERR11030140}"
REFERENCE_URL="${REFERENCE_URL:-https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz}"

mkdir -p "${OUT_DIR}"

echo "Download E. coli K-12 MG1655 reference"
wget -c -O "${OUT_DIR}/ecoli_k12_mg1655.fa.gz" "${REFERENCE_URL}"
gunzip -kf "${OUT_DIR}/ecoli_k12_mg1655.fa.gz"

cat <<EOF

Reference saved:
  ${OUT_DIR}/ecoli_k12_mg1655.fa

Download ONT reads from SRA/ENA:
  Run: ${SRA_RUN}
  NCBI SRA: https://www.ncbi.nlm.nih.gov/sra/${SRA_RUN}
  ENA run:  https://www.ebi.ac.uk/ena/browser/view/${SRA_RUN}

Option A, SRA Toolkit:
  prefetch ${SRA_RUN}
  fasterq-dump ${SRA_RUN} --outdir ${OUT_DIR}

Option B, ENA browser:
  open https://www.ebi.ac.uk/ena/browser/view/${SRA_RUN}
  copy the FASTQ FTP link and download it with wget.

The reads file should then be passed to scripts/mapping_qc_pipeline.sh with -q.
EOF
