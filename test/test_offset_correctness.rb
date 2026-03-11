# frozen_string_literal: true

require_relative "test_helper"

class TestOffsetCorrectness < Minitest::Test
  # Verify that chunk offsets are correct for all splitter strategies
  # by checking that original_text[offset, chunk.length] == chunk.text

  def verify_offsets(chunks, original_text)
    chunks.each do |chunk|
      extracted = original_text[chunk.offset, chunk.text.length]
      assert_equal chunk.text, extracted,
        "Chunk ##{chunk.index} offset #{chunk.offset} mismatch: " \
        "expected #{chunk.text.inspect[0..60]}, got #{extracted&.inspect&.[](0..60)}"
    end
  end

  def test_character_splitter_offsets
    text = "The quick brown fox jumps over the lazy dog. " * 10
    splitter = ChunkerRuby::Character.new(chunk_size: 50, chunk_overlap: 10)
    chunks = splitter.split(text)
    refute_empty chunks
    verify_offsets(chunks, text)
  end

  def test_recursive_character_offsets
    text = "First paragraph here.\n\nSecond paragraph here.\n\nThird paragraph here.\n\nFourth paragraph."
    splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 40, chunk_overlap: 5)
    chunks = splitter.split(text)
    refute_empty chunks
    verify_offsets(chunks, text)
  end

  def test_sentence_splitter_offsets
    text = "Hello world. This is a test. Another sentence here. " * 5
    splitter = ChunkerRuby::Sentence.new(chunk_size: 80, chunk_overlap: 10)
    chunks = splitter.split(text)
    refute_empty chunks
    verify_offsets(chunks, text)
  end

  def test_separator_splitter_offsets
    text = "item1, item2, item3, item4, item5, item6, item7, item8"
    splitter = ChunkerRuby::Separator.new(separator: ", ", chunk_size: 20, chunk_overlap: 5)
    chunks = splitter.split(text)
    refute_empty chunks
    verify_offsets(chunks, text)
  end

  def test_markdown_splitter_offsets
    text = "# Heading\n\nSome text here.\n\n## Sub Heading\n\nMore text.\n\n### Another\n\nEven more text."
    splitter = ChunkerRuby::Markdown.new(chunk_size: 40, chunk_overlap: 5)
    chunks = splitter.split(text)
    refute_empty chunks
    verify_offsets(chunks, text)
  end
end

class TestDuplicateTextOffsets < Minitest::Test
  # Test that duplicate text segments get correct (non-overlapping) offsets

  def test_character_duplicate_text
    text = "hello " * 20
    splitter = ChunkerRuby::Character.new(chunk_size: 18, chunk_overlap: 6)
    chunks = splitter.split(text)
    refute_empty chunks

    # Offsets should be monotonically increasing
    offsets = chunks.map(&:offset)
    offsets.each_cons(2) do |a, b|
      assert_operator a, :<, b, "Offsets should increase: #{offsets.inspect}"
    end
  end

  def test_sentence_duplicate_text
    text = "This is a test. " * 10
    splitter = ChunkerRuby::Sentence.new(chunk_size: 50, chunk_overlap: 10)
    chunks = splitter.split(text)
    refute_empty chunks

    offsets = chunks.map(&:offset)
    offsets.each_cons(2) do |a, b|
      assert_operator a, :<, b, "Offsets should increase: #{offsets.inspect}"
    end
  end
end

class TestUnicodeOffsets < Minitest::Test
  def test_unicode_character_offsets
    # Multibyte characters: each emoji is multiple bytes but 1 char in Ruby
    text = "Hello! This is great. Another one here. More text follows."
    splitter = ChunkerRuby::Character.new(chunk_size: 25, chunk_overlap: 5)
    chunks = splitter.split(text)
    refute_empty chunks

    chunks.each do |chunk|
      extracted = text[chunk.offset, chunk.text.length]
      assert_equal chunk.text, extracted,
        "Unicode offset mismatch at chunk ##{chunk.index}"
    end
  end

  def test_cjk_character_offsets
    text = "Ruby language." * 5
    splitter = ChunkerRuby::Character.new(chunk_size: 20, chunk_overlap: 5)
    chunks = splitter.split(text)
    refute_empty chunks

    chunks.each do |chunk|
      extracted = text[chunk.offset, chunk.text.length]
      assert_equal chunk.text, extracted,
        "CJK offset mismatch at chunk ##{chunk.index}"
    end
  end
end
