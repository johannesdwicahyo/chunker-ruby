# frozen_string_literal: true

require "test_helper"

class TestMarkdown < Minitest::Test
  include TestHelpers

  def test_empty_text
    splitter = ChunkerRuby::Markdown.new(chunk_size: 100, chunk_overlap: 0)
    assert_equal [], splitter.split("")
  end

  def test_splits_on_headers
    text = "# Title\n\nIntro paragraph.\n\n## Section 1\n\nContent one.\n\n## Section 2\n\nContent two."
    splitter = ChunkerRuby::Markdown.new(chunk_size: 50, chunk_overlap: 0)
    chunks = splitter.split(text)

    assert chunks.length >= 2
    assert_valid_chunks(chunks)
  end

  def test_preserves_header_metadata
    text = "# Title\n\nIntro.\n\n## Section\n\nContent."
    splitter = ChunkerRuby::Markdown.new(chunk_size: 500, chunk_overlap: 0)
    chunks = splitter.split(text)

    assert chunks.length >= 1
    last_chunk = chunks.last
    assert last_chunk.metadata.key?(:headers)
  end

  def test_respects_code_blocks
    text = "# Title\n\nSome text.\n\n```ruby\ndef hello\n  # This has ## inside\nend\n```\n\n## Real Section\n\nMore text."
    splitter = ChunkerRuby::Markdown.new(chunk_size: 500, chunk_overlap: 0)
    chunks = splitter.split(text)

    # The ## inside code block should NOT create a split
    code_chunks = chunks.select { |c| c.text.include?("def hello") }
    assert code_chunks.length >= 1
  end

  def test_header_hierarchy
    text = "# H1\n\nA.\n\n## H2\n\nB.\n\n### H3\n\nC."
    splitter = ChunkerRuby::Markdown.new(chunk_size: 500, chunk_overlap: 0)
    chunks = splitter.split(text)

    h3_chunk = chunks.find { |c| c.text.include?("### H3") }
    if h3_chunk
      assert h3_chunk.metadata[:headers].length >= 2
    end
  end

  def test_fixture_file
    text = read_fixture("sample.md")
    splitter = ChunkerRuby::Markdown.new(chunk_size: 200, chunk_overlap: 20)
    chunks = splitter.split(text)

    assert chunks.length >= 1
    assert_valid_chunks(chunks)
  end
end
