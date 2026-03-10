# frozen_string_literal: true

module ChunkerRuby
  class Token < BaseSplitter
    def initialize(tokenizer: nil, **kwargs)
      super(**kwargs)
      @tokenizer = resolve_tokenizer(tokenizer)
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      if @tokenizer
        split_by_tokens(text, metadata)
      else
        split_by_estimation(text, metadata)
      end
    end

    private

    def resolve_tokenizer(tokenizer)
      case tokenizer
      when nil
        try_load_default_tokenizer
      when String, Symbol
        try_load_tokenizer(tokenizer.to_s)
      else
        tokenizer # assume it responds to #encode and #decode
      end
    end

    def try_load_default_tokenizer
      try_load_tokenizer("gpt2")
    end

    def try_load_tokenizer(name)
      require "tokenizer_ruby"
      TokenizerRuby::Tokenizer.new(name)
    rescue LoadError
      nil
    end

    def split_by_tokens(text, metadata)
      tokens = @tokenizer.encode(text)
      chunks = []
      start = 0
      current_pos = 0

      while start < tokens.length
        end_pos = [start + @chunk_size, tokens.length].min
        chunk_tokens = tokens[start...end_pos]
        raw_text = @tokenizer.decode(chunk_tokens)
        stripped = raw_text.strip

        offset = text.index(stripped, current_pos) || current_pos
        current_pos = offset + stripped.length

        chunks << Chunk.new(
          text: raw_text,
          index: chunks.size,
          offset: offset,
          metadata: metadata.merge(token_count: chunk_tokens.length)
        )

        break if end_pos >= tokens.length

        start += @chunk_size - @chunk_overlap
      end

      chunks
    end

    def split_by_estimation(text, metadata)
      # Estimate ~4 chars per token
      char_chunk_size = @chunk_size * 4
      char_overlap = @chunk_overlap * 4

      char_splitter = Character.new(
        chunk_size: char_chunk_size,
        chunk_overlap: char_overlap
      )
      char_splitter.split(text, metadata: metadata)
    end
  end
end
