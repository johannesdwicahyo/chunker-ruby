# frozen_string_literal: true

require "test_helper"

class TestCharacter < Minitest::Test
  include TestHelpers

  def setup
    @splitter = ChunkerRuby::Character.new(chunk_size: 100, chunk_overlap: 20)
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
    assert_equal 0, chunks.first.index
    assert_equal 0, chunks.first.offset
  end

  def test_single_character
    chunks = @splitter.split("a")
    assert_equal 1, chunks.length
    assert_equal "a", chunks.first.text
  end

  def test_exact_chunk_size
    text = "a" * 100
    chunks = @splitter.split(text)
    assert_equal 1, chunks.length
  end

  def test_splits_with_overlap
    text = "a" * 200
    chunks = @splitter.split(text)

    assert_equal 3, chunks.length
    assert_equal 100, chunks[0].text.length
    assert_equal 100, chunks[1].text.length
    assert_equal 0, chunks[0].offset
    assert_equal 80, chunks[1].offset
  end

  def test_chunk_objects
    text = "Hello " * 50
    chunks = @splitter.split(text)

    assert_valid_chunks(chunks)
    chunks.each do |chunk|
      assert chunk.text.length <= 100
      assert_instance_of Hash, chunk.metadata
    end
  end

  def test_metadata_passed_through
    chunks = @splitter.split("Hello world", metadata: { source: "test" })
    assert_equal({ source: "test" }, chunks.first.metadata)
  end

  def test_unicode_text
    text = "日本語のテスト文章です。" * 20
    chunks = @splitter.split(text)
    assert chunks.length >= 1
    assert_valid_chunks(chunks)
  end

  def test_to_h
    chunks = @splitter.split("Hello world")
    h = chunks.first.to_h
    assert_equal "Hello world", h[:text]
    assert_equal 0, h[:index]
    assert_equal 0, h[:offset]
  end

  def test_to_s
    chunks = @splitter.split("Hello world")
    assert_equal "Hello world", chunks.first.to_s
  end

  def test_offset_correctness
    text = "the the the the"
    splitter = ChunkerRuby::Character.new(chunk_size: 8, chunk_overlap: 0)
    chunks = splitter.split(text)
    chunks.each do |chunk|
      assert_equal chunk.text, text[chunk.offset, chunk.text.length],
        "Offset mismatch for chunk #{chunk.index}"
    end
  end

  def test_offset_correctness_with_overlap
    text = "abcdefghijklmnopqrstuvwxyz" * 5
    splitter = ChunkerRuby::Character.new(chunk_size: 20, chunk_overlap: 5)
    chunks = splitter.split(text)
    chunks.each do |chunk|
      assert_equal chunk.text, text[chunk.offset, chunk.text.length],
        "Offset mismatch for chunk #{chunk.index}"
    end
  end

  def test_chunk_valid_method
    chunks = @splitter.split("Hello world")
    assert chunks.first.valid?
    assert chunks.first.valid?("Hello world")
  end

  def test_chunk_valid_rejects_bad_offset
    chunk = ChunkerRuby::Chunk.new(text: "hello", index: 0, offset: 99)
    refute chunk.valid?("hello world")
  end

  def test_chunk_valid_without_original_text
    chunk = ChunkerRuby::Chunk.new(text: "hello", index: 0, offset: 0)
    assert chunk.valid?
  end

  def test_chunk_valid_empty_text
    chunk = ChunkerRuby::Chunk.new(text: "", index: 0, offset: 0)
    refute chunk.valid?
  end
end
