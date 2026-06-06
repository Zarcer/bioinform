cwlVersion: v1.2
class: Workflow
label: ONT mapping quality control pipeline

inputs:
  reference: File
  reads: File
  threshold:
    type: float
    default: 90
  threads:
    type: int
    default: 2
  parse_script:
    type: File
    default:
      class: File
      location: ../scripts/parse_flagstat.py

outputs:
  fastqc_html:
    type: File
    outputSource: fastqc/html
  fastqc_zip:
    type: File
    outputSource: fastqc/zip
  sam:
    type: File
    outputSource: map/sam
  bam:
    type: File
    outputSource: sam_to_bam/bam
  flagstat:
    type: File
    outputSource: run_flagstat/flagstat
  mapping_status:
    type: File
    outputSource: parse_flagstat/status
  sorted_bam:
    type: File
    outputSource: sort_bam/sorted_bam

steps:
  fastqc:
    run: fastqc.cwl
    in:
      reads: reads
    out: [html, zip]

  index_reference:
    run: minimap2_index.cwl
    in:
      reference: reference
    out: [index]

  map:
    run: minimap2_map.cwl
    in:
      index: index_reference/index
      reads: reads
      threads: threads
    out: [sam]

  sam_to_bam:
    run: samtools_view.cwl
    in:
      sam: map/sam
    out: [bam]

  run_flagstat:
    run: samtools_flagstat.cwl
    in:
      bam: sam_to_bam/bam
    out: [flagstat]

  parse_flagstat:
    run: parse_flagstat.cwl
    in:
      script: parse_script
      flagstat: run_flagstat/flagstat
      threshold: threshold
    out: [status]

  sort_bam:
    run: samtools_sort.cwl
    in:
      bam: sam_to_bam/bam
    out: [sorted_bam]
