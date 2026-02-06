# Kelly Frequency Lists for Kotoshu

Frequency lists derived from the Kelly Project (University of Leeds & University of Gothenburg) for use with the Kotoshu spell checker and other language learning applications.

## Overview

This repository contains processed frequency lists from the [Kelly Project](https://spraakbanken.gu.se/eng/kelly) in a JSON format suitable for integration with spell checkers and language learning tools. The Kelly Project provides corpus-based vocabulary lists for language learners with CEFR-level annotations.

## Languages

| Language | Code | Word Count | CEFR Levels | Source Format | Status |
|----------|------|------------|-------------|---------------|--------|
| Arabic   | ar   | 8,893      | A1, A2, B1, B2, C1, C2 | XLS (via CSV) | ✅ Complete |
| Chinese  | zh   | 7,730      | A1, A2, B1, B2, C1, C2 | XLS           | ✅ Complete |
| English  | en   | 7,549      | A1, A2, B1, B2, C1, C2 | XLS           | ✅ Complete |
| Greek    | el   | 7,385      | A1, A2, B1, B2, C1, C2 | XLSX          | ✅ Complete |
| Italian  | it   | 6,865      | A1, A2, B1, B2, C1, C2 | XLS           | ✅ Complete |
| Norwegian | no  | 6,000      | None        | XLS           | ✅ Complete |
| Russian  | ru   | 8,958      | A1, A2, B1, B2, C1, C2 | XLS           | ✅ Complete |
| Swedish  | sv   | 8,425      | A1, A2, B1, B2, C1, C2 | XML           | ✅ Complete |

**Total**: 52,805 words across 8 languages (7 with CEFR-level annotations)

## Quick Start

### Direct Download

Download individual JSON files:

```bash
curl -O https://raw.githubusercontent.com/kotoshu/frequency-list-kelly/v1/data/en.json
curl -O https://raw.githubusercontent.com/kotoshu/frequency-list-kelly/v1/data/ru.json
curl -O https://raw.githubusercontent.com/kotoshu/frequency-list-kelly/v1/data/ar.json
```

### Clone Repository

```bash
git clone https://github.com/kotoshu/frequency-list-kelly.git
cd frequency-list-kelly
```

## Usage with Kotoshu

### Automatic Integration

Kotoshu's `EditDistanceStrategy` now automatically loads Kelly frequency data when available:

```ruby
require 'kotoshu'

# Create spell checker with Kelly frequency support
spellchecker = Kotoshu::Spellchecker.new(
  dictionary: Kotoshu::Dictionary::Hunspell.new(
    dic_path: '/path/to/en_US.dic',
    aff_path: '/path/to/en_US.aff'
  )
)

# Suggestions automatically use Kelly frequency data
# Common words like "hello", "the", "world" receive bonus points
result = spellchecker.check("helo wrold teh")
puts result.suggestions
# => ["hello", "world", "the"] with frequency-based ranking
```

### Manual Integration

```ruby
require 'kotoshu'
require 'json'

# Load Kelly frequency data
kelly_data = JSON.parse(File.read('data/en.json'))

# Extract frequency tiers for Kotoshu
frequency_tiers = {
  top_50: Set.new(kelly_data['tiers']['top_50']['words']),
  top_200: Set.new(kelly_data['tiers']['top_50']['words'] +
                  kelly_data['tiers']['top_200']['words']),
  top_1000: Set.new(kelly_data['tiers']['top_50']['words'] +
                   kelly_data['tiers']['top_200']['words'] +
                   kelly_data['tiers']['top_1000']['words'])
}

# Create edit distance strategy with custom frequency data
strategy = Kotoshu::Suggestions::Strategies::EditDistanceStrategy.new(
  language_code: 'en',
  frequency_tiers: frequency_tiers
)

# Generate suggestions with Kelly frequency-based scoring
suggestions = strategy.generate(context)
# Common words receive bonus points: 200 (top_50), 100 (top_200), 50 (top_1000)
```

### Example Output

Without Kelly frequency:
```
"helo" → ["hello", "help", "tell"]
```

With Kelly frequency:
```
"helo" → ["hello", "help", "he"]  # "he" moves up due to top_50 bonus
```

## Data Format

Each JSON file contains:

```json
{
  "metadata": {
    "language": "en",
    "language_name": "English",
    "source": "Kelly Project - University of Leeds & University of Gothenburg",
    "source_url": "https://spraakbanken.gu.se/eng/kelly",
    "total_words": 7549,
    "cefr_levels": ["A1", "A2", "B1", "B2", "C1", "C2"]
  },
  "tiers": {
    "top_50": { "words": [...], "description": "Top 50 most frequent words", "bonus_score": 200 },
    "top_200": { "words": [...], "description": "Top 200 most frequent words", "bonus_score": 100 },
    "top_1000": { "words": [...], "description": "Top 1000 most frequent words", "bonus_score": 50 },
    "a1": { "words": [...], "description": "CEFR A1 level words", "bonus_score": 150 },
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
    }
  ]
}
```

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
│   └── README.md           # Data format documentation
│
├── references/             # Original Kelly Project data files
│   ├── ar_m3.xls          # Arabic source (8,893 words)
│   ├── zh_m3.xls          # Chinese source (7,730 words)
│   ├── en_m3.xls          # English source (7,549 words)
│   ├── KELLY_EL.xlsx      # Greek source (7,385 words)
│   ├── it_m3.xls          # Italian source (6,865 words)
│   ├── Norwegian-Kelly.xls # Norwegian source (6,000 words)
│   ├── ru_m3.xls          # Russian source (8,958 words)
│   ├── kelly.xml          # Swedish source (8,425 words)
│   └── README.md          # Source URLs and documentation
│
├── scripts/                # Processing tools
│   ├── parse_kelly.rb      # Main parser (all languages)
│   └── convert_arabic.py   # Arabic CSV converter (encoding workaround)
│
├── ATTRIBUTION.md         # Kelly Project citation and license
├── LICENSE               # MIT License for processing code
└── README.md             # This file
```

## CEFR Level Mapping

The CEFR (Common European Framework of Reference for Languages) levels are used for both proficiency classification and bonus scoring:

| Level | Description    | Bonus Score | Example Words                    |
|-------|----------------|-------------|----------------------------------|
| A1    | Beginner       | 150         | the, be, to, of, and             |
| A2    | Elementary     | 120         | will, my, one, all, would        |
| B1    | Intermediate   | 90          | however, although, therefore     |
| B2    | Upper Int.     | 60          | nevertheless, meanwhile, moreover|
| C1    | Advanced       | 30          | specialized vocabulary           |
| C2    | Proficiency    | 20          | academic/technical vocabulary     |

## Bonus Score Structure

| Tier       | Bonus Score | Description                    |
|------------|-------------|--------------------------------|
| top_50     | 200         | Most frequent words (global)   |
| top_200    | 100         | High-frequency words           |
| top_1000   | 50          | Common words                   |
| A1         | 150         | Beginner vocabulary            |
| A2         | 120         | Elementary vocabulary          |
| B1         | 90          | Intermediate vocabulary        |
| B2         | 60          | Upper-intermediate vocabulary  |
| C1         | 30          | Advanced vocabulary            |
| C2         | 20          | Proficiency vocabulary         |

## How Frequency Data Improves Suggestions

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

### Example Impact

For the typo "helo":
- Without Kelly: `["hello", "help", "tell"]`
- With Kelly: `["hello", "help", "he"]`  # "he" (top_50) moves up

For the typo "wrold":
- Without Kelly: `["world", "word", "hold"]`
- With Kelly: `["world", "would", "hold"]`  # "would" (top_50) moves up

## Data Processing

The JSON files are generated from the original Kelly Excel files using the provided parser script.

### Requirements

- Ruby 3.1+
- `roo` gem (2.10.1+)
- `roo-xls` gem (for XLS support)
- `nokogiri` gem (for XML parsing)
- Python 3 with `xlrd` (for Arabic XLS encoding issues)

### Installation

```bash
gem install roo roo-xls nokogiri
pip3 install xlrd
```

### Usage

```bash
# Parse all Kelly files
ruby scripts/parse_kelly.rb
```

The parser will:
1. Read Kelly files from the `references/` directory
2. Extract word, frequency, and CEFR data
3. Generate Kotoshu-compatible JSON files in the `data/` directory

### Arabic Special Processing

Arabic requires additional preprocessing due to encoding issues:

```bash
# The parser automatically handles Arabic via Python conversion
ruby scripts/parse_kelly.rb
```

The Python script (`scripts/convert_arabic.py`) uses `xlrd` with `encoding_override='cp1252'` to correctly read Arabic text from the Excel file.

## Source URLs

All source files are downloaded from their official locations and stored in the `references/` directory:

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

**Source**: Kelly Project - University of Leeds & University of Gothenburg
**URL**: https://spraakbanken.gu.se/eng/kelly
**DOI**: https://doi.org/10.1015/lre-2014-0012

See [ATTRIBUTION.md](ATTRIBUTION.md) for full citation and license information.

## License

This repository (processing scripts, documentation, and JSON structure) is licensed under the MIT License. The underlying frequency data is derived from the Kelly Project, which is provided for research use.

## Contributing

Contributions are welcome! This repository follows a structured approach for adding new frequency lists or updating existing ones.

### Adding a New Frequency List

To add a new frequency list for a language not currently included:

1. **Prepare your data** in one of the supported formats:
   - **Excel (.xls, .xlsx)**: Include columns for word, frequency, and optionally CEFR level
   - **XML**: Following the Kelly XML structure
   - **CSV**: With columns [word, cefr, pos, frequency]
   - **JSON**: Already in the target format

2. **Place source file** in `references/` directory:
   ```bash
   cp /path/to/your_frequency_list.xls references/your_lang_source.xls
   ```

3. **Update the parser** (`scripts/parse_kelly.rb`):
   ```ruby
   # Add to LANGUAGE_CODES hash
   LANGUAGE_CODES = {
     # ... existing languages ...
     'xx' => { name: 'YourLanguage', file: 'your_lang_source.xls', type: :local }
   }.freeze

   # Add format detection to detect_format method if needed
   def detect_format(sheet)
     # ... existing detection ...
     return :your_format if header.include?('YourLanguageHeader')
   end

   # Add parser method if format is unique
   def parse_your_format_row(row)
     # Extract word, frequency, CEFR data
   end
   ```

4. **Update source documentation** (`references/README.md`):
   ```markdown
   | YourLanguage | xx | your_lang_source.xls | Your Source URL |
   ```

5. **Run the parser**:
   ```bash
   ruby scripts/parse_kelly.rb
   ```

6. **Verify the output** in `data/xx.json`

7. **Test with Kotoshu**:
   ```ruby
   require 'kotoshu'

   strategy = Kotoshu::Suggestions::Strategies::EditDistanceStrategy.new(
     language_code: 'xx',
     frequency_tiers: {
       top_50: Set.new(JSON.parse(File.read('frequency-list-kelly/data/xx.json'))['tiers']['top_50']['words'])
     }
   )
   ```

### Updating an Existing Frequency List

If you have an updated version of an existing frequency list:

1. **Backup the current version**:
   ```bash
   cp references/existing_file.xls references/existing_file.xls.backup
   cp data/existing.json data/existing.json.backup
   ```

2. **Place the updated file** in `references/`:
   ```bash
   cp /path/to/updated_file.xls references/existing_file.xls
   ```

3. **Re-run the parser**:
   ```bash
   ruby scripts/parse_kelly.rb
   ```

4. **Compare the outputs**:
   ```bash
   diff data/existing.json.backup data/existing.json
   ```

5. **Update metadata** in the JSON file if needed (source URL, version, etc.)

6. **Document the changes** in your commit message

### Custom Frequency List Format

If your frequency list doesn't match any existing format:

1. **Create a custom parser class** in `scripts/parse_kelly.rb`:
   ```ruby
   class CustomParser < BaseParser
     def initialize(filepath, language_code)
       super(language_code)
       @filepath = filepath
     end

     def parse
       # Your custom parsing logic
       # Return array of {word:, ipm:, cefr:, rank:, pos:} hashes
     end
   end
   ```

2. **Register your parser** in the `process_language` method:
   ```ruby
   parser = case info[:file]
            when 'kelly.xml'
              XmlParser.new(filepath, code)
            when 'custom_file.ext'
              CustomParser.new(filepath, code)
            else
              ExcelParser.new(filepath, code)
            end
   ```

### Contribution Workflow

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b add-xyz-language`
3. **Make your changes**:
   - Add source file to `references/`
   - Update parser if needed
   - Run `ruby scripts/parse_kelly.rb`
   - Verify generated JSON
4. **Test your changes**:
   - Validate JSON format
   - Test with Kotoshu integration
5. **Commit with clear message**:
   ```
   Add XYZ language frequency list (1,234 words)
   - Source: XYZ Corpus 2024
   - Format: CSV with [word, freq, cefr, pos]
   - CEFR levels: A1-C2
   ```
6. **Push and create pull request**

### Validation Checklist

Before submitting, ensure:

- [ ] Source file added to `references/` with proper attribution
- [ ] Parser updated to handle new format (if needed)
- [ ] JSON file generated in `data/` directory
- [ ] JSON validates against the format schema
- [ ] Word count is reasonable (not 0 or extremely high)
- [ ] CEFR levels are present if applicable
- [ ] Top 50/200/1000 tiers contain actual words
- [ ] Documentation updated (README.md, references/README.md)
- [ ] Example tested with Kotoshu (if applicable)

### Areas for Contribution

- **New Languages**: Add frequency data for languages not yet included (German, Spanish, French, Portuguese, Japanese, Korean, etc.)
- **Format Support**: Improve processing scripts for additional Excel/XML/CSV formats
- **Validation**: Add automated tests for generated JSON files
- **Documentation**: Improve examples and usage guides
- **Performance**: Optimize parser for large datasets

## Links

- [Kotoshu Spell Checker](https://github.com/kotoshu/kotoshu)
- [Kelly Project](https://spraakbanken.gu.se/eng/kelly)
- [CEFR Levels](https://www.coe.int/en/web/common-european-framework-of-reference-for-languages)

## Acknowledgments

We gratefully acknowledge the Kelly Project team:

- Adam Kilgarriff (Lexical Computing Ltd)
- Foteini Charalabopoulou (Aristotle University of Thessaloniki)
- Maria Gavrilidou (ILSP / Athena R.C.)
- Lars Borin Johannessen (University of Gothenburg)
- Sima Khalil (University of Leeds)
- Dimitrios Kokkinakis (University of Gothenburg)
- Rachele Lew (Lexical Computing Ltd)
- Serge Sharoff (University of Leeds)
- Ravikiran Vadlapudi (University of Leeds)
- Elena Volodina (University of Gothenburg)
