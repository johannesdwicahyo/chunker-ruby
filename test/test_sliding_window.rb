# frozen_string_literal: true

require "test_helper"

class TestSlidingWindow < Minitest::Test
  include TestHelpers

  def test_empty_text
    splitter = ChunkerRuby::SlidingWindow.new(chunk_size: 100, chunk_overlap: 0)
    assert_equal [], splitter.split("")
  end

  def test_basic_sliding
    text = "a" * 200
    splitter = ChunkerRuby::SlidingWindow.new(chunk_size: 100, chunk_overlap: 50)
    chunks = splitter.split(text)

    assert_equal 3, chunks.length
    assert_equal 100, chunks[0].text.length
    assert_equal 0, chunks[0].offset
    assert_equal 50, chunks[1].offset
    assert_equal 100, chunks[2].offset
  end

  def test_custom_stride
    text = "a" * 200
    splitter = ChunkerRuby::SlidingWindow.new(chunk_size: 100, chunk_overlap: 0, stride: 30)
    chunks = splitter.split(text)

    assert chunks.length >= 4
    assert_equal 30, chunks[1].offset
  end

  def test_stride_validation
    assert_raises(ArgumentError) do
      ChunkerRuby::SlidingWindow.new(chunk_size: 100, chunk_overlap: 0, stride: 0)
    end
  end

  def test_offset_correctness
    text = "abcdefghij" * 10
    splitter = ChunkerRuby::SlidingWindow.new(chunk_size: 20, chunk_overlap: 5)
    chunks = splitter.split(text)
    chunks.each do |chunk|
      assert_equal chunk.text, text[chunk.offset, chunk.text.length],
        "Offset mismatch for chunk #{chunk.index}"
    end
  end
end
