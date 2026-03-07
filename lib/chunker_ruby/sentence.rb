# frozen_string_literal: true

require "strscan"

module ChunkerRuby
  class Sentence < BaseSplitter
    ABBREVIATIONS = %w[
      Mr Mrs Ms Dr Prof Sr Jr St Gen Gov Sgt Cpl Pvt
      Inc Corp Ltd Co vs etc al
      Jan Feb Mar Apr Jun Jul Aug Sep Oct Nov Dec
      Ave Blvd Dept Div Est Fig
    ].freeze

    def initialize(min_chunk_size: nil, max_chunk_size: nil, **kwargs)
      chunk_size = max_chunk_size || kwargs[:chunk_size] || 1000
      super(chunk_size: chunk_size, **kwargs.except(:chunk_size))
      @min_chunk_size = min_chunk_size || (@chunk_size / 3)
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      sentences = split_into_sentences(text)
      build_chunks(sentences, text, metadata: metadata)
    end

    private

    def split_into_sentences(text)
      sentences = []
      current = +""

      text.scan(/[^.!?]*[.!?]+[\s]*|[^.!?]+\s*/) do |segment|
        current << segment

        # Check if this looks like a real sentence end
        if segment.match?(/[.!?]\s*\z/) && real_sentence_end?(current)
          sentences << current
          current = +""
        end
      end

      sentences << current unless current.strip.empty?
      sentences.empty? ? [text] : sentences
    end

    def real_sentence_end?(text)
      stripped = text.rstrip
      return false if stripped.empty?

      # Check for abbreviations: "Dr.", "Mr.", etc.
      ABBREVIATIONS.each do |abbr|
        return false if stripped.end_with?("#{abbr}.")
      end

      # Check for decimal numbers: "3.14"
      return false if stripped.match?(/\d\.\z/)

      # Check for ellipsis
      return false if stripped.end_with?("...")

      true
    end
  end
end
