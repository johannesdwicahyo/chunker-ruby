# frozen_string_literal: true

module ChunkerRuby
  class Semantic < BaseSplitter
    def initialize(embed:, threshold: 0.5, min_chunk_size: 100, max_chunk_size: 2000, **kwargs)
      super(chunk_size: max_chunk_size, chunk_overlap: 0, **kwargs)
      @embed = embed
      @threshold = threshold
      @min_chunk_size = min_chunk_size
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      sentences = split_into_sentences(text)
      return [Chunk.new(text: text, index: 0, offset: 0, metadata: metadata)] if sentences.length <= 1

      embeddings = sentences.map { |s| @embed.call(s) }
      split_points = find_split_points(embeddings)

      build_semantic_chunks(sentences, split_points, text, metadata)
    end

    private

    def split_into_sentences(text)
      parts = text.split(/(?<=[.!?])\s+/)
      parts.reject(&:empty?)
    end

    def find_split_points(embeddings)
      points = []
      (0...embeddings.length - 1).each do |i|
        similarity = cosine_similarity(embeddings[i], embeddings[i + 1])
        points << i if similarity < @threshold
      end
      points
    end

    def cosine_similarity(a, b)
      dot = a.zip(b).sum { |x, y| x * y }
      mag_a = Math.sqrt(a.sum { |x| x * x })
      mag_b = Math.sqrt(b.sum { |x| x * x })
      return 0.0 if mag_a.zero? || mag_b.zero?

      dot / (mag_a * mag_b)
    end

    def build_semantic_chunks(sentences, split_points, original_text, metadata)
      chunks = []
      current_pos = 0
      boundaries = [-1] + split_points + [sentences.length - 1]

      (0...boundaries.length - 1).each do |i|
        start_idx = boundaries[i] + 1
        end_idx = boundaries[i + 1]
        chunk_sentences = sentences[start_idx..end_idx]
        chunk_text = chunk_sentences.join(" ")

        # Enforce size constraints
        if chunk_text.length > @chunk_size
          sub_splitter = RecursiveCharacter.new(
            chunk_size: @chunk_size,
            chunk_overlap: @chunk_overlap
          )
          sub_chunks = sub_splitter.split(chunk_text, metadata: metadata)
          sub_chunks.each do |sc|
            offset = original_text.index(sc.text, current_pos) || current_pos
            current_pos = offset + sc.text.length
            chunks << Chunk.new(
              text: sc.text,
              index: chunks.size,
              offset: offset,
              metadata: sc.metadata
            )
          end
        elsif chunk_text.length >= @min_chunk_size
          offset = original_text.index(chunk_text, current_pos) || current_pos
          current_pos = offset + chunk_text.length
          chunks << Chunk.new(
            text: chunk_text,
            index: chunks.size,
            offset: offset,
            metadata: metadata.dup
          )
        elsif !chunks.empty?
          # Merge small chunk with previous
          prev = chunks.pop
          merged = prev.text + " " + chunk_text
          chunks << Chunk.new(
            text: merged,
            index: prev.index,
            offset: prev.offset,
            metadata: prev.metadata
          )
          current_pos = prev.offset + merged.length
        else
          offset = original_text.index(chunk_text, current_pos) || current_pos
          current_pos = offset + chunk_text.length
          chunks << Chunk.new(
            text: chunk_text,
            index: chunks.size,
            offset: offset,
            metadata: metadata.dup
          )
        end
      end

      chunks
    end
  end
end
