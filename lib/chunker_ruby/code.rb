# frozen_string_literal: true

module ChunkerRuby
  class Code < BaseSplitter
    LANGUAGE_SEPARATORS = {
      ruby: [
        "\nclass ", "\nmodule ", "\ndef ", "\n\n", "\n", " ", ""
      ],
      python: [
        "\nclass ", "\ndef ", "\n\n", "\n", " ", ""
      ],
      javascript: [
        "\nfunction ", "\nclass ", "\nconst ", "\nlet ", "\nvar ",
        "\nexport ", "\n\n", "\n", " ", ""
      ],
      typescript: [
        "\ninterface ", "\ntype ", "\nfunction ", "\nclass ",
        "\nconst ", "\nlet ", "\nexport ", "\n\n", "\n", " ", ""
      ]
    }.freeze

    def initialize(language: :ruby, **kwargs)
      super(**kwargs)
      @language = language.to_sym
      @separators = LANGUAGE_SEPARATORS.fetch(@language) do
        raise ArgumentError, "Unsupported language: #{language}. Supported: #{LANGUAGE_SEPARATORS.keys.join(", ")}"
      end
    end

    def split(text, metadata: {})
      return [] if text.nil? || text.empty?

      meta = metadata.merge(language: @language)
      splitter = RecursiveCharacter.new(
        chunk_size: @chunk_size,
        chunk_overlap: @chunk_overlap,
        separators: @separators,
        keep_separator: true
      )
      splitter.split(text, metadata: meta)
    end
  end
end
