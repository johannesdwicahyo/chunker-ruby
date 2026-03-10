# frozen_string_literal: true

module ChunkerRuby
  class Chunk
    attr_reader :text, :index, :offset, :length, :metadata

    def initialize(text:, index:, offset:, metadata: {})
      @text = text
      @index = index
      @offset = offset
      @length = text.length
      @metadata = metadata
    end

    def token_count(tokenizer = nil)
      if tokenizer
        tokenizer.encode(text).length
      else
        # Rough estimation: ~4 characters per token for English
        (text.length / 4.0).ceil
      end
    end

    def to_s
      @text
    end

    def to_h
      { text: @text, index: @index, offset: @offset, length: @length, metadata: @metadata }
    end

    def valid?(original_text = nil)
      return false if text.nil? || text.empty?
      return false if offset.negative?
      return false if index.negative?
      if original_text
        return false unless original_text[offset, text.length] == text
      end
      true
    end

    def ==(other)
      other.is_a?(Chunk) && text == other.text && index == other.index && offset == other.offset
    end
  end
end
