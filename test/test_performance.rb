# frozen_string_literal: true

require_relative "test_helper"

class TestPerformance < Minitest::Test
  def test_large_document_character_splitter
    # 1MB+ document
    text = "The quick brown fox jumps over the lazy dog. " * 25_000
    assert text.bytesize > 1_000_000, "Test text should be >1MB"

    splitter = ChunkerRuby::Character.new(chunk_size: 1000, chunk_overlap: 200)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    chunks = splitter.split(text)
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    refute_empty chunks
    assert_operator elapsed, :<, 10.0, "Character split of 1MB should complete in <10s (took #{elapsed.round(2)}s)"
  end

  def test_large_document_recursive_splitter
    text = ("Paragraph content here. " * 100 + "\n\n") * 500
    assert text.bytesize > 1_000_000, "Test text should be >1MB"

    splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 1000, chunk_overlap: 200)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    chunks = splitter.split(text)
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    refute_empty chunks
    assert_operator elapsed, :<, 10.0, "Recursive split of 1MB should complete in <10s (took #{elapsed.round(2)}s)"
  end

  def test_large_document_sentence_splitter
    text = "This is sentence number one. " * 40_000
    assert text.bytesize > 1_000_000, "Test text should be >1MB"

    splitter = ChunkerRuby::Sentence.new(chunk_size: 1000, chunk_overlap: 200)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    chunks = splitter.split(text)
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    refute_empty chunks
    assert_operator elapsed, :<, 10.0, "Sentence split of 1MB should complete in <10s (took #{elapsed.round(2)}s)"
  end
end
