# frozen_string_literal: true

require_relative "chunker_ruby/version"
require_relative "chunker_ruby/chunk"
require_relative "chunker_ruby/base_splitter"
require_relative "chunker_ruby/character"
require_relative "chunker_ruby/separator"
require_relative "chunker_ruby/recursive_character"
require_relative "chunker_ruby/sentence"
require_relative "chunker_ruby/markdown"
require_relative "chunker_ruby/html"
require_relative "chunker_ruby/code"
require_relative "chunker_ruby/json_splitter"
require_relative "chunker_ruby/token"
require_relative "chunker_ruby/semantic"
require_relative "chunker_ruby/sliding_window"

module ChunkerRuby
  def self.split(text, chunk_size: 1000, chunk_overlap: 200, **options)
    RecursiveCharacter.new(chunk_size: chunk_size, chunk_overlap: chunk_overlap, **options).split(text)
  end
end
