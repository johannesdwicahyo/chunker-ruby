# frozen_string_literal: true

require "test_helper"

class TestSemantic < Minitest::Test
  include TestHelpers

  def test_empty_text
    embed = ->(text) { [0.0] * 10 }
    splitter = ChunkerRuby::Semantic.new(embed: embed)
    assert_equal [], splitter.split("")
  end

  def test_single_sentence
    embed = ->(text) { [1.0] * 10 }
    splitter = ChunkerRuby::Semantic.new(embed: embed)
    chunks = splitter.split("Just one sentence.")
    assert_equal 1, chunks.length
  end

  def test_splits_on_topic_change
    call_count = 0
    embed = lambda do |text|
      call_count += 1
      if text.include?("weather") || text.include?("rain") || text.include?("sunny")
        [1.0, 0.0, 0.0, 0.0, 0.0]
      else
        [0.0, 0.0, 0.0, 0.0, 1.0]
      end
    end

    text = "The weather is nice today. It might rain tomorrow. The sun is sunny. " \
           "Ruby is a programming language. Python is also popular. JavaScript runs in browsers."
    splitter = ChunkerRuby::Semantic.new(embed: embed, threshold: 0.5, min_chunk_size: 10)
    chunks = splitter.split(text)

    assert chunks.length >= 2, "Should split on topic change"
    assert_valid_chunks(chunks)
  end

  def test_respects_max_chunk_size
    embed = ->(text) { [1.0, 0.0, 0.0] }
    splitter = ChunkerRuby::Semantic.new(embed: embed, max_chunk_size: 50, min_chunk_size: 5)
    text = "Word. " * 100
    chunks = splitter.split(text)

    chunks.each do |chunk|
      assert chunk.text.length <= 55, "Chunk exceeds max size: #{chunk.text.length}"
    end
  end
end
