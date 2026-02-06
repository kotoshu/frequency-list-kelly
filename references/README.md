# Kelly Project References

This directory contains the original Kelly Project data files used to generate the processed JSON files in `data/`.

## Source Files

| Language | Local File | Format | Source URL | License | Generated JSON |
|----------|-----------|--------|------------|---------|----------------|
| Arabic   | `ar_m3.xls` | XLS | [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/ar_m3.xls) | Kelly terms | Not generated (encoding issues) |
| Chinese  | `zh_m3.xls` | XLS | [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/zh_m3.xls) | Kelly terms | `data/zh.json` |
| English  | `en_m3.xls` | XLS | [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/en_m3.xls) | Kelly terms | `data/en.json` |
| Greek    | `KELLY_EL.xlsx` | XLSX | [inventory.clarin.gr/lcr/741](https://inventory.clarin.gr/lcr/741) | Kelly terms | `data/el.json` |
| Italian  | `it_m3.xls` | XLS | [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/it_m3.xls) | Kelly terms | `data/it.json` |
| Norwegian | `Norwegian-Kelly.xls` | XLS | [spraakbanken.gu.se](https://spraakbanken.gu.se/sites/spraakbanken.gu.se/files/Norwegian-Kelly.xls) | Kelly terms | `data/no.json` |
| Russian  | `ru_m3.xls` | XLS | [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/ru_m3.xls) | Kelly terms | `data/ru.json` |
| Swedish  | `kelly.xml` | XML | [spraakbanken.gu.se](https://svn.spraakbanken.gu.se/sb-arkiv/pub/lmf/kelly/kelly.xml) | Kelly terms | `data/sv.json` |

## Local Source Files

Files in this directory (`references/`):

### `ar_m3.xls` (Arabic)
- **Source**: [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/)
- **Download URL**: https://ssharoff.github.io/kelly/ar_m3.xls
- **Format**: Excel XLS with 12 columns
- **Word count**: ~8,893 Arabic words
- **Status**: Not processed due to encoding issues with Ruby roo gem

### `zh_m3.xls` (Chinese)
- **Source**: [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/)
- **Download URL**: https://ssharoff.github.io/kelly/zh_m3.xls
- **Format**: Excel XLS with 2 columns [Chinese, CEFR]
- **Word count**: 7,730 Chinese words
- **CEFR levels**: A1, A2, B1, B2, C1, C2

### `en_m3.xls` (English)
- **Source**: [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/)
- **Download URL**: https://ssharoff.github.io/kelly/en_m3.xls
- **Format**: Excel XLS with 5 columns [ID, Word, POS, CEFR, Points]
- **Word count**: 7,549 English words
- **CEFR levels**: A1, A2, B1, B2, C1, C2

### `KELLY_EL.xlsx` (Greek)
- **Source**: [inventory.clarin.gr/lcr/741](https://inventory.clarin.gr/lcr/741)
- **Download URL**: https://inventory.clarin.gr/lcr/741
- **Format**: Excel XLSX with 9 columns
  - ID, Frequency, ‰, CEF level, Lemma, MWE, Part of speech, Translation, Comments
- **Word count**: 7,385 Greek words
- **CEFR levels**: A1, A2, B1, B2, C1, C2

### `it_m3.xls` (Italian)
- **Source**: [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/)
- **Download URL**: https://ssharoff.github.io/kelly/it_m3.xls
- **Format**: Excel XLS with 3 columns [Lemma, Pos, Points/CEFR]
- **Word count**: 6,865 Italian words
- **CEFR levels**: A1, A2, B1, B2, C1, C2

### `Norwegian-Kelly.xls` (Norwegian)
- **Source**: [Spraakbanken](https://spraakbanken.gu.se/)
- **Download URL**: https://spraakbanken.gu.se/sites/spraakbanken.gu.se/files/Norwegian-Kelly.xls
- **Format**: Excel XLS with 2 columns [Norwegian, POS]
- **Word count**: 6,000 Norwegian words
- **CEFR levels**: Not included in source file

### `ru_m3.xls` (Russian)
- **Source**: [ssharoff.github.io/kelly](https://ssharoff.github.io/kelly/)
- **Download URL**: https://ssharoff.github.io/kelly/ru_m3.xls
- **Format**: Excel XLS with 5 columns [Lemma, CEFR, POS, Frq abs, Frq ipm]
- **Word count**: 8,958 Russian words
- **CEFR levels**: A1, A2, B1, B2, C1, C2

### `kelly.xml` (Swedish)
- **Source**: [Spraakbanken](https://spraakbanken.gu.se/)
- **Download URL**: https://svn.spraakbanken.gu.se/sb-arkiv/pub/lmf/kelly/kelly.xml
- **Format**: XML with LexicalEntry elements
- **Word count**: 8,425 Swedish words
- **CEFR levels**: A1, A2, B1, B2, C1, C2 (encoded as 1-6)

## License Information

All Kelly Project data is subject to the Kelly Project's terms of use for research and educational purposes.

**Citation**:
```
Kilgarriff, A., Charalabopoulou, F., Gavrilidou, M., Johannessen, L. B.,
Khalil, S., Kokkinakis, S., Lew, R., Sharoff, S., Vadlapudi, R.,
Volodina, E. (2014). Corpus-based vocabulary lists for language learners
for nine languages. Language Resources and Evaluation, 48(2), 121-163.
DOI: https://doi.org/10.1015/lre-2014-0012
```

## Processing

The source files in this directory were processed using `scripts/parse_kelly.rb` to generate the Kotoshu-compatible JSON files in the `data/` directory.

Each JSON file contains:
- **Metadata**: Source information, citation, processing date
- **Tiers**: Frequency-based word groups (top_50, top_200, top_1000) and CEFR levels (A1-C2)
- **Full List**: Complete word entries with rank, frequency, and CEFR classification

See the main [README.md](../README.md) for usage instructions.
