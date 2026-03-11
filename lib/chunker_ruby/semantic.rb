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
      # Use scan to preserve exact boundaries without losing whitespace info
      parts = text.scan(/[^.!?]*[.!?]+\s*|[^.!?]+/)
      parts.map! { |s| s.rstrip }
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
      boundaries = [-1] + split_points + [sentences.length - 1]

      # Pre-compute sentence positions in original text
      sent_offsets = []
      spos = 0
      sentences.each do |s|
        idx = original_text.index(s, spos)
        sent_offsets << (idx || spos)
        spos = (idx || spos) + s.length
      end

      (0...boundaries.length - 1).each do |i|
        start_idx = boundaries[i] + 1
        end_idx = boundaries[i + 1]
        chunk_sentences = sentences[start_idx..end_idx]

        # Extract chunk from original text to preserve spacing
        chunk_start = sent_offsets[start_idx]
        chunk_end = sent_offsets[end_idx] + sentences[end_idx].length
        chunk_text = original_text[chunk_start...chunk_end].rstrip
        chunk_text = chunk_sentences.join(" ") if chunk_text.strip.empty?

        # Enforce size constraints
        if chunk_text.length > @chunk_size
          sub_splitter = RecursiveCharacter.new(
            chunk_size: @chunk_size,
            chunk_overlap: @chunk_overlap
          )
          sub_chunks = sub_splitter.split(chunk_text, metadata: metadata)
          sub_chunks.each do |sc|
            offset = chunk_start + (sc.offset || 0)
            chunks << Chunk.new(
              text: sc.text,
              index: chunks.size,
              offset: offset,
              metadata: sc.metadata
            )
          end
          current_pos = chunk_end
        elsif chunk_text.length >= @min_chunk_size
          offset = chunk_start
          current_pos = chunk_end
          chunks << Chunk.new(
            text: chunk_text,
            index: chunks.size,
            offset: offset,
            metadata: metadata.dup
          )
        elsif !chunks.empty?
          # Merge small chunk with previous
          prev = chunks.pop
          merged_end = chunk_end
          merged_text = original_text[prev.offset...merged_end].rstrip
          merged_text = prev.text + " " + chunk_text if merged_text.strip.empty?
          chunks << Chunk.new(
            text: merged_text,
            index: prev.index,
            offset: prev.offset,
            metadata: prev.metadata
          )
          current_pos = merged_end
        else
          offset = chunk_start
          current_pos = chunk_end
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
