# frozen_string_literal: true

module ChunkerRuby
  class RecursiveCharacter < BaseSplitter
    DEFAULT_SEPARATORS = ["\n\n", "\n", ". ", ", ", " ", ""].freeze

    def initialize(separators: nil, keep_separator: true, **kwargs)
      super(**kwargs)
      @separators = separators || DEFAULT_SEPARATORS
      @keep_separator = keep_separator
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      chunks = recursive_split(text, @separators)
      merge_chunks(chunks, text, metadata: metadata)
    end

    private

    def recursive_split(text, separators)
      return [text] if text.length <= @chunk_size
      return [text] if separators.empty?

      separator = separators.first
      remaining_separators = separators[1..]

      pieces = split_by_separator(text, separator)

      result = []
      pieces.each do |piece|
        if piece.length <= @chunk_size
          result << piece
        elsif remaining_separators.any?
          result.concat(recursive_split(piece, remaining_separators))
        else
          result << piece
        end
      end

      result
    end

    def split_by_separator(text, separator)
      if separator.empty?
        return text.chars
      end

      parts = text.split(separator, -1)
      return parts unless @keep_separator && parts.length > 1

      result = []
      parts.each_with_index do |part, i|
        if i < parts.length - 1
          result << part + separator unless part.empty? && i > 0
        else
          result << part unless part.empty?
        end
      end
      result.empty? ? [text] : result
    end

    def merge_chunks(pieces, original_text, metadata: {})
      build_chunks(pieces, original_text, metadata: metadata)
    end
  end
end
