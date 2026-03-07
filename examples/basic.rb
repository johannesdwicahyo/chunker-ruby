#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/chunker_ruby"

text = <<~TEXT
  Ruby is a dynamic, open source programming language with a focus on simplicity
  and productivity. It has an elegant syntax that is natural to read and easy to write.

  Ruby was created by Yukihiro "Matz" Matsumoto in the mid-1990s. It was designed
  for programmer happiness and emphasizes the principle of least surprise.

  The language supports multiple programming paradigms, including object-oriented,
  functional, and imperative programming. Everything in Ruby is an object, including
  primitive data types like integers and booleans.

  Ruby on Rails, often simply called Rails, is a web application framework written
  in Ruby. It follows the model-view-controller pattern and emphasizes convention
  over configuration and the don't repeat yourself principle.
TEXT

puts "=== Simple split (RecursiveCharacter default) ==="
chunks = ChunkerRuby.split(text, chunk_size: 200, chunk_overlap: 50)
chunks.each do |chunk|
  puts "\n--- Chunk #{chunk.index} (offset: #{chunk.offset}, length: #{chunk.length}) ---"
  puts chunk.text
end

puts "\n=== Character splitter ==="
splitter = ChunkerRuby::Character.new(chunk_size: 150, chunk_overlap: 30)
chunks = splitter.split(text)
puts "#{chunks.length} chunks created"

puts "\n=== Sentence splitter ==="
splitter = ChunkerRuby::Sentence.new(chunk_size: 200, chunk_overlap: 0)
chunks = splitter.split(text)
chunks.each do |chunk|
  puts "\n--- Chunk #{chunk.index} ---"
  puts chunk.text.strip
end

puts "\n=== Markdown splitter ==="
markdown = <<~MD
  # Getting Started

  Welcome to the guide.

  ## Installation

  Run `gem install chunker-ruby` to install.

  ## Usage

  Here is a basic example of how to use the library.
MD

splitter = ChunkerRuby::Markdown.new(chunk_size: 100, chunk_overlap: 0)
chunks = splitter.split(markdown)
chunks.each do |chunk|
  puts "\n--- Chunk #{chunk.index} (headers: #{chunk.metadata[:headers]&.join(" > ")}) ---"
  puts chunk.text.strip
end
