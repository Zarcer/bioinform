cwlVersion: v1.2
class: CommandLineTool
baseCommand: samtools
requirements:
  InlineJavascriptRequirement: {}
arguments:
  - sort
  - -o
  - valueFrom: $(inputs.bam.nameroot).sorted.bam
    position: 1
inputs:
  bam:
    type: File
    inputBinding:
      position: 2
outputs:
  sorted_bam:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).sorted.bam
