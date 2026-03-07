# frozen_string_literal: true

module ChunkerRuby
  class Separator < BaseSplitter
    def initialize(separator: "\n\n", keep_separator: true, **kwargs)
      super(**kwargs)
      @separator = separator
      @keep_separator = keep_separator
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      pieces = split_by_separator(text, @separator)
      build_chunks(pieces, text, metadata: metadata)
    end

    private

    def split_by_separator(text, separator)
      if separator.is_a?(Regexp)
        split_with_regex(text, separator)
      elsif separator.empty?
        text.chars
      else
        split_with_string(text, separator)
      end
    end

    def split_with_string(text, separator)
      parts = text.split(separator, -1)
      return parts unless @keep_separator && parts.length > 1

      result = []
      parts.each_with_index do |part, i|
        if i == 0
          result << part + separator unless part.empty?
        elsif i == parts.length - 1
          result << part unless part.empty?
        else
          result << part + separator unless part.empty?
        end
      end
      result.empty? ? [text] : result
    end

    def split_with_regex(text, separator)
      splits = text.split(separator, -1)
      separators = text.scan(separator)
      return splits unless @keep_separator

      result = []
      splits.each_with_index do |part, i|
        combined = i < separators.length ? part + separators[i] : part
        result << combined unless combined.empty?
      end
      result.empty? ? [text] : result
    end
  end
end
