# frozen_string_literal: true

module ChunkerRuby
  class HTML < BaseSplitter
    BLOCK_TAGS = %w[
      div p section article aside main header footer nav
      h1 h2 h3 h4 h5 h6 blockquote pre ul ol li table tr
      form fieldset details summary figure figcaption
    ].freeze

    def initialize(strip_tags: false, **kwargs)
      super(**kwargs)
      @strip_tags = strip_tags
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      sections = split_by_tags(text)
      chunks = []

      sections.each do |section|
        content = @strip_tags ? strip_html_tags(section[:text]) : section[:text]
        next if content.strip.empty?

        if content.length <= @chunk_size
          chunks << Chunk.new(
            text: content,
            index: chunks.size,
            offset: section[:offset],
            metadata: metadata.dup
          )
        else
          sub_splitter = RecursiveCharacter.new(
            chunk_size: @chunk_size,
            chunk_overlap: @chunk_overlap
          )
          sub_chunks = sub_splitter.split(content, metadata: metadata)
          sub_chunks.each do |sc|
            chunks << Chunk.new(
              text: sc.text,
              index: chunks.size,
              offset: section[:offset] + sc.offset,
              metadata: sc.metadata
            )
          end
        end
      end

      chunks
    end

    private

    def split_by_tags(text)
      sections = []
      tag_pattern = /<\/?(?:#{BLOCK_TAGS.join("|")})\b[^>]*>/i

      parts = text.split(/(#{tag_pattern})/i)
      current_text = +""
      current_offset = 0
      pos = 0

      parts.each do |part|
        if part.match?(tag_pattern) && !current_text.strip.empty?
          sections << { text: current_text, offset: current_offset }
          current_text = part
          current_offset = pos
        else
          current_text << part
        end
        pos += part.length
      end

      sections << { text: current_text, offset: current_offset } unless current_text.strip.empty?
      sections
    end

    def strip_html_tags(text)
      text.gsub(/<[^>]+>/, "")
    end
  end
end
