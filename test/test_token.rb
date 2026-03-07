# frozen_string_literal: true

require "test_helper"

class TestToken < Minitest::Test
  include TestHelpers

  def test_empty_text
    splitter = ChunkerRuby::Token.new(chunk_size: 100, chunk_overlap: 10)
    assert_equal [], splitter.split("")
  end

  def test_falls_back_to_character_estimation
    # Without tokenizer-ruby installed, should fall back to char-based estimation
    splitter = ChunkerRuby::Token.new(chunk_size: 50, chunk_overlap: 10)
    text = "Hello world. " * 100
    chunks = splitter.split(text)

    assert chunks.length >= 1
    assert_valid_chunks(chunks)
  end

  def test_small_text
    splitter = ChunkerRuby::Token.new(chunk_size: 1000, chunk_overlap: 100)
    chunks = splitter.split("Hello world")
    assert_equal 1, chunks.length
  end
end
