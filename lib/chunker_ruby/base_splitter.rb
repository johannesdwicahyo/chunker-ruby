# frozen_string_literal: true

module ChunkerRuby
  class BaseSplitter
    attr_reader :chunk_size, :chunk_overlap

    def initialize(chunk_size: 1000, chunk_overlap: 200, **options)
      raise ArgumentError, "chunk_size must be positive" unless chunk_size > 0
      raise ArgumentError, "chunk_overlap must be non-negative" unless chunk_overlap >= 0
      raise ArgumentError, "chunk_overlap must be less than chunk_size" unless chunk_overlap < chunk_size

      @chunk_size = chunk_size
      @chunk_overlap = chunk_overlap
    end

    def split(text, metadata: {})
      raise NotImplementedError, "#{self.class}#split must be implemented"
    end

    def split_many(texts)
      texts.flat_map.with_index { |t, i| split(t, metadata: { doc_index: i }) }
    end

    private

    def build_chunks(pieces, original_text, metadata: {})
      chunks = []
      current_pos = 0

      merged = merge_pieces(pieces)

      merged.each do |chunk_text|
        next if chunk_text.strip.empty?

        # Find the actual position starting from current_pos
        offset = original_text.index(chunk_text, current_pos) || current_pos

        chunks << Chunk.new(
          text: chunk_text,
          index: chunks.size,
          offset: offset,
          metadata: metadata.dup
        )

        current_pos = offset + chunk_text.length
      end

      chunks
    end

    def merge_pieces(pieces)
      merged = []
      current_parts = []
      current_length = 0

      pieces.each do |piece|
        piece_len = piece.length

        if current_length + piece_len > @chunk_size && !current_parts.empty?
          merged << current_parts.join

          # Handle overlap: keep trailing parts that fit within overlap size
          overlap_parts = []
          overlap_length = 0
          current_parts.reverse_each do |part|
            if overlap_length + part.length <= @chunk_overlap
              overlap_parts.unshift(part)
              overlap_length += part.length
            else
              break
            end
          end

          current_parts = overlap_parts
          current_length = overlap_length
        end

        current_parts << piece
        current_length += piece_len
      end

      merged << current_parts.join unless current_parts.empty?

      merged
    end
  end
end
