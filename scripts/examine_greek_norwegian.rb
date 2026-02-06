#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to examine Greek and Norwegian Kelly files
# Usage: ruby scripts/examine_greek_norwegian.rb

require 'roo'
require 'roo-xls'

NORWEGIAN_FILE = '/Users/mulgogi/src/kotoshu/frequency-list-kelly/Norwegian-Kelly.xls'
GREEK_FILE = '/Users/mulgogi/src/kotoshu/frequency-list-kelly/KELLY_EL.xlsx'

# Examine Norwegian (XLS)
puts "=" * 70
puts "Norwegian Kelly File (XLS)"
puts "=" * 70

if File.exist?(NORWEGIAN_FILE)
  workbook = Roo::Spreadsheet.open(NORWEGIAN_FILE)
  puts "Sheets: #{workbook.sheets.join(', ')}"

  sheet = workbook.sheet(workbook.sheets.first)
  puts "Dimensions: #{sheet.last_row} rows x #{sheet.last_column} columns"
  puts

  puts "Header row (row 1):"
  puts "-" * 70
  header = sheet.row(1)
  header.each_with_index do |h, i|
    puts "  [#{i}] #{h.to_s[0..50]}"
  end
  puts

  puts "First 5 data rows:"
  puts "-" * 70
  (2..6).each do |row_num|
    row = sheet.row(row_num)
    puts "Row #{row_num}: #{row.map { |c| c.to_s.strip[0..30] }.join(' | ')}"
  end

  workbook.close
end

puts
puts "=" * 70
puts "Greek Kelly File (XLSX)"
puts "=" * 70

if File.exist?(GREEK_FILE)
  begin
    workbook = Roo::Spreadsheet.open(GREEK_FILE)
    puts "Sheets: #{workbook.sheets.join(', ')}"

    sheet = workbook.sheet(workbook.sheets.first)
    puts "Dimensions: #{sheet.last_row} rows x #{sheet.last_column} columns"
    puts

    puts "Header row (row 1):"
    puts "-" * 70
    header = sheet.row(1)
    header.each_with_index do |h, i|
      puts "  [#{i}] #{h.to_s[0..50]}"
    end
    puts

    puts "First 5 data rows:"
    puts "-" * 70
    (2..6).each do |row_num|
      row = sheet.row(row_num)
      puts "Row #{row_num}: #{row.map { |c| c.to_s.strip[0..30] }.join(' | ')}"
    end

    workbook.close
  rescue => e
    puts "Error opening Greek file: #{e.class} - #{e.message}"
    puts "The XLSX format may require the 'roo-xls' gem or 'caxlsx' gem"
  end
end
