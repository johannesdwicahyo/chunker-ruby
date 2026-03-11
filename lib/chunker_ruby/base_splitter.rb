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
      # Pre-compute offsets for each piece to avoid re-searching (fixes duplicate text)
      piece_offsets = compute_piece_offsets(pieces, original_text)
      merged = merge_pieces_with_offsets(pieces, piece_offsets)

      merged.map.with_index do |entry|
        next if entry[:text].strip.empty?

        Chunk.new(
          text: entry[:text],
          index: 0, # will be reindexed below
          offset: entry[:offset],
          metadata: metadata.dup
        )
      end.compact.each_with_index.map do |chunk, i|
        Chunk.new(text: chunk.text, index: i, offset: chunk.offset, metadata: chunk.metadata)
      end
    end

    def compute_piece_offsets(pieces, original_text)
      offsets = []
      pos = 0
      pieces.each do |piece|
        idx = original_text.index(piece, pos)
        if idx
          offsets << idx
          pos = idx + piece.length
        else
          offsets << pos
        end
      end
      offsets
    end

    def merge_pieces(pieces)
      merge_pieces_with_offsets(pieces, nil).map { |e| e[:text] }
    end

    def merge_pieces_with_offsets(pieces, piece_offsets)
      merged = []
      current_parts = []
      current_offsets = []
      current_length = 0

      pieces.each_with_index do |piece, i|
        piece_len = piece.length

        if current_length + piece_len > @chunk_size && !current_parts.empty?
          merged << { text: current_parts.join, offset: current_offsets.first || 0 }

          # Handle overlap: keep trailing parts that fit within overlap size
          overlap_parts = []
          overlap_offsets = []
          overlap_length = 0
          current_parts.zip(current_offsets).reverse_each do |part, off|
            if overlap_length + part.length <= @chunk_overlap
              overlap_parts.unshift(part)
              overlap_offsets.unshift(off)
              overlap_length += part.length
            else
              break
            end
          end

          current_parts = overlap_parts
          current_offsets = overlap_offsets
          current_length = overlap_length
        end

        current_parts << piece
        current_offsets << (piece_offsets ? piece_offsets[i] : 0)
        current_length += piece_len
      end

      merged << { text: current_parts.join, offset: current_offsets.first || 0 } unless current_parts.empty?

      merged
    end
  end
end
