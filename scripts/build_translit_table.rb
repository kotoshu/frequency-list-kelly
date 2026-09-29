$LOAD_PATH.unshift(File.expand_path("~/src/interscript/interscript/ruby/lib"))
require "interscript"
require "json"

# Fold semantics mirror the gem's fold_word: NFD-strip combining marks
# (the ALA-LC output carries ḥ/ā-style dots) + downcase.
fold = ->(s) { s.unicode_normalize(:nfd).gsub(/[̀-ͯ]/, "").downcase.gsub(/[-'’]/, "") }

list_path = File.join(ENV["HOME"], ".cache/kotoshu/frequency-lists/ar/frequency.json")
words = JSON.parse(File.read(list_path))["full_list"].map { |e| e["word"] }

table = {}
words.each do |w|
  rom = fold.(Interscript.transliterate("alalc-ara-Arab-Latn-1997", w))
  next if rom.empty?
  (table[rom] ||= []) << w
end
# collision profile
sizes = Hash.new(0)
table.each_value { |v| sizes[v.length] += 1 }
puts "words: #{words.length}, distinct keys: #{table.length}, collisions: #{table.length - sizes[1]}"
puts "size histogram (top): " + sizes.sort.first(5).map { |k, v| "#{k}->#{v}" }.join(" ")
File.write("/tmp/ar.translit.json", JSON.pretty_generate(table))
puts "wrote /tmp/ar.translit.json (#{File.size("/tmp/ar.translit.json")} bytes)"
# spot checks
%w[mrhb slm alslm ktb].each { |k| puts "  #{k} => #{(table[k] || []).first(3).inspect}" }
