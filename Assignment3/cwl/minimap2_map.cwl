cwlVersion: v1.2
class: CommandLineTool
baseCommand: minimap2
requirements:
  InlineJavascriptRequirement: {}
arguments:
  - -ax
  - map-ont
  - -t
  - valueFrom: $(inputs.threads)
inputs:
  index:
    type: File
    inputBinding:
      position: 1
  reads:
    type: File
    inputBinding:
      position: 2
  threads:
    type: int
    default: 2
outputs:
  sam:
    type: stdout
stdout: $(inputs.reads.nameroot).sam
