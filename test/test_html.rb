# frozen_string_literal: true

require "test_helper"

class TestHTML < Minitest::Test
  include TestHelpers

  def test_empty_text
    splitter = ChunkerRuby::HTML.new(chunk_size: 100, chunk_overlap: 0)
    assert_equal [], splitter.split("")
  end

  def test_splits_on_block_tags
    text = read_fixture("sample.html")
    splitter = ChunkerRuby::HTML.new(chunk_size: 200, chunk_overlap: 20)
    chunks = splitter.split(text)

    assert chunks.length >= 1
    assert_valid_chunks(chunks)
  end

  def test_strip_tags
    text = "<p>Hello <b>world</b></p><p>Second paragraph</p>"
    splitter = ChunkerRuby::HTML.new(strip_tags: true, chunk_size: 500)
    chunks = splitter.split(text)

    chunks.each do |chunk|
      refute chunk.text.include?("<p>"), "Tags should be stripped"
      refute chunk.text.include?("<b>"), "Tags should be stripped"
    end
  end

  def test_preserve_tags
    text = "<p>Hello <b>world</b></p>"
    splitter = ChunkerRuby::HTML.new(strip_tags: false, chunk_size: 500)
    chunks = splitter.split(text)

    assert chunks.any? { |c| c.text.include?("<b>") }, "Tags should be preserved"
  end
end
