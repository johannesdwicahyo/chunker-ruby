# frozen_string_literal: true

require_relative "lib/chunker_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "chunker-ruby"
  spec.version = ChunkerRuby::VERSION
  spec.authors = ["Johannes Dwi Cahyo"]
  spec.email = []

  spec.summary = "Text chunking/splitting library for Ruby, designed for RAG pipelines"
  spec.description = "Multiple chunking strategies to split documents into optimal pieces for embedding and vector search. Supports character, recursive, sentence, markdown, HTML, code, token, and semantic splitting."
  spec.homepage = "https://github.com/johannesdwicahyo/chunker-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*.rb", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]
end
