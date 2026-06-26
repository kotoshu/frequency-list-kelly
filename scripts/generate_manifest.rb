#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Hash every data/<lang>.json frequency list and emit manifest.json at
# the repo root. Format matches Kotoshu::Integrity::Manifest in the gem.

require "digest"
require "json"
require "time"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "manifest.json")
DATA_DIR = File.join(ROOT, "data")

resources = {}
Dir.children(DATA_DIR).sort.each do |fname|
  next unless fname.end_with?(".json")
  abs = File.join(DATA_DIR, fname)
  next unless File.file?(abs)

  bytes = File.read(abs, mode: "rb")
  parsed = JSON.parse(bytes) rescue {}
  meta = parsed["metadata"] || {}
  lang = meta["language"] || fname.sub(/\.json\z/, "")

  resources["data/#{fname}"] = {
    size: bytes.bytesize,
    sha256: Digest::SHA256.hexdigest(bytes),
    language: lang,
    type: "frequency",
    license: "CC BY-SA 3.0",
    source: meta["source_url"],
    citation: meta["citation"]
  }.compact
end

manifest = {
  version: 1,
  generated_at: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
  repo_version: "v1",
  resource_count: resources.size,
  language_count: resources.size,
  resources: resources
}

File.write(MANIFEST_PATH, JSON.pretty_generate(manifest) + "\n")
puts "Wrote #{MANIFEST_PATH}"
puts "  #{resources.size} frequency lists"
