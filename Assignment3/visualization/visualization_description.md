# bioinform

## 1-Использованный способ визуализации
```text
Для визуализации пайплайна использован Graphviz.

Основной графический файл:
mapping_qc_dag.png

Исходный файл для Graphviz:
mapping_qc_dag.dot
```

```bash
dot -Tpng visualization/mapping_qc_dag.dot -o visualization/mapping_qc_dag.png
```

## 2-Автоматическая визуализация CWL
```text
Также была получена автоматическая визуализация из CWL workflow.

Графический файл:
mapping_qc_dag_from_cwl.png

Исходный DOT-файл:
mapping_qc_dag_from_cwl.dot
```

```bash
cwltool --print-dot cwl/mapping_qc.cwl | dot -Tpng > visualization/mapping_qc_dag_from_cwl.png
```

## 3-Отличие ручной схемы от CWL DAG
```text
mapping_qc_dag.png — это упрощенная схема для человека. Она показывает общий
смысл алгоритма: reads и reference, FastQC, minimap2, samtools flagstat,
получение процента mapped reads и вывод OK/not OK.

mapping_qc_dag_from_cwl.png — это автоматическая схема, построенная из файла
cwl/mapping_qc.cwl. Она показывает реальные входы workflow, выходы workflow,
названия шагов CWL и связи между файлами.
```

## 4-Отличие DAG от блок-схемы алгоритма
```text
Блок-схема алгоритма показывает логику принятия решения. После samtools flagstat
извлекается процент картированных reads, затем выполняется проверка порога 90%.
Если mapped reads >= 90%, выводится OK. Если меньше 90%, выводится not OK.

DAG показывает не условные переходы, а зависимости между шагами и файлами.
Например, FastQC может выполняться независимо от индексации референса.
Условие OK/not OK в CWL-графе представлено как выходной файл mapping_status.txt,
а не как ромб с ветвлением.
```
