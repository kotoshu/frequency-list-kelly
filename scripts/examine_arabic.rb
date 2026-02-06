#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to examine Arabic Kelly Excel file

require 'roo'
require 'roo-xls'

EXCEL_FILE = '/Users/mulgogi/src/external/ssharoff.github.io/kelly/ar_m3.xls'

workbook = Roo::Spreadsheet.open(EXCEL_FILE)
sheet = workbook.sheet('Arabic')

puts "Arabic Excel File Structure"
puts "=" * 70
puts "Dimensions: #{sheet.last_row} rows x #{sheet.last_column} columns"
puts

puts "Header row (row 1):"
puts "-" * 70
header = sheet.row(1)
header.each_with_index do |h, i|
  puts "  Column #{i}: #{h.inspect}"
end

puts
puts "First 10 data rows with column indices:"
puts "-" * 70
(2..11).each do |row_num|
  row = sheet.row(row_num)
  puts "Row #{row_num}:"
  row.each_with_index do |cell, i|
    next if cell.nil? || cell.to_s.strip.empty?
    puts "  [#{i}] #{cell.to_s.strip[0..50]}"
  end
  puts
end

workbook.close
