# chunker-ruby

Text chunking/splitting library for Ruby, designed for RAG (Retrieval-Augmented Generation) pipelines. Split documents into optimal pieces for embedding and vector search.

Bad chunking = bad retrieval = bad RAG. This gem solves that.

## Installation

```ruby
gem install chunker-ruby
```

Or add to your Gemfile:

```ruby
gem "chunker-ruby"
```

## Quick Start

```ruby
require "chunker_ruby"

text = File.read("long_document.md")

# Simple split (uses RecursiveCharacter by default)
chunks = ChunkerRuby.split(text, chunk_size: 1000, chunk_overlap: 200)

chunks.each do |chunk|
  chunk.text       # => "The document begins..."
  chunk.index      # => 0
  chunk.offset     # => 0 (character offset in original)
  chunk.length     # => 342
  chunk.metadata   # => {}
end
```

## Strategies

### Character

Fixed character count with overlap. Simplest strategy.

```ruby
chunker = ChunkerRuby::Character.new(chunk_size: 1000, chunk_overlap: 200)
chunks = chunker.split(text)
```

### RecursiveCharacter

Tries splitting by paragraph, then sentence, then word, then character. The most generally useful strategy.

```ruby
chunker = ChunkerRuby::RecursiveCharacter.new(
  chunk_size: 1000,
  chunk_overlap: 200,
  separators: ["\n\n", "\n", ". ", ", ", " ", ""]  # default
)
chunks = chunker.split(text)
```

### Sentence

Splits on sentence boundaries. Handles abbreviations (Dr., Mr., etc.) and decimal numbers.

```ruby
chunker = ChunkerRuby::Sentence.new(
  min_chunk_size: 500,
  max_chunk_size: 1500
)
chunks = chunker.split(text)
```

### Separator

Split on a specific string or regex.

```ruby
chunker = ChunkerRuby::Separator.new(
  separator: "\n\n",        # or a Regexp
  keep_separator: true,
  chunk_size: 1000
)
chunks = chunker.split(text)
```

### Markdown

Splits on markdown headers (h1-h6). Respects code blocks. Preserves header hierarchy in metadata.

```ruby
chunker = ChunkerRuby::Markdown.new(chunk_size: 1000, chunk_overlap: 100)
chunks = chunker.split(markdown_text)

chunks.first.metadata[:headers]  # => ["# Introduction", "## Background"]
```

### HTML

Splits on HTML block tags. Optionally strips tags.

```ruby
chunker = ChunkerRuby::HTML.new(chunk_size: 1000, strip_tags: true)
chunks = chunker.split(html_text)
```

### Code

Splits on function/class/method boundaries. Supports Ruby, Python, JavaScript, and TypeScript.

```ruby
chunker = ChunkerRuby::Code.new(language: :ruby, chunk_size: 1500)
chunks = chunker.split(source_code)

chunks.first.metadata[:language]  # => :ruby
```

### JSON

Splits JSON arrays/objects into chunks. Each chunk is valid JSON.

```ruby
chunker = ChunkerRuby::JSONSplitter.new(chunk_size: 1000, chunk_overlap: 0)
chunks = chunker.split(json_string)
```

### Token

Splits by token count. Uses `tokenizer-ruby` if available, falls back to character estimation (~4 chars/token).

```ruby
chunker = ChunkerRuby::Token.new(
  chunk_size: 512,        # in tokens
  chunk_overlap: 50,
  tokenizer: "gpt2"
)
chunks = chunker.split(text)
```

### Semantic

Splits where embedding similarity drops (topic boundaries). Requires an embedding function.

```ruby
chunker = ChunkerRuby::Semantic.new(
  embed: ->(text) { my_embedding_function(text) },
  threshold: 0.5,
  min_chunk_size: 100,
  max_chunk_size: 2000
)
chunks = chunker.split(text)
```

### Sliding Window

Fixed-size sliding window with configurable stride.

```ruby
chunker = ChunkerRuby::SlidingWindow.new(
  chunk_size: 500,
  chunk_overlap: 100,
  stride: 200            # optional, defaults to chunk_size - chunk_overlap
)
chunks = chunker.split(text)
```

## Chunk Object

Every strategy returns an array of `ChunkerRuby::Chunk` objects:

```ruby
chunk.text          # chunk content
chunk.index         # position in sequence (0, 1, 2, ...)
chunk.offset        # character offset in original document
chunk.length        # character length
chunk.metadata      # arbitrary metadata hash
chunk.token_count   # estimated token count (or exact with tokenizer)
chunk.to_h          # { text:, index:, offset:, length:, metadata: }
chunk.to_s          # same as chunk.text
```

## Splitting Multiple Documents

```ruby
splitter = ChunkerRuby::RecursiveCharacter.new(chunk_size: 1000)
chunks = splitter.split_many(["First document...", "Second document..."])

chunks.first.metadata[:doc_index]  # => 0
```

## Rails Integration

```ruby
class Document < ApplicationRecord
  include ChunkerRuby::Rails::Chunkable

  chunkable :content,
    strategy: :markdown,
    chunk_size: 1000,
    chunk_overlap: 200
end

document = Document.create!(content: long_text)
document.chunks  # => [#<DocumentChunk text="..." chunk_index=0>, ...]
```

Requires a `DocumentChunk` model with `text`, `chunk_index`, `offset`, and `metadata` columns.

## Choosing a Strategy

| Use Case | Recommended Strategy |
|---|---|
| General text | `RecursiveCharacter` |
| Markdown docs | `Markdown` |
| Source code | `Code` |
| HTML pages | `HTML` |
| LLM context window management | `Token` |
| Topic-based splitting | `Semantic` |
| Simple fixed-size | `Character` or `SlidingWindow` |

## Chunk Size Guidelines

- **256-512 tokens**: Precise, fact-based retrieval (FAQ, definitions)
- **512-1024 tokens**: Good balance for most use cases (docs, articles)
- **1024-2048 tokens**: Complex topics needing more context (tutorials, guides)
- **10-20% overlap**: Prevents context loss at boundaries

## Dependencies

- **Runtime**: None (pure Ruby)
- **Optional**: `tokenizer-ruby` for token-based chunking

## License

MIT
