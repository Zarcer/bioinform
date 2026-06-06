# bioinform

## 1-Выбранный вариант задания
```text
Построение пайплайна получения генетических вариантов.

Прибор: Oxford Nanopore MinION/GridION/PromethION (ONT)
Инструмент картирования: minimap2
Фреймворк пайплайнов: CWL
Организм: Escherichia coli
Референс: GCF_000005845.2, Escherichia coli K-12 MG1655
```

## 2-Ссылка на загруженные прочтения из NCBI SRA
```text
Run accession: ERR11030140
NCBI SRA: https://www.ncbi.nlm.nih.gov/sra/ERR11030140
ENA: https://www.ebi.ac.uk/ena/browser/view/ERR11030140

Для реального запуска использована подвыборка первых 10 000 reads из файла
ERR11030140.fastq.gz, чтобы не хранить большой FASTQ в репозитории.

Ссылка также сохранена в файле results/sra_reads_link.txt
```

## 3-Референсный геном
```text
NCBI Assembly: https://www.ncbi.nlm.nih.gov/assembly/GCF_000005845.2/
FASTA:
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz

Скрипт скачивания референса: scripts/download_inputs.sh
```

```bash
cd Assignment3
bash scripts/download_inputs.sh data
```

## 4-Скачивание reads
```bash
wget -c -O data/ERR11030140.fastq.gz \
  https://ftp.sra.ebi.ac.uk/vol1/fastq/ERR110/040/ERR11030140/ERR11030140.fastq.gz
```

```bash
python3 - <<'PY'
import gzip
from itertools import islice

with gzip.open("data/ERR11030140.fastq.gz", "rt") as inp, \
     gzip.open("data/ERR11030140.subset_10000.fastq.gz", "wt") as out:
    for line in islice(inp, 10000 * 4):
        out.write(line)
PY
```

## 5-Установка программ
```text
Были использованы консольные версии программ:
FastQC, minimap2, samtools, freebayes, cwltool, graphviz, sra-tools.
```

```bash
mamba create -n variant-qc -c conda-forge -c bioconda \
  python=3.11 fastqc minimap2 samtools freebayes cwltool graphviz sra-tools
mamba activate variant-qc
```

```bash
fastqc --version
minimap2 --version
samtools --version
cwltool --version
```

## 6-Простой запуск программ и индексация референса
```text
FastQC:
fastqc --outdir results/bash_run/qc data/ERR11030140.subset_10000.fastq.gz

Индексация референса:
minimap2 -d data/ecoli_k12_mg1655.fa.mmi data/ecoli_k12_mg1655.fa

Картирование:
minimap2 -ax map-ont -t 2 data/ecoli_k12_mg1655.fa.mmi data/ERR11030140.subset_10000.fastq.gz > sample.sam

SAM -> BAM:
samtools view -bS sample.sam > sample.bam

Оценка BAM:
samtools flagstat sample.bam > flagstat.txt
```

## 7-Скрипт разбора samtools flagstat
```text
Скрипт находится в файле scripts/parse_flagstat.py

Он ищет строку вида:
8066 + 0 mapped (73.84% : N/A)

И выводит процент картированных reads.
```

```bash
python3 scripts/parse_flagstat.py results/flagstat.txt --threshold 90
```

## 8-Bash алгоритм оценки качества картирования
```text
Основной bash-скрипт находится в файле scripts/mapping_qc_pipeline.sh

Алгоритм:
1. FastQC
2. minimap2 index
3. minimap2 map-ont
4. samtools view
5. samtools flagstat
6. parse_flagstat.py
7. Проверка процента mapped reads
8. Вывод OK или not OK
9. Если OK, запуск samtools sort и freebayes
```

```bash
bash scripts/mapping_qc_pipeline.sh \
  -r data/ecoli_k12_mg1655.fa \
  -q data/ERR11030140.subset_10000.fastq.gz \
  -o results/bash_run \
  -t 90 \
  -p 2
```

## 9-Фактический результат запуска bash алгоритма
```text
Результат samtools flagstat сохранен в results/flagstat.txt
Результат проверки сохранен в results/mapping_status.txt
Отдельный файл с итогом находится в results/pipeline_output.txt

Mapped reads: 73.84%
Threshold: 90%
Decision: not OK

Так как процент картированных reads меньше 90%, запуск считается not OK.
```

## 10-Фреймворк пайплайнов
```text
Выбран фреймворк CWL (Common Workflow Language).

Ссылка: https://www.commonwl.org/
```

```bash
pipx install cwltool
cwltool --version
```

## 11-Тестовый пайплайн Hello world
```text
Код тестового пайплайна:
cwl/hello.cwl
cwl/hello-job.yml

Результат запуска:
results/cwl_hello_run/hello_world.txt

Лог запуска:
results/logs/cwl_hello.log
```

```bash
cwltool cwl/hello.cwl cwl/hello-job.yml
```

## 12-Пайплайн оценки качества картирования на CWL
```text
Основной CWL workflow:
cwl/mapping_qc.cwl

Описание входных файлов:
cwl/mapping-qc-job.template.yml

Вспомогательные CWL-шаги находятся в папке cwl.
```

```bash
cwltool --outdir results/cwl_run cwl/mapping_qc.cwl cwl/mapping-qc-job.template.yml
```

```text
Результаты CWL запуска:
results/cwl_run/flagstat.txt
results/cwl_run/mapping_status.txt
results/logs/cwl_mapping_qc.log
```

## 13-Визуализация пайплайна
```text
Ручная упрощенная схема:
visualization/mapping_qc_dag.png

Автоматическая схема, полученная из CWL:
visualization/mapping_qc_dag_from_cwl.png

Исходные DOT-файлы:
visualization/mapping_qc_dag.dot
visualization/mapping_qc_dag_from_cwl.dot
```

```bash
cwltool --print-dot cwl/mapping_qc.cwl | dot -Tpng > visualization/mapping_qc_dag_from_cwl.png
```

## 14-Описание визуализации
```text
Описание способа визуализации и отличий DAG от блок-схемы находится в файле:
visualization/visualization_description.md
```

## 15-Список основных файлов результата
```text
1. Ссылка на reads: results/sra_reads_link.txt
2. Bash-скрипт: scripts/mapping_qc_pipeline.sh
3. samtools flagstat: results/flagstat.txt
4. Парсер flagstat: scripts/parse_flagstat.py
5. Инструкция установки CWL: README.md
6. Hello world CWL: cwl/hello.cwl
7. Результаты CWL: results/cwl_hello_run, results/cwl_run, results/logs
8. CWL mapping QC: cwl/mapping_qc.cwl
9. Итоговый результат: results/pipeline_output.txt
10. Логи: results/logs, results/bash_run/logs
11. PNG визуализация: visualization/mapping_qc_dag.png
12. Описание визуализации: visualization/visualization_description.md
```

## 16-Примечание
```text
В репозитории сохранены текстовые результаты реального запуска на подвыборке
10 000 reads. Большие файлы FASTQ, SAM, BAM, индексы и локальное окружение
добавлены в .gitignore, чтобы не загружать в репозиторий сотни мегабайт.
```
