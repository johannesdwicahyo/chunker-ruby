# frozen_string_literal: true

module ChunkerRuby
  class Markdown < BaseSplitter
    HEADER_PATTERN = /^(\#{1,6})\s+(.+)$/

    def initialize(keep_headers: true, **kwargs)
      super(**kwargs)
      @keep_headers = keep_headers
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      sections = split_by_headers(text)
      chunks = []

      sections.each do |section|
        section_meta = metadata.merge(section[:metadata])

        if section[:text].length <= @chunk_size
          chunks << Chunk.new(
            text: section[:text],
            index: chunks.size,
            offset: section[:offset],
            metadata: section_meta
          )
        else
          # Fall back to recursive splitting for large sections
          sub_splitter = RecursiveCharacter.new(
            chunk_size: @chunk_size,
            chunk_overlap: @chunk_overlap,
            separators: ["\n\n", "\n", ". ", " ", ""]
          )
          sub_chunks = sub_splitter.split(section[:text], metadata: section_meta)
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

    def split_by_headers(text)
      sections = []
      current_headers = []
      current_text = +""
      current_offset = 0
      in_code_block = false

      lines = text.lines
      pos = 0

      lines.each do |line|
        if line.match?(/\A```/)
          in_code_block = !in_code_block
          current_text << line
          pos += line.length
          next
        end

        if !in_code_block && (match = line.match(HEADER_PATTERN))
          # Save previous section
          unless current_text.empty?
            sections << {
              text: current_text.rstrip,
              offset: current_offset,
              metadata: { headers: current_headers.dup }
            }
          end

          level = match[1].length
          # Remove headers at same or deeper level
          current_headers = current_headers.select { |h| header_level(h) < level }
          current_headers << line.rstrip

          if @keep_headers
            current_text = line.dup
          else
            current_text = +""
          end
          current_offset = pos
        else
          current_text << line
        end

        pos += line.length
      end

      unless current_text.empty?
        sections << {
          text: current_text.rstrip,
          offset: current_offset,
          metadata: { headers: current_headers.dup }
        }
      end

      sections
    end

    def header_level(header_line)
      match = header_line.match(/^(\#{1,6})/)
      match ? match[1].length : 7
    end
  end
end
