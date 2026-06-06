cwlVersion: v1.2
class: CommandLineTool
baseCommand: samtools
requirements:
  InlineJavascriptRequirement: {}
arguments:
  - view
  - -bS
inputs:
  sam:
    type: File
    inputBinding:
      position: 1
outputs:
  bam:
    type: stdout
stdout: $(inputs.sam.nameroot).bam
