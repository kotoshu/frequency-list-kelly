# Kelly Frequency Lists for Kotoshu

This directory contains frequency lists derived from the Kelly Project (University of Leeds & University of Gothenburg) for use with the Kotoshu spell checker.

## Overview

The Kelly Project provides corpus-based vocabulary lists for language learners with CEFR (Common European Framework of Reference for Languages) level annotations. These frequency lists significantly improve spell checker suggestion quality by prioritizing common words.

## Files

| Language | Code | JSON File | Word Count | CEFR Levels | Source Format |
|----------|------|-----------|------------|-------------|---------------|
| Arabic   | ar   | `ar.json`  | 8,893      | A1-C2       | XLS (via CSV) |
| Chinese  | zh   | `zh.json`  | 7,730      | A1-C2       | XLS           |
| English  | en   | `en.json`  | 7,549      | A1-C2       | XLS           |
| Greek    | el   | `el.json`  | 7,385      | A1-C2       | XLSX          |
| Italian  | it   | `it.json`  | 6,865      | A1-C2       | XLS           |
| Norwegian| no   | `no.json`  | 6,000      | None        | XLS           |
| Russian  | ru   | `ru.json`  | 8,958      | A1-C2       | XLS           |
| Swedish  | sv   | `sv.json`  | 8,425      | A1-C2       | XML           |

**Total: 52,805 words across 8 languages**

## Data Format

Each JSON file contains:

```json
{
  "metadata": {
    "language": "Language code (ISO 639-1)",
    "language_name": "Full language name",
    "source": "Kelly Project - University of Leeds & University of Gothenburg",
    "source_url": "https://spraakbanken.gu.se/eng/kelly",
    "citation": "Full citation information",
    "doi": "https://doi.org/10.1015/lre-2014-0012",
    "total_words": "Total word count",
    "cefr_levels": ["A1", "A2", "B1", "B2", "C1", "C2"],
    "license": "Research use - see Kelly project terms",
    "processed_date": "ISO 8601 timestamp",
    "kotoshu_version": "1.0.0",
    "note": "Generated from Kelly Project frequency lists. See ATTRIBUTION.md for details."
  },
  "tiers": {
    "top_50": {
      "words": ["word1", "word2", ...],
      "description": "Top 50 most frequent words",
      "bonus_score": 200
    },
    "top_200": {
      "words": ["word1", "word2", ...],
      "description": "Top 200 most frequent words",
      "bonus_score": 100
    },
    "top_1000": {
      "words": ["word1", "word2", ...],
      "description": "Top 1000 most frequent words",
      "bonus_score": 50
    },
    "a1": {
      "words": [...],
      "description": "CEFR A1 level words",
      "bonus_score": 150
    },
    "a2": { "words": [...], "description": "CEFR A2 level words", "bonus_score": 120 },
    "b1": { "words": [...], "description": "CEFR B1 level words", "bonus_score": 90 },
    "b2": { "words": [...], "description": "CEFR B2 level words", "bonus_score": 60 },
    "c1": { "words": [...], "description": "CEFR C1 level words", "bonus_score": 30 },
    "c2": { "words": [...], "description": "CEFR C2 level words", "bonus_score": 20 }
  },
  "full_list": [
    {
      "word": "example",
      "ipm": 1000.0,
      "cefr": "A1",
      "rank": 1,
      "pos": "noun"
    },
    ...
  ]
}
```

## CEFR Level Mapping

The CEFR (Common European Framework of Reference for Languages) levels are used for both proficiency classification and bonus scoring in Kotoshu's suggestion algorithm:

| Level | Description    | Bonus Score | Example Words                    |
|-------|----------------|-------------|----------------------------------|
| A1    | Beginner       | 150         | the, be, to, of, and             |
| A2    | Elementary     | 120         | will, my, one, all, would        |
| B1    | Intermediate   | 90          | however, although, therefore     |
| B2    | Upper Int.     | 60          | nevertheless, meanwhile, moreover|
| C1    | Advanced       | 30          | specialized vocabulary           |
| C2    | Proficiency    | 20          | academic/technical vocabulary     |

## Usage with Kotoshu

### Loading Kelly Frequency Lists

The Kelly frequency lists can be loaded directly into Kotoshu's `EditDistanceStrategy`:

```ruby
require 'kotoshu'
require 'json'

# Load Kelly frequency data
kelly_data = JSON.parse(File.read('frequency-list-kelly/data/en.json'))

# Extract frequency tiers for Kotoshu
frequency_tiers = {
  top_50: Set.new(kelly_data['tiers']['top_50']['words']),
  top_200: Set.new(kelly_data['tiers']['top_50']['words'] +
                  kelly_data['tiers']['top_200']['words']),
  top_1000: Set.new(kelly_data['tiers']['top_50']['words'] +
                   kelly_data['tiers']['top_200']['words'] +
                   kelly_data['tiers']['top_1000']['words'])
}

# Create spell checker with Kelly frequency data
spellchecker = Kotoshu::SpellChecker.new(
  dictionary: Kotoshu::Dictionary::Hunspell.new(
    dic_path: '/path/to/en_US.dic',
    aff_path: '/path/to/en_US.aff'
  )
)

# Create edit distance strategy with custom frequency data
strategy = Kotoshu::Suggestions::Strategies::EditDistanceStrategy.new(
  language_code: 'en',
  frequency_tiers: frequency_tiers
)

# Generate suggestions with Kelly frequency-based scoring
context = Kotoshu::Context.new(
  word: 'helo',
  dictionary: spellchecker.dictionary
)

suggestions = strategy.generate(context)
# Common words like "hello" will receive bonus points based on Kelly frequency
```

### Direct Integration Example

See `examples/12_kelly_frequency_integration.rb` for a complete working example.

## Processing

The JSON files are generated from the original Kelly Excel files using the `scripts/parse_kelly.rb` script.

### Requirements

- Ruby 3.1+
- `roo` gem (2.10.1+)
- `roo-xls` gem (for XLS support)
- `nokogiri` gem (for XML parsing)
- Python 3 with `xlrd` (for Arabic XLS encoding issues)

### Usage

```bash
# Parse all Kelly files
ruby scripts/parse_kelly.rb

# Parse specific language only (by modifying LANGUAGE_CODES in script)
ruby scripts/parse_kelly.rb
```

### Arabic Special Processing

Arabic requires additional preprocessing due to encoding issues:

```bash
# Step 1: Convert Arabic Excel to CSV using Python
python3 scripts/convert_arabic.py

# Step 2: Run the main parser
ruby scripts/parse_kelly.rb
```

The conversion is handled automatically by the parser.

## Repository Structure

```
frequency-list-kelly/
├── data/                    # Processed JSON files
│   ├── ar.json             # Arabic frequency data
│   ├── zh.json             # Chinese frequency data
│   ├── en.json             # English frequency data
│   ├── el.json             # Greek frequency data
│   ├── it.json             # Italian frequency data
│   ├── no.json             # Norwegian frequency data
│   ├── ru.json             # Russian frequency data
│   ├── sv.json             # Swedish frequency data
│   ├── ATTRIBUTION.md      # Citation and license information
│   └── README.md           # This file
│
├── references/             # Original Kelly files (downloaded)
│   ├── ar_m3.xls          # Arabic source
│   ├── zh_m3.xls          # Chinese source
│   ├── en_m3.xls          # English source
│   ├── KELLY_EL.xlsx      # Greek source
│   ├── it_m3.xls          # Italian source
│   ├── Norwegian-Kelly.xls # Norwegian source
│   ├── ru_m3.xls          # Russian source
│   ├── kelly.xml          # Swedish source
│   └── README.md          # Source URLs and attribution
│
└── scripts/                # Processing scripts
    ├── parse_kelly.rb      # Main parser
    ├── convert_arabic.py   # Arabic CSV converter
    └── debug_arabic.rb     # Arabic debugging tool
```

## Source Files and Attribution

Please see [ATTRIBUTION.md](ATTRIBUTION.md) for full citation and license information for the Kelly Project data.

### Source URLs

| Language | Source URL |
|----------|------------|
| Arabic   | https://ssharoff.github.io/kelly/ar_m3.xls |
| Chinese  | https://ssharoff.github.io/kelly/zh_m3.xls |
| English  | https://ssharoff.github.io/kelly/en_m3.xls |
| Greek    | https://inventory.clarin.gr/lcr/741 |
| Italian  | https://ssharoff.github.io/kelly/it_m3.xls |
| Norwegian | https://spraakbanken.gu.se/sites/spraakbanken.gu.se/files/Norwegian-Kelly.xls |
| Russian  | https://ssharoff.github.io/kelly/ru_m3.xls |
| Swedish  | https://svn.spraakbanken.gu.se/sb-arkiv/pub/lmf/kelly/kelly.xml |

## Citation

If you use this data in your research or project, please cite:

```bibtex
@article{kilgarriff2014corpus,
  title={Corpus-based vocabulary lists for language learners for nine languages},
  author={Kilgarriff, A. and Charalabopoulou, F. and Gavrilidou, M. and
          Johannessen, L. B. and Khalil, S. and Kokkinakis, S. and
          Lew, R. and Sharoff, S. and Vadlapudi, R. and Volodina, E.},
  journal={Language Resources and Evaluation},
  volume={48},
  number={2},
  pages={121--163},
  year={2014},
  publisher={Springer},
  doi={10.1015/lre-2014-0012}
}
```

## License

The Kelly Project data is provided for research use. Please see the Kelly Project terms for specific license conditions.

## Integration with Kotoshu

### How Frequency Data Improves Suggestions

Kotoshu's `EditDistanceStrategy` uses frequency data to improve suggestion quality:

1. **Frequency Bonus**: Common words (top 50/200/1000) receive bonus points
2. **CEFR-Level Scoring**: Words from lower CEFR levels (beginner) rank higher
3. **Combined Scoring**: Edit distance + frequency + keyboard proximity + typo patterns

### Scoring Formula

```
enhanced_score = (edit_distance × 1000)
               - frequency_bonus
               + keyboard_penalty
               - transposition_bonus
               - typo_pattern_bonus
               + length_difference_penalty
```

Where:
- `frequency_bonus`: 200 (top 50), 100 (top 200), 50 (top 1000)
- `keyboard_penalty`: 10 (adjacent keys) to 100 (far keys)
- `transposition_bonus`: 200 for single adjacent swap
- `typo_pattern_bonus`: 300 for missing double letter

## References

- Kilgarriff, A., et al. (2014). Corpus-based vocabulary lists for language learners for nine languages. *Language Resources and Evaluation*, 48(2), 121-163. DOI: https://doi.org/10.1015/lre-2014-0012
- Kelly Project: https://spraakbanken.gu.se/eng/kelly
- Kotoshu Spell Checker: https://github.com/kotoshu/kotoshu
