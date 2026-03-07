# frozen_string_literal: true

require "json"

module ChunkerRuby
  class JSONSplitter < BaseSplitter
    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      parsed = ::JSON.parse(text)
      pieces = extract_pieces(parsed)
      chunks = []

      current_parts = []
      current_length = 0

      pieces.each do |piece|
        json_str = ::JSON.generate(piece)

        if current_length + json_str.length > @chunk_size && !current_parts.empty?
          chunk_text = ::JSON.generate(current_parts.length == 1 ? current_parts.first : current_parts)
          chunks << Chunk.new(
            text: chunk_text,
            index: chunks.size,
            offset: 0,
            metadata: metadata.dup
          )
          current_parts = []
          current_length = 0
        end

        current_parts << piece
        current_length += json_str.length
      end

      unless current_parts.empty?
        chunk_text = ::JSON.generate(current_parts.length == 1 ? current_parts.first : current_parts)
        chunks << Chunk.new(
          text: chunk_text,
          index: chunks.size,
          offset: 0,
          metadata: metadata.dup
        )
      end

      chunks
    end

    private

    def extract_pieces(parsed)
      case parsed
      when Array
        parsed
      when Hash
        parsed.map { |k, v| { k => v } }
      else
        [parsed]
      end
    end
  end
end
