#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  mapping_qc_pipeline.sh -r reference.fa -q reads.fastq[.gz] -o out_dir [-t 90]

Pipeline:
  1. FastQC for reads
  2. minimap2 reference index
  3. minimap2 ONT mapping
  4. samtools view: SAM -> BAM
  5. samtools flagstat
  6. parse mapped reads percent
  7. print OK/not OK
  8. if OK: samtools sort and optional freebayes variant calling
USAGE
}

REFERENCE=""
READS=""
OUT_DIR=""
THRESHOLD="90"
THREADS="2"

while getopts ":r:q:o:t:p:h" opt; do
  case "${opt}" in
    r) REFERENCE="${OPTARG}" ;;
    q) READS="${OPTARG}" ;;
    o) OUT_DIR="${OPTARG}" ;;
    t) THRESHOLD="${OPTARG}" ;;
    p) THREADS="${OPTARG}" ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${REFERENCE}" || -z "${READS}" || -z "${OUT_DIR}" ]]; then
  usage >&2
  exit 2
fi

for tool in fastqc minimap2 samtools python3; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool is not found in PATH: ${tool}" >&2
    exit 127
  fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${OUT_DIR}"/{qc,logs}

SAMPLE="$(basename "${READS}")"
SAMPLE="${SAMPLE%.gz}"
SAMPLE="${SAMPLE%.fastq}"
SAMPLE="${SAMPLE%.fq}"

INDEX="${REFERENCE}.mmi"
SAM="${OUT_DIR}/${SAMPLE}.sam"
BAM="${OUT_DIR}/${SAMPLE}.bam"
SORTED_BAM="${OUT_DIR}/${SAMPLE}.sorted.bam"
FLAGSTAT="${OUT_DIR}/${SAMPLE}.flagstat.txt"
MAPPED_PERCENT_FILE="${OUT_DIR}/${SAMPLE}.mapped_percent.txt"
STATUS_FILE="${OUT_DIR}/${SAMPLE}.mapping_status.txt"
VCF="${OUT_DIR}/${SAMPLE}.vcf"

echo "[$(date -Is)] FastQC: ${READS}" | tee "${OUT_DIR}/logs/pipeline.log"
fastqc --outdir "${OUT_DIR}/qc" "${READS}" >>"${OUT_DIR}/logs/fastqc.log" 2>&1

if [[ ! -f "${INDEX}" ]]; then
  echo "[$(date -Is)] Index reference: ${REFERENCE}" | tee -a "${OUT_DIR}/logs/pipeline.log"
  minimap2 -d "${INDEX}" "${REFERENCE}" >>"${OUT_DIR}/logs/minimap2_index.log" 2>&1
fi

echo "[$(date -Is)] Map reads with minimap2" | tee -a "${OUT_DIR}/logs/pipeline.log"
minimap2 -ax map-ont -t "${THREADS}" "${INDEX}" "${READS}" >"${SAM}" 2>"${OUT_DIR}/logs/minimap2_map.log"

echo "[$(date -Is)] Convert SAM to BAM" | tee -a "${OUT_DIR}/logs/pipeline.log"
samtools view -@ "${THREADS}" -bS "${SAM}" >"${BAM}" 2>"${OUT_DIR}/logs/samtools_view.log"

echo "[$(date -Is)] Run samtools flagstat" | tee -a "${OUT_DIR}/logs/pipeline.log"
samtools flagstat "${BAM}" >"${FLAGSTAT}" 2>"${OUT_DIR}/logs/samtools_flagstat.log"

MAPPED_PERCENT="$(python3 "${SCRIPT_DIR}/parse_flagstat.py" "${FLAGSTAT}")"
printf '%s\n' "${MAPPED_PERCENT}" >"${MAPPED_PERCENT_FILE}"

if awk -v mapped="${MAPPED_PERCENT}" -v threshold="${THRESHOLD}" 'BEGIN { exit !(mapped >= threshold) }'; then
  echo "OK: mapped reads ${MAPPED_PERCENT}% >= ${THRESHOLD}%" | tee "${STATUS_FILE}"

  echo "[$(date -Is)] Sort BAM" | tee -a "${OUT_DIR}/logs/pipeline.log"
  samtools sort -@ "${THREADS}" -o "${SORTED_BAM}" "${BAM}" 2>"${OUT_DIR}/logs/samtools_sort.log"
  samtools index "${SORTED_BAM}" 2>"${OUT_DIR}/logs/samtools_index.log"

  if command -v freebayes >/dev/null 2>&1; then
    echo "[$(date -Is)] Call variants with freebayes" | tee -a "${OUT_DIR}/logs/pipeline.log"
    freebayes -f "${REFERENCE}" "${SORTED_BAM}" >"${VCF}" 2>"${OUT_DIR}/logs/freebayes.log"
  else
    echo "freebayes is not installed; variant calling step skipped" | tee "${OUT_DIR}/logs/freebayes.log"
  fi
else
  echo "not OK: mapped reads ${MAPPED_PERCENT}% < ${THRESHOLD}%" | tee "${STATUS_FILE}"
fi

echo "[$(date -Is)] Finished" | tee -a "${OUT_DIR}/logs/pipeline.log"
