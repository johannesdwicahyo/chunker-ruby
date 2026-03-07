# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "chunker_ruby"
require "minitest/autorun"

module TestHelpers
  def fixture_path(name)
    File.join(File.dirname(__FILE__), "fixtures", name)
  end

  def read_fixture(name)
    File.read(fixture_path(name))
  end

  def assert_no_gaps(chunks, original_text)
    # Verify chunks cover the original text (minus overlap)
    combined = chunks.map(&:text).join
    original_text.split(/\s+/).each do |word|
      assert combined.include?(word), "Word '#{word}' missing from chunks"
    end
  end

  def assert_valid_chunks(chunks)
    chunks.each_with_index do |chunk, i|
      assert_equal i, chunk.index, "Chunk index mismatch at position #{i}"
      assert chunk.text.length > 0, "Empty chunk at index #{i}"
      assert chunk.offset >= 0, "Negative offset at index #{i}"
    end
  end
end
