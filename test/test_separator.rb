# frozen_string_literal: true

require "test_helper"

class TestSeparator < Minitest::Test
  include TestHelpers

  def test_split_on_double_newline
    text = "Part one.\n\nPart two.\n\nPart three."
    splitter = ChunkerRuby::Separator.new(separator: "\n\n", chunk_size: 50, chunk_overlap: 0)
    chunks = splitter.split(text)
    assert chunks.length >= 1
    assert_valid_chunks(chunks)
  end

  def test_split_on_custom_separator
    text = "a|b|c|d|e"
    splitter = ChunkerRuby::Separator.new(separator: "|", chunk_size: 5, chunk_overlap: 0)
    chunks = splitter.split(text)
    assert chunks.length >= 1
  end

  def test_empty_text
    splitter = ChunkerRuby::Separator.new(chunk_size: 100, chunk_overlap: 0)
    assert_equal [], splitter.split("")
  end

  def test_regex_separator
    text = "one1two2three3four"
    splitter = ChunkerRuby::Separator.new(separator: /\d/, chunk_size: 10, chunk_overlap: 0)
    chunks = splitter.split(text)
    assert chunks.length >= 1
  end

  def test_keep_separator_false
    text = "Part one.\n\nPart two.\n\nPart three."
    splitter = ChunkerRuby::Separator.new(
      separator: "\n\n", keep_separator: false,
      chunk_size: 50, chunk_overlap: 0
    )
    chunks = splitter.split(text)
    chunks.each do |chunk|
      refute chunk.text.include?("\n\n"), "Separator should be removed"
    end
  end

  def test_offset_correctness
    text = "Part one.\n\nPart two.\n\nPart three.\n\nPart four."
    splitter = ChunkerRuby::Separator.new(separator: "\n\n", chunk_size: 25, chunk_overlap: 0)
    chunks = splitter.split(text)
    chunks.each do |chunk|
      assert_equal chunk.text, text[chunk.offset, chunk.text.length],
        "Offset mismatch for chunk #{chunk.index}"
    end
  end
end
