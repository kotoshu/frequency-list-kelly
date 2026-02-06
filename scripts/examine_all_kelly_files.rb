#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to examine Kelly Excel file structures
# Usage: ruby scripts/examine_all_kelly_files.rb

require 'roo'
require 'roo-xls'

KELLY_PATH = '/Users/mulgogi/src/external/ssharoff.github.io/kelly'

FILES_TO_CHECK = {
  'ar' => 'ar_m3.xls',
  'it' => 'it_m3.xls',
  'zh' => 'zh_m3.xls'
}.freeze

FILES_TO_CHECK.each do |code, filename|
  filepath = File.join(KELLY_PATH, filename)

  puts "=" * 70
  puts "Examining: #{filename} (#{code})"
  puts "=" * 70

  next unless File.exist?(filepath)

  workbook = Roo::Spreadsheet.open(filepath)
  puts "Class: #{workbook.class}"
  puts "Sheets: #{workbook.sheets.join(', ')}"
  puts

  sheet = workbook.sheet(workbook.sheets.first)
  puts "Dimensions: #{sheet.last_row} rows x #{sheet.last_column} columns"
  puts

  # Examine header
  puts "Header row (row 1):"
  puts "-" * 70
  header = sheet.row(1)
  puts header.map { |h| h.to_s[0..30] }.join(' | ')
  puts

  # Examine first 5 data rows
  puts "First 5 data rows:"
  puts "-" * 70
  (2..[6, sheet.last_row].min).each do |row_num|
    row = sheet.row(row_num)
    puts "Row #{row_num}: #{row.map { |c| c.to_s.strip[0..30] }.join(' | ')}"
  end

  puts
  puts "Sample words with CEFR:"
  puts "-" * 70
  (2..[10, sheet.last_row].min).each do |row_num|
    row = sheet.row(row_num)
    word = row[0]
    cefr = row[3]
    puts "  #{word.to_s.ljust(30)} CEFR: #{cefr.to_s}"
  end

  workbook.close
  puts
end
