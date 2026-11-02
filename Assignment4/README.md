# Assignment 4 - student_31

Файлы результата:

- `student_31.vcf` - копия исходного VCF.
- `annotated_variants.tsv` - сводная таблица из 50 исходных вариантов.
- `VEP_export.tsv` - полный транскриптный экспорт VEP.
- `VEP_annotated.vcf` - исходные записи с полями VEP INFO/CSQ.
- `ClinVar_annotations.tsv` - точная ClinVar/SPDI-аннотация всех 50 вариантов.
- `ClinVar_records.tsv` - 22 точные VCV-записи плюс одна связанная запись для другого ALT.
- `ClinVar_esearch.json`, `ClinVar_esummary.json` - исходные результаты ClinVar-поиска по rsID.
- `ClinVar_spdi_search.json`, `ClinVar_spdi_esummary.json` - исходный exact-SPDI поиск и ESummary для дополнительных VCV.
- `ClinVar_exact_allele_search.json` - сводная проверка аллельного соответствия для 50 вариантов.
- `gnomAD_annotations.tsv` - частоты gnomAD для всех 50 вариантов, если доступны.
- `annotation_settings.md` - версии, параметры, правила выбора и источники.
- `report.md` - краткий отчет с разбором трех вариантов и заключением.

Сводка: **50 SNV**; chr21 - **7**, chr22 - **43**; **42 транзиции** и **8 трансверсий**. Точный поиск ClinVar по SPDI нашёл записи для **22** вариантов; 28 exact-SPDI запросов не вернули совпадения.
