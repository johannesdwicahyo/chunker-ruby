# frozen_string_literal: true

module ChunkerRuby
  module Rails
    module Chunkable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def chunkable(attribute, strategy: :recursive_character, chunk_size: 1000, chunk_overlap: 200, **options)
          @chunkable_config = {
            attribute: attribute,
            strategy: strategy,
            chunk_size: chunk_size,
            chunk_overlap: chunk_overlap,
            options: options
          }

          after_save :rechunk!, if: -> { saved_change_to_attribute?(attribute) }

          has_many :chunks,
            class_name: "#{name}Chunk",
            dependent: :destroy

          define_method(:chunker) do
            config = self.class.instance_variable_get(:@chunkable_config)
            splitter_class = ChunkerRuby::Rails::Chunkable.resolve_strategy(config[:strategy])
            splitter_class.new(
              chunk_size: config[:chunk_size],
              chunk_overlap: config[:chunk_overlap],
              **config[:options]
            )
          end

          define_method(:rechunk!) do
            config = self.class.instance_variable_get(:@chunkable_config)
            content = send(config[:attribute])
            return if content.nil? || content.empty?

            chunks.destroy_all
            result = chunker.split(content, metadata: { source_id: id, source_type: self.class.name })
            result.each do |chunk|
              chunks.create!(
                text: chunk.text,
                chunk_index: chunk.index,
                offset: chunk.offset,
                metadata: chunk.metadata
              )
            end
          end
        end
      end

      def self.resolve_strategy(strategy)
        case strategy.to_sym
        when :character then ChunkerRuby::Character
        when :recursive_character then ChunkerRuby::RecursiveCharacter
        when :sentence then ChunkerRuby::Sentence
        when :separator then ChunkerRuby::Separator
        when :markdown then ChunkerRuby::Markdown
        when :html then ChunkerRuby::HTML
        when :code then ChunkerRuby::Code
        when :token then ChunkerRuby::Token
        else raise ArgumentError, "Unknown chunking strategy: #{strategy}"
        end
      end
    end
  end
end
