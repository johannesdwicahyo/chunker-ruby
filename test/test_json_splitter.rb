# frozen_string_literal: true

require "test_helper"
require "json"

class TestJSONSplitter < Minitest::Test
  include TestHelpers

  def test_empty_text
    splitter = ChunkerRuby::JSONSplitter.new(chunk_size: 100, chunk_overlap: 0)
    assert_equal [], splitter.split("")
  end

  def test_splits_array
    data = (1..20).map { |i| { "id" => i, "name" => "Item #{i}" } }
    text = JSON.generate(data)
    splitter = ChunkerRuby::JSONSplitter.new(chunk_size: 200, chunk_overlap: 0)
    chunks = splitter.split(text)

    assert chunks.length >= 2
    assert_valid_chunks(chunks)
    chunks.each { |c| assert JSON.parse(c.text) }
  end

  def test_splits_object
    data = {}
    10.times { |i| data["key_#{i}"] = "value " * 20 }
    text = JSON.generate(data)
    splitter = ChunkerRuby::JSONSplitter.new(chunk_size: 300, chunk_overlap: 0)
    chunks = splitter.split(text)

    assert chunks.length >= 1
    chunks.each { |c| assert JSON.parse(c.text) }
  end

  def test_offsets_are_non_negative_and_increasing
    data = (1..20).map { |i| { "id" => i, "name" => "Item #{i}" } }
    text = JSON.generate(data)
    splitter = ChunkerRuby::JSONSplitter.new(chunk_size: 200, chunk_overlap: 0)
    chunks = splitter.split(text)

    assert chunks.length >= 2
    chunks.each do |chunk|
      assert chunk.offset >= 0, "Offset should be non-negative for chunk #{chunk.index}"
    end

    # Offsets should be non-decreasing
    (1...chunks.length).each do |i|
      assert chunks[i].offset >= chunks[i - 1].offset,
        "Offsets should be non-decreasing: chunk #{i} offset #{chunks[i].offset} < chunk #{i - 1} offset #{chunks[i - 1].offset}"
    end
  end
end
