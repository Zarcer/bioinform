cwlVersion: v1.2
class: CommandLineTool
baseCommand: fastqc
inputs:
  reads:
    type: File
    inputBinding:
      position: 1
  outdir:
    type: string
    default: .
    inputBinding:
      prefix: --outdir
      position: 0
outputs:
  html:
    type: File
    outputBinding:
      glob: "*_fastqc.html"
  zip:
    type: File
    outputBinding:
      glob: "*_fastqc.zip"
