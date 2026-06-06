cwlVersion: v1.2
class: CommandLineTool
baseCommand: freebayes
requirements:
  InlineJavascriptRequirement: {}
arguments:
  - -f
inputs:
  reference:
    type: File
    inputBinding:
      position: 1
  sorted_bam:
    type: File
    inputBinding:
      position: 2
outputs:
  vcf:
    type: stdout
stdout: $(inputs.sorted_bam.nameroot).vcf
