cwlVersion: v1.2
class: CommandLineTool
baseCommand: samtools
arguments:
  - flagstat
inputs:
  bam:
    type: File
    inputBinding:
      position: 1
outputs:
  flagstat:
    type: stdout
stdout: flagstat.txt
