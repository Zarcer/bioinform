cwlVersion: v1.2
class: CommandLineTool
baseCommand: minimap2
requirements:
  InlineJavascriptRequirement: {}
arguments:
  - -d
  - valueFrom: $(inputs.reference.basename).mmi
    position: 1
inputs:
  reference:
    type: File
    inputBinding:
      position: 2
outputs:
  index:
    type: File
    outputBinding:
      glob: $(inputs.reference.basename).mmi
