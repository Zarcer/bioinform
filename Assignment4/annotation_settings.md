# Настройки и происхождение аннотаций

Дата получения: 2026-11-02. Исходный файл: `student_31.vcf`; сборка - GRCh38.

## Ensembl VEP

- Ensembl VEP web tool; сборка Human GRCh38.p14; transcript set GENCODE 50.
- Job `student_31_HW4`, ID `2tS9gP4gQz9ZMR`; VEP `v116.2` / API `v116` по метаданным VCF.
- Включены gnomAD Exomes v4.1.1 и Genomes v4.1.1; сохранены глобальные AF и максимальная частота подгруппы для genomes, если доступны.
- TSV экспорт содержит все транскриптные последствия (1 502 строки для 50 позиций); VCF экспорт содержит VEP INFO/CSQ.
- Основное последствие в `annotated_variants.tsv` - самое тяжёлое по Sequence Ontology среди всех транскриптов. При равном следствии приоритет: MANE Select → MANE Plus Clinical → canonical → первая строка экспорта. Дополнительно приведены MANE Select следствие и все последствия. APPRIS/TSL/CCDS отсутствовали в TSV и не использовались.
- Страница результата: https://www.ensembl.org/tools/vep/submissions/2tS9gP4gQz9ZMR. Официальная документация: https://rest.ensembl.org/documentation/info/vep_region_get

## ClinVar

- Поиск выполнен через NCBI E-utilities двумя способами: по rsID и по точному GRCh38 SPDI (`NC_000021.9` или `NC_000022.11`, позиция VCF minus 1, REF, ALT). Формат поиска по SPDI описан в официальной справке ClinVar.
- ESummary canonical SPDI сопоставлен с исходными координатой/REF/ALT. Точные аллельные записи найдены для 22 вариантов; 28 запросов по SPDI не вернули совпадения.
- Для rs116555717 точная запись T>C - VCV003305447.2, с конфликтующими классификациями. Дополнительно по rsID найден VCV002585196.1 для T>G (VUS); это другой ALT, и классификация не переносилась на исходный аллель.
- `ClinVar_annotations.tsv` - одна строка на входной вариант; `ClinVar_records.tsv` - все 22 точные записи плюс один связанный, но аллельно отличный VCV; JSON-файлы сохраняют ESearch/ESummary и проверку соответствия.
- Нет результата exact-SPDI поиска не является доказательством отсутствия ClinVar записи при другом представлении аллеля. ClinVar агрегирует утверждения submitter-ов, которые могут конфликтовать.
- Справка: https://www.ncbi.nlm.nih.gov/clinvar/docs/help/ ; E-utilities: https://www.ncbi.nlm.nih.gov/clinvar/docs/maintenance_use/ ; база: https://www.ncbi.nlm.nih.gov/clinvar/intro/

## gnomAD

- Частоты взяты из полей Ensembl VEP для gnomAD Exomes v4.1.1 и Genomes v4.1.1; для genomes дополнительно сохранён `AF_grpmax`, если возвращён.
- `gnomAD_annotations.tsv` содержит строку на каждый исходный SNV. Пустой AF означает, что VEP экспорт не вернул частоту для аллеля.
- Портал: https://gnomad.broadinstitute.org/ . AF - популяционная частота, не клиническая классификация.
