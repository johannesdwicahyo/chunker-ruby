# frozen_string_literal: true

require "json"

module ChunkerRuby
  class JSONSplitter < BaseSplitter
    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      parsed = ::JSON.parse(text)
      pieces = extract_pieces(parsed)
      chunks = []
      current_pos = 0

      current_parts = []
      current_length = 0

      pieces.each do |piece|
        json_str = ::JSON.generate(piece)

        if current_length + json_str.length > @chunk_size && !current_parts.empty?
          chunk_text = ::JSON.generate(current_parts.length == 1 ? current_parts.first : current_parts)
          # Search for a key or value from the first piece to approximate offset
          offset = find_json_offset(text, current_parts.first, current_pos)
          current_pos = offset + chunk_text.length
          chunks << Chunk.new(
            text: chunk_text,
            index: chunks.size,
            offset: offset,
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
        offset = find_json_offset(text, current_parts.first, current_pos)
        chunks << Chunk.new(
          text: chunk_text,
          index: chunks.size,
          offset: offset,
          metadata: metadata.dup
        )
      end

      chunks
    end

    private

    def find_json_offset(text, first_piece, current_pos)
      # Try to find a recognizable key or value from the first piece in the original text
      search_str = case first_piece
                   when Hash
                     first_piece.keys.first.to_s
                   when String
                     first_piece
                   else
                     first_piece.to_s
                   end

      # Search for the key/value string as it would appear in JSON (quoted)
      quoted = "\"#{search_str}\""
      text.index(quoted, current_pos) || text.index(search_str, current_pos) || current_pos
    end

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
