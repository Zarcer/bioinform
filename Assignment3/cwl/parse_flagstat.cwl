cwlVersion: v1.2
class: CommandLineTool
baseCommand: python3
inputs:
  script:
    type: File
    inputBinding:
      position: 0
  flagstat:
    type: File
    inputBinding:
      position: 1
  threshold:
    type: float
    default: 90
    inputBinding:
      prefix: --threshold
      position: 2
outputs:
  status:
    type: stdout
stdout: mapping_status.txt
