# frozen_string_literal: true

require "test_helper"

class TestSentence < Minitest::Test
  include TestHelpers

  def test_empty_text
    splitter = ChunkerRuby::Sentence.new(chunk_size: 100, chunk_overlap: 0)
    assert_equal [], splitter.split("")
    assert_equal [], splitter.split(nil)
  end

  def test_single_sentence
    splitter = ChunkerRuby::Sentence.new(chunk_size: 100, chunk_overlap: 0)
    chunks = splitter.split("Hello world.")
    assert_equal 1, chunks.length
    assert_equal "Hello world.", chunks.first.text
  end

  def test_multiple_sentences
    text = "First sentence. Second sentence. Third sentence. Fourth sentence."
    splitter = ChunkerRuby::Sentence.new(chunk_size: 40, chunk_overlap: 0)
    chunks = splitter.split(text)
    assert chunks.length >= 1
    assert_valid_chunks(chunks)
  end

  def test_min_max_chunk_size
    splitter = ChunkerRuby::Sentence.new(min_chunk_size: 50, max_chunk_size: 200, chunk_overlap: 0)
    assert_equal 200, splitter.chunk_size
  end

  def test_preserves_sentence_boundaries
    text = "Dr. Smith went to the store. He bought milk. Then he left."
    splitter = ChunkerRuby::Sentence.new(chunk_size: 200, chunk_overlap: 0)
    chunks = splitter.split(text)
    assert chunks.length >= 1
  end
end
