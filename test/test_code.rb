# frozen_string_literal: true

require "test_helper"

class TestCode < Minitest::Test
  include TestHelpers

  def test_empty_text
    splitter = ChunkerRuby::Code.new(language: :ruby, chunk_size: 100, chunk_overlap: 0)
    assert_equal [], splitter.split("")
  end

  def test_ruby_splitting
    text = read_fixture("sample.rb")
    splitter = ChunkerRuby::Code.new(language: :ruby, chunk_size: 200, chunk_overlap: 20)
    chunks = splitter.split(text)

    assert chunks.length >= 1
    assert_valid_chunks(chunks)
    assert_equal :ruby, chunks.first.metadata[:language]
  end

  def test_unsupported_language
    assert_raises(ArgumentError) do
      ChunkerRuby::Code.new(language: :cobol)
    end
  end

  def test_supported_languages
    %i[ruby python javascript typescript].each do |lang|
      splitter = ChunkerRuby::Code.new(language: lang, chunk_size: 100, chunk_overlap: 0)
      chunks = splitter.split("function hello() {\n  return 1;\n}")
      assert chunks.length >= 1, "Failed for #{lang}"
    end
  end

  def test_preserves_language_metadata
    splitter = ChunkerRuby::Code.new(language: :python, chunk_size: 500)
    chunks = splitter.split("def foo():\n    pass\n\ndef bar():\n    pass")
    chunks.each do |chunk|
      assert_equal :python, chunk.metadata[:language]
    end
  end
end
