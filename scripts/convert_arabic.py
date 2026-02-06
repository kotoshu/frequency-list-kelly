#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Convert Arabic Kelly Excel to CSV for Ruby processing
# Usage: python scripts/convert_arabic.py

import xlrd
import csv
import sys
import os

ARABIC_FILE = 'references/ar_m3.xls'
OUTPUT_FILE = 'data/arabic_from_csv.csv'

print("Converting Arabic Excel to CSV...")
print("=" * 70)

try:
    book = xlrd.open_workbook(ARABIC_FILE, encoding_override='cp1252')
    sheet = book.sheet_by_index(0)  # First sheet

    print(f"Rows: {sheet.nrows}, Cols: {sheet.ncols}")

    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)

        # Skip header row (row 0) - starts from row 1
        for row_idx in range(1, sheet.nrows):
            row = sheet.row_values(row_idx)

            # Skip empty rows
            if all(str(v).strip() == '' for v in row):
                continue

            # Extract: CEFR (col 5), Freq (col 6), POS (col 2), Word (col 4)
            cefr = str(row[5]).strip() if row[5] else ''
            freq = str(row[6]).strip() if row[6] else ''
            pos = str(row[2]).strip() if row[2] else ''
            word = str(row[4]).strip() if row[4] else ''

            # Skip if word is empty
            if not word:
                continue

            writer.writerow([word, cefr, pos, freq])

    print(f"Written {OUTPUT_FILE}")
    print(f"File size: {os.path.getsize(OUTPUT_FILE)} bytes")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
