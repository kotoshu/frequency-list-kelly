#!/usr/bin/env ruby
# frozen_string_literal: true

require 'roo'
require 'roo-xls' # Required for XLS (Excel 97-2003) support
require 'json'
require 'fileutils'
require 'nokogiri'
require 'csv'

##
# Kelly Frequency List Parser for Kotoshu
#
# This script parses Kelly Project frequency lists (Excel and XML formats)
# and converts them to Kotoshu-compatible JSON format.
#
# Usage:
#   ruby scripts/parse_kelly.rb
#
# Input:
#   Kelly Excel files: ar_m3.xls, en_m3.xls, it_m3.xls, ru_m3.xls, zh_m3.xls
#   Kelly XML files: swedish-kelly.xml
#
# Output:
#   data/ar.json, data/en.json, data/it.json, data/ru.json, data/sv.json, data/zh.json
#
# Attribution:
#   Kelly Project - University of Leeds & University of Gothenburg
#   Kilgarriff, A., et al. (2014). Corpus-based vocabulary lists for language
#   learners for nine languages. Language Resources and Evaluation, 48(2), 121-163.
#   DOI: https://doi.org/10.1015/lre-2014-0012
#

module KellyParser
  # CEFR level ordering for bonus scores
  CEFR_LEVELS = %w[A1 A2 B1 B2 C1 C2].freeze

  # Language mapping from Kelly codes to ISO 639-1
  # All files stored locally in references/ directory
  LANGUAGE_CODES = {
    'ar' => { name: 'Arabic', file: 'ar_m3.xls', type: :local },
    'zh' => { name: 'Chinese', file: 'zh_m3.xls', type: :local },
    'en' => { name: 'English', file: 'en_m3.xls', type: :local },
    'el' => { name: 'Greek', file: 'KELLY_EL.xlsx', type: :local },
    'it' => { name: 'Italian', file: 'it_m3.xls', type: :local },
    'no' => { name: 'Norwegian', file: 'Norwegian-Kelly.xls', type: :local },
    'ru' => { name: 'Russian', file: 'ru_m3.xls', type: :local },
    'sv' => { name: 'Swedish', file: 'kelly.xml', type: :local }
  }.freeze

  class BaseParser
    attr_reader :data, :language_code

    def initialize(language_code)
      @language_code = language_code
      @data = []
    end

    def parse
      raise NotImplementedError, 'Subclasses must implement parse method'
    end
  end

  class ExcelParser < BaseParser
    attr_reader :filepath

    def initialize(filepath, language_code)
      super(language_code)
      @filepath = filepath
    end

    # Parse Kelly Excel file and extract word data
    def parse
      puts "Parsing #{@filepath}..."

      workbook = Roo::Spreadsheet.open(@filepath)
      sheet_name = workbook.sheets.first
      sheet = workbook.sheet(sheet_name)
      puts "  Sheet: #{sheet_name}"
      puts "  Dimensions: #{sheet.last_row} rows x #{sheet.last_column} columns"

      # Detect format and parse accordingly
      format = detect_format(sheet)
      puts "  Format: #{format}"

      parse_sheet(sheet, format)

      puts "  Parsed #{@data.size} words"
      workbook.close
      @data
    end

    private

    # Detect the format of the Excel file based on header and structure
    def detect_format(sheet)
      header = sheet.row(1).map { |h| h.to_s.downcase }.join(' ')
      col_count = sheet.last_column

      # Greek format: [ID, Frequency, ‰, CEF level, Lemma, ...] (9 columns, Greek headers)
      # Check for Greek characters first before checking for "ID" or other common terms
      return :greek if col_count >= 9 || header.include?('συχνότητα') || header.include?('cef level')

      # Russian format: [Lemma, CEFR, POS, Frq abs, Frq ipm]
      return :russian if header.include?('lemma') && header.include?('frq')

      # Norwegian format: [Norwegian, POS] (2 columns, Norwegian header)
      return :norwegian if header.include?('norwegian')

      # Chinese format: [Chinese, CEFR] (2 columns)
      return :chinese if header.include?('chinese') || (col_count == 2 && !header.include?('norwegian'))

      # Italian format: [Lemma, Pos, Points/CEFR] (3 columns)
      return :italian if (header.include?('lemma') && col_count <= 3) || col_count == 3

      # English format: [ID, Word, POS, CEFR, Points] (5 columns)
      return :english if header.include?('id') || header.include?('word') || col_count == 5

      # Arabic format: many columns, first few empty
      return :arabic if col_count >= 10

      # Default fallback based on column count
      case col_count
      when 2 then :chinese
      when 3 then :italian
      when 5 then :english
      when 9 then :greek
      else :russian
      end
    end

    # Parse sheet based on detected format
    def parse_sheet(sheet, format)
      current_row = 2

      while (row = sheet.row(current_row))
        break if row.all?(&:nil?)
        next if row.compact.empty?

        word_data = case format
                    when :english then parse_english_row(row)
                    when :russian then parse_russian_row(row)
                    when :italian then parse_italian_row(row)
                    when :chinese then parse_chinese_row(row)
                    when :arabic then parse_arabic_row(row)
                    when :greek then parse_greek_row(row)
                    when :norwegian then parse_norwegian_row(row)
                    else nil
                    end

        @data << word_data if word_data
        current_row += 1
      end
    end

    # English format: [ID, Word, POS, CEFR, Points]
    def parse_english_row(row)
      return nil if row.size < 5
      return nil if row[1].nil? || row[1].to_s.strip.empty?

      word = row[1].to_s.strip
      cefr = extract_cefr(row[3].to_s)
      points = row[4].to_s.to_f
      rank = row[0].to_s.to_i

      { word: word, ipm: points, cefr: cefr, rank: rank, pos: row[2].to_s.strip }
    end

    # Russian format: [Word, CEFR, POS, Frq abs, Frq ipm]
    def parse_russian_row(row)
      return nil if row.size < 5
      return nil if row[0].nil? || row[0].to_s.strip.empty?

      word = row[0].to_s.strip
      cefr = extract_cefr(row[1].to_s)
      ipm = row[4].to_s.to_f
      rank = @data.size + 1

      { word: word, ipm: ipm, cefr: cefr, rank: rank, pos: row[2].to_s.strip }
    end

    # Italian format: [Lemma, Pos, Points/CEFR]
    def parse_italian_row(row)
      return nil if row.size < 3
      return nil if row[0].nil? || row[0].to_s.strip.empty?

      word = row[0].to_s.strip
      cefr = extract_cefr(row[2].to_s)
      # Points column contains CEFR level, use rank as proxy
      rank = @data.size + 1

      { word: word, ipm: 0, cefr: cefr, rank: rank, pos: row[1].to_s.strip }
    end

    # Chinese format: [Chinese, CEFR]
    def parse_chinese_row(row)
      return nil if row.size < 2
      return nil if row[0].nil? || row[0].to_s.strip.empty?

      word = row[0].to_s.strip
      cefr = extract_cefr(row[1].to_s)
      rank = @data.size + 1

      { word: word, ipm: 0, cefr: cefr, rank: rank, pos: '' }
    end

    # Arabic format: complex with empty columns
    # Columns: [empty, empty, empty, empty, CEFR, empty, Freq, ...]
    def parse_arabic_row(row)
      return nil if row.size < 7

      # Find the word - it's usually in the first non-empty column
      word = nil
      row.each do |cell|
        next if cell.nil? || cell.to_s.strip.empty?
        word = cell.to_s.strip
        break
      end

      return nil if word.nil? || word.empty?

      # CEFR is in column 4
      cefr = extract_cefr(row[4].to_s)
      # Freq is in column 6
      ipm = row[6].to_s.to_f
      rank = @data.size + 1

      { word: word, ipm: ipm, cefr: cefr, rank: rank, pos: '' }
    end

    # Greek format: [ID, Frequency, ‰, CEF level, Lemma, MWE, Part of speech, Translation, Comments]
    # Columns: 0=ID, 1=Frequency, 2=‰, 3=CEF level, 4=Lemma (Greek word), 5=MWE, 6=POS, 7=Translation, 8=Comments
    def parse_greek_row(row)
      return nil if row.size < 5
      return nil if row[4].nil? || row[4].to_s.strip.empty?

      word = row[4].to_s.strip  # Lemma is in column 4
      cefr = extract_cefr(row[3].to_s)  # CEF level is in column 3
      # Frequency data is in column 2 (‰ per million)
      ipm = row[2].to_s.to_f
      rank = @data.size + 1

      { word: word, ipm: ipm, cefr: cefr, rank: rank, pos: row[6].to_s.strip }
    end

    # Norwegian format: [Norwegian, POS] - simple 2-column format
    # Note: Norwegian Kelly file doesn't include CEFR levels in the main sheet
    def parse_norwegian_row(row)
      return nil if row.size < 2
      return nil if row[0].nil? || row[0].to_s.strip.empty?

      word = row[0].to_s.strip
      # No CEFR data in Norwegian format
      rank = @data.size + 1

      { word: word, ipm: 0, cefr: nil, rank: rank, pos: row[1].to_s.strip }
    end

    # Extract CEFR level from raw string, handling fancy quotes
    def extract_cefr(cefr_raw)
      return nil if cefr_raw.nil? || cefr_raw.empty?

      # Remove all types of quotes including fancy quotes using Unicode ranges
      cefr_clean = cefr_raw.gsub(/["\u201C\u201D']/, '').strip.upcase
      cefr_clean if CEFR_LEVELS.include?(cefr_clean)
    end
  end

  class XmlParser < BaseParser
    attr_reader :filepath

    def initialize(filepath, language_code)
      super(language_code)
      @filepath = filepath
    end

    # Parse Swedish Kelly XML file
    def parse
      puts "Parsing #{@filepath}..."

      doc = File.open(@filepath) { |f| Nokogiri::XML(f) }

      # Kelly XML CEFR mapping: 1=A1, 2=A2, 3=B1, 4=B2, 5=C1, 6=C2
      cefr_mapping = {
        '1' => 'A1', '2' => 'A2', '3' => 'B1',
        '4' => 'B2', '5' => 'C1', '6' => 'C2'
      }

      entries = doc.xpath('//LexicalEntry')
      puts "  Found #{entries.size} entries"

      rank = 1
      entries.each do |entry|
        word = entry.at_xpath('.//feat[@att="writtenForm"]')&.attr('val')&.strip
        cefr_num = entry.at_xpath('.//feat[@att="cefr"]')&.attr('val')
        pos = entry.at_xpath('.//feat[@att="partOfSpeech"]')&.attr('val')&.strip || ''

        next if word.nil? || word.empty?

        cefr = cefr_mapping[cefr_num]
        wpm = entry.at_xpath('.//feat[@att="wpm"]')&.attr('val')
        ipm = wpm ? wpm.gsub(',', '.').to_f : 0

        @data << {
          word: word,
          ipm: ipm,
          cefr: cefr,
          rank: rank,
          pos: pos
        }

        rank += 1
      end

      puts "  Parsed #{@data.size} words"
      @data
    end
  end

  # CSV Parser for Arabic (Python-converted due to encoding issues)
  class CsvParser < BaseParser
    attr_reader :filepath

    def initialize(filepath, language_code)
      super(language_code)
      @filepath = filepath
    end

    # Parse CSV file generated by Python xlrd
    # Format: [Word, CEFR, POS, Frequency]
    def parse
      puts "Parsing #{@filepath}..."

      rank = 1
      CSV.foreach(@filepath, encoding: 'UTF-8') do |row|
        word = row[0]&.strip
        cefr_raw = row[1]&.strip
        pos = row[2]&.strip
        freq = row[3]&.strip

        next if word.nil? || word.empty?

        cefr = if cefr_raw && CEFR_LEVELS.include?(cefr_raw.upcase)
                 cefr_raw.upcase
               else
                 # Try to extract from Arabic/hybrid text
                 cefr_clean = cefr_raw.to_s.gsub(/["\u201C\u201D']/, '').strip.upcase
                 cefr_clean if CEFR_LEVELS.include?(cefr_clean)
               end

        ipm = freq ? freq.to_f : 0

        @data << {
          word: word,
          ipm: ipm,
          cefr: cefr,
          rank: rank,
          pos: pos
        }

        rank += 1
      end

      puts "  Parsed #{@data.size} words"
      @data
    end
  end

  # Generate Kotoshu-compatible JSON format
  class JsonGenerator
    attr_reader :data, :language_code, :language_name

    def initialize(data, language_code, language_name)
      @data = data
      @language_code = language_code
      @language_name = language_name
    end

    # Generate Kotoshu-compatible JSON structure
    def generate
      # Sort by rank (ID number) to maintain frequency order
      ranked_data = @data.select { |d| d[:rank] && d[:rank] > 0 }
      sorted_data = ranked_data.sort_by { |d| d[:rank] }

      {
        metadata: metadata,
        tiers: generate_tiers(sorted_data),
        full_list: sorted_data
      }
    end

    private

    def metadata
      {
        language: @language_code,
        language_name: @language_name,
        source: "Kelly Project - University of Leeds & University of Gothenburg",
        source_url: "https://spraakbanken.gu.se/eng/kelly",
        citation: "Kilgarriff, A., Charalabopoulou, F., Gavrilidou, M., Johannessen, L. B., " \
                   "Khalil, S., Kokkinakis, S., Lew, R., Sharoff, S., Vadlapudi, R., " \
                   "Volodina, E. (2014). Corpus-based vocabulary lists for language learners " \
                   "for nine languages. Language Resources and Evaluation, 48(2), 121-163.",
        doi: "https://doi.org/10.1015/lre-2014-0012",
        total_words: @data.size,
        cefr_levels: @data.map { |d| d[:cefr] }.compact.uniq.sort,
        license: "Research use - see Kelly project terms",
        processed_date: Time.now.utc.iso8601,
        kotoshu_version: "1.0.0",
        note: "Generated from Kelly Project frequency lists. See ATTRIBUTION.md for details."
      }
    end

    def generate_tiers(sorted_data)
      tiers = {}

      # Top N tiers
      tiers[:top_50] = create_tier(sorted_data.first(50), "Top 50 most frequent words", 200)
      tiers[:top_200] = create_tier(sorted_data.first(200), "Top 200 most frequent words", 100)
      tiers[:top_1000] = create_tier(sorted_data.first(1000), "Top 1000 most frequent words", 50)

      # CEFR-level tiers
      CEFR_LEVELS.each do |level|
        level_data = sorted_data.select { |d| d[:cefr] == level }
        level_sym = level.downcase.to_sym
        bonus_score = case level
                      when 'A1' then 150
                      when 'A2' then 120
                      when 'B1' then 90
                      when 'B2' then 60
                      when 'C1' then 30
                      when 'C2' then 20
                      else 0
                      end
        tiers[level_sym] = create_tier(level_data.map { |d| d[:word] },
                                       "CEFR #{level} level words",
                                       bonus_score)
      end

      tiers
    end

    def create_tier(words, description, bonus_score)
      {
        words: words.map { |d| d.is_a?(Hash) ? d[:word] : d },
        description: description,
        bonus_score: bonus_score
      }
    end
  end

  # CLI interface
  class CLI
    OUTPUT_DIR = ENV['OUTPUT_DIR'] || File.join(File.dirname(__FILE__), '..', 'data')
    REFERENCES_DIR = ENV['REFERENCES_DIR'] || File.join(File.dirname(__FILE__), '..', 'references')

    def run
      puts "=" * 70
      puts "Kelly Frequency List Parser for Kotoshu"
      puts "=" * 70
      puts
      puts "References directory: #{REFERENCES_DIR}"
      puts "Output directory: #{OUTPUT_DIR}"
      puts

      FileUtils.mkdir_p(OUTPUT_DIR)

      # Process all available languages
      LANGUAGE_CODES.each do |code, info|
        process_language(code, info)
      end

      puts
      puts "=" * 70
      puts "Parsing complete!"
      puts "=" * 70
      puts
      puts "Generated files:"
      Dir.glob(File.join(OUTPUT_DIR, '*.json')).sort.each do |file|
        puts "  #{file}"
      end
    end

    private

    def process_language(code, info)
      # Special handling for Arabic: convert to CSV first using Python
      if code == 'ar'
        process_arabic_via_csv(code, info)
        return
      end

      # All other files are now stored locally in references/ directory
      filepath = File.join(REFERENCES_DIR, info[:file])

      return unless File.exist?(filepath)

      puts "Processing #{info[:name]} (#{code})..."

      parser = case info[:file]
               when 'kelly.xml'
                 XmlParser.new(filepath, code)
               else
                 ExcelParser.new(filepath, code)
               end

      data = parser.parse

      if data.empty?
        puts "  Warning: No data parsed, skipping JSON generation"
        return
      end

      generator = JsonGenerator.new(data, code, info[:name])
      json_data = generator.generate

      output_file = File.join(OUTPUT_DIR, "#{code}.json")
      File.write(output_file, JSON.pretty_generate(json_data))

      puts "  Generated: #{output_file}"
      puts "  Total words: #{json_data[:metadata][:total_words]}"
      puts "  CEFR levels: #{json_data[:metadata][:cefr_levels].join(', ')}"
      puts
    end

    # Special processing for Arabic due to encoding issues
    def process_arabic_via_csv(code, info)
      csv_file = File.join(OUTPUT_DIR, 'arabic_from_csv.csv')

      # Convert Arabic Excel to CSV using Python
      puts "Processing #{info[:name]} (#{code})..."
      puts "  Converting Excel to CSV using Python (encoding: cp1252)..."

      python_script = File.join(File.dirname(__FILE__), 'convert_arabic.py')
      result = system("python3", python_script)

      if !result || !File.exist?(csv_file)
        puts "  Error: Failed to convert Arabic file to CSV"
        return
      end

      # Parse the CSV file
      puts "  Parsing CSV file..."
      parser = CsvParser.new(csv_file, code)
      data = parser.parse

      if data.empty?
        puts "  Warning: No data parsed from CSV"
        return
      end

      generator = JsonGenerator.new(data, code, info[:name])
      json_data = generator.generate

      output_file = File.join(OUTPUT_DIR, "#{code}.json")
      File.write(output_file, JSON.pretty_generate(json_data))

      puts "  Generated: #{output_file}"
      puts "  Total words: #{json_data[:metadata][:total_words]}"
      puts "  CEFR levels: #{json_data[:metadata][:cefr_levels].join(', ')}"
      puts
    end
  end
end

# Run if executed directly
if __FILE__ == $PROGRAM_NAME
  KellyParser::CLI.new.run
end
