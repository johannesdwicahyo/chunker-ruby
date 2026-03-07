# frozen_string_literal: true

module ChunkerRuby
  class SlidingWindow < BaseSplitter
    def initialize(stride: nil, **kwargs)
      super(**kwargs)
      @stride = stride || (@chunk_size - @chunk_overlap)
      raise ArgumentError, "stride must be positive" unless @stride > 0
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      chunks = []
      start = 0

      while start < text.length
        end_pos = [start + @chunk_size, text.length].min
        chunk_text = text[start...end_pos]

        chunks << Chunk.new(
          text: chunk_text,
          index: chunks.size,
          offset: start,
          metadata: metadata.dup
        )

        break if end_pos >= text.length

        start += @stride
      end

      chunks
    end
  end
end
