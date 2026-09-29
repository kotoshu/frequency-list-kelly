#!/usr/bin/env ruby
# Romanization retrieval table: fold-normalized ALA-LC keys -> native
# words (interscript schemes; the gem's cross-script channel consumer).
#   ruby scripts/build_translit_table.rb --lang ar --scheme alalc-ara-Arab-Latn-1997
require "optparse"
$LOAD_PATH.unshift(File.expand_path("~/src/interscript/interscript/ruby/lib"))
require "interscript"
require "json"

options = { scheme: "alalc-ara-Arab-Latn-1997" }
OptionParser.new do |o|
  o.on("--lang LANG") { |v| options[:lang] = v }
  o.on("--scheme CODE") { |v| options[:scheme] = v }
end.parse!
lang = options.fetch(:lang)
scheme = options.fetch(:scheme)

# Fold semantics mirror the gem's fold_word: NFD-strip combining marks
# (ALA-LC output carries dots/diacritics) + downcase + scheme
# punctuation stripped (al-slm indexes as alslm).
fold = ->(s) { s.unicode_normalize(:nfd).gsub(/[̀-ͯ]/, "").downcase.gsub(/[-'’]/, "") }

list_path = File.join(ENV["HOME"], ".cache/kotoshu/frequency-lists", lang, "frequency.json")
words = JSON.parse(File.read(list_path))["full_list"].map { |e| e["word"] }

table = {}
words.each do |w|
  rom = fold.(Interscript.transliterate(scheme, w))
  next if rom.empty?
  (table[rom] ||= []) << w
end
sizes = Hash.new(0)
table.each_value { |v| sizes[v.length] += 1 }
puts "words: #{words.length}, distinct keys: #{table.length}, collisions: #{table.length - sizes[1]}"

out_path = "/tmp/#{lang}.translit.json"
File.write(out_path, JSON.pretty_generate(table))
puts "wrote #{out_path} (#{File.size(out_path)} bytes)"
