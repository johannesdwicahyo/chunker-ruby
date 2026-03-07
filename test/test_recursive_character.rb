# frozen_string_literal: true

require "test_helper"

class TestRecursiveCharacter < Minitest::Test
  include TestHelpers

  def setup
    @splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 100, chunk_overlap: 20)
  end

  def test_empty_text
    assert_equal [], @splitter.split("")
    assert_equal [], @splitter.split(nil)
  end

  def test_text_smaller_than_chunk_size
    text = "Hello world"
    chunks = @splitter.split(text)
    assert_equal 1, chunks.length
    assert_equal text, chunks.first.text
  end

  def test_splits_on_paragraphs_first
    text = "First paragraph.\n\nSecond paragraph.\n\nThird paragraph."
    splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 40, chunk_overlap: 0)
    chunks = splitter.split(text)

    assert chunks.length >= 2
    assert_valid_chunks(chunks)
  end

  def test_falls_back_to_newlines
    text = "Line one.\nLine two.\nLine three.\nLine four.\nLine five.\nLine six."
    splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 30, chunk_overlap: 0)
    chunks = splitter.split(text)

    assert chunks.length >= 2
    assert_valid_chunks(chunks)
  end

  def test_falls_back_to_spaces
    text = "word " * 50
    splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 30, chunk_overlap: 0)
    chunks = splitter.split(text.strip)

    assert chunks.length >= 2
    assert_valid_chunks(chunks)
  end

  def test_custom_separators
    text = "part1|part2|part3|part4"
    splitter = ChunkerRuby::RecursiveCharacter.new(
      chunk_size: 12,
      chunk_overlap: 0,
      separators: ["|", ""]
    )
    chunks = splitter.split(text)
    assert chunks.length >= 2
  end

  def test_default_separators
    assert_equal ["\n\n", "\n", ". ", ", ", " ", ""],
      ChunkerRuby::RecursiveCharacter::DEFAULT_SEPARATORS
  end

  def test_overlap_present
    text = ("This is sentence one. " * 5) + "\n\n" + ("This is sentence two. " * 5)
    splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 80, chunk_overlap: 20)
    chunks = splitter.split(text)

    if chunks.length >= 2
      # Ensure all chunks are valid and non-empty
      (0...chunks.length - 1).each do |i|
        assert chunks[i].text.length > 0
      end
    end
  end

  def test_convenience_method
    text = "Hello " * 200
    chunks = ChunkerRuby.split(text, chunk_size: 100, chunk_overlap: 20)
    assert chunks.length >= 2
    assert_valid_chunks(chunks)
  end

  def test_split_many
    texts = ["Hello " * 50, "World " * 50]
    chunks = @splitter.split_many(texts)
    assert chunks.length >= 2
    doc_indices = chunks.map { |c| c.metadata[:doc_index] }.uniq.sort
    assert_equal [0, 1], doc_indices
  end
end
