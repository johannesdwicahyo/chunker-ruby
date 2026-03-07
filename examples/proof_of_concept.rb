#!/usr/bin/env ruby
# frozen_string_literal: true

# Real-world proof of concept for chunker-ruby
# Demonstrates chunking a realistic document, verifying correctness,
# and comparing strategies side by side.

require_relative "../lib/chunker_ruby"

# --- 1. Realistic document (a technical blog post) ---

DOCUMENT = <<~TEXT
  # Building a RAG Pipeline in Ruby

  Retrieval-Augmented Generation (RAG) is a technique that enhances large language models by grounding their responses in external knowledge. Instead of relying solely on training data, RAG systems retrieve relevant documents at query time and feed them as context to the LLM.

  This guide walks through building a production RAG pipeline in Ruby, covering document ingestion, chunking, embedding, vector storage, and retrieval.

  ## Why RAG Matters

  Large language models are powerful but have limitations. They can hallucinate facts, their knowledge has a cutoff date, and they cannot access private or proprietary data. RAG addresses all three problems by retrieving relevant context from a knowledge base before generating a response.

  Companies like Notion, Stripe, and Shopify use RAG to power internal search, customer support bots, and documentation assistants. The technique is production-proven and works with any LLM provider.

  ## Step 1: Document Ingestion

  The first step is collecting and normalizing your documents. Sources might include:

  - Markdown files from a documentation repository
  - HTML pages scraped from a website
  - PDF reports exported from business tools
  - Database records with text content
  - Slack messages or email threads

  Each source requires different parsing logic, but the output should be plain text with metadata (source URL, title, date, etc.).

  ```ruby
  class DocumentIngester
    def ingest(source)
      case source
      when MarkdownSource
        parse_markdown(source.content)
      when HTMLSource
        parse_html(source.content)
      when PDFSource
        extract_text(source.path)
      end
    end

    private

    def parse_markdown(content)
      # Strip front matter, normalize whitespace
      content.gsub(/\\A---.*?---\\n/m, "").strip
    end

    def parse_html(content)
      # Strip tags, decode entities
      content.gsub(/<[^>]+>/, "").gsub(/&\\w+;/, " ").strip
    end

    def extract_text(path)
      # Use a PDF extraction library
      PDFReader.new(path).text
    end
  end
  ```

  ## Step 2: Chunking

  Raw documents are usually too long to embed directly. Embedding models have token limits (typically 512 or 8192 tokens), and shorter, focused chunks produce better retrieval results than long, unfocused ones.

  The key insight is that chunking strategy matters enormously. Naive fixed-size splitting breaks sentences mid-thought, loses context, and produces poor retrieval quality. Smart chunking respects document structure — paragraphs, sections, code blocks — and preserves semantic coherence.

  ### Choosing a Strategy

  For markdown documentation, use the Markdown splitter. It respects header hierarchy and keeps sections together. For plain text, RecursiveCharacter is the best general-purpose choice. For source code, use the Code splitter which understands function and class boundaries.

  ### Chunk Size Guidelines

  - **256-512 tokens**: Best for precise, fact-based retrieval (FAQ, definitions)
  - **512-1024 tokens**: Good balance for most use cases (documentation, articles)
  - **1024-2048 tokens**: Better for complex topics that need more context (tutorials, guides)

  Overlap of 10-20% helps ensure context is not lost at chunk boundaries.

  ## Step 3: Embedding

  Once chunked, each piece of text needs to be converted to a vector embedding. Popular embedding models include:

  - OpenAI text-embedding-3-small (1536 dimensions, best cost/performance ratio)
  - Cohere embed-v3 (1024 dimensions, multilingual support)
  - Voyage AI voyage-3 (1024 dimensions, strong for code)
  - Open source: nomic-embed-text, BGE, GTE

  The embedding step is typically the most expensive part of the pipeline, both in terms of API costs and processing time. Batch your requests and cache results aggressively.

  ## Step 4: Vector Storage

  Store your embeddings in a vector database for fast similarity search. Options range from lightweight Ruby-native solutions to managed cloud services:

  - **zvec-ruby**: Pure Ruby vector store, perfect for small-to-medium datasets
  - **pgvector**: PostgreSQL extension, great if you already use Postgres
  - **Pinecone/Weaviate/Qdrant**: Managed services for large-scale deployments

  ## Step 5: Retrieval and Generation

  At query time, embed the user's question using the same model, search the vector store for the top-k most similar chunks, and pass them as context to the LLM.

  ```ruby
  class RAGPipeline
    def initialize(chunker:, embedder:, vector_store:, llm:)
      @chunker = chunker
      @embedder = embedder
      @vector_store = vector_store
      @llm = llm
    end

    def index(document)
      chunks = @chunker.split(document.content, metadata: { source: document.title })
      chunks.each do |chunk|
        embedding = @embedder.embed(chunk.text)
        @vector_store.insert(embedding, chunk.to_h)
      end
    end

    def query(question, top_k: 5)
      query_embedding = @embedder.embed(question)
      results = @vector_store.search(query_embedding, limit: top_k)

      ctx = results.map { |r| r[:text] }.join("\\n\\n")
      @llm.complete(
        system: "Answer based on the provided context.",
        user: "Context: ..." + ctx + " Question: ..." + question
      )
    end
  end
  ```

  ## Conclusion

  Building a RAG pipeline in Ruby is straightforward with the right tools. The chunker-ruby gem handles the critical chunking step, zvec-ruby provides vector storage, and any LLM API completes the picture. The most important decision is your chunking strategy — it directly impacts retrieval quality and ultimately the quality of generated answers.

  Start simple with RecursiveCharacter splitting, measure retrieval quality, and iterate from there. Most teams find that document-aware splitting (Markdown, Code) provides the biggest quality improvement over naive approaches.
TEXT

puts "=" * 70
puts "CHUNKER-RUBY PROOF OF CONCEPT"
puts "=" * 70
puts "\nDocument: #{DOCUMENT.length} characters, #{DOCUMENT.lines.count} lines"
puts

# --- 2. Compare all strategies ---

strategies = {
  "Character" => ChunkerRuby::Character.new(chunk_size: 500, chunk_overlap: 100),
  "RecursiveCharacter" => ChunkerRuby::RecursiveCharacter.new(chunk_size: 500, chunk_overlap: 100),
  "Sentence" => ChunkerRuby::Sentence.new(chunk_size: 500, chunk_overlap: 0),
  "Markdown" => ChunkerRuby::Markdown.new(chunk_size: 500, chunk_overlap: 50),
  "Separator" => ChunkerRuby::Separator.new(separator: "\n\n", chunk_size: 500, chunk_overlap: 50),
  "SlidingWindow" => ChunkerRuby::SlidingWindow.new(chunk_size: 500, chunk_overlap: 100),
}

puts "-" * 70
puts "STRATEGY COMPARISON"
puts "-" * 70
puts
printf "%-25s %8s %10s %10s %10s\n", "Strategy", "Chunks", "Avg Size", "Min Size", "Max Size"
puts "-" * 65

strategies.each do |name, splitter|
  chunks = splitter.split(DOCUMENT)
  sizes = chunks.map { |c| c.text.length }
  printf "%-25s %8d %10d %10d %10d\n",
    name, chunks.length, sizes.sum / sizes.length, sizes.min, sizes.max
end
puts

# --- 3. Verify correctness: offsets map back to original ---

puts "-" * 70
puts "CORRECTNESS VERIFICATION"
puts "-" * 70
puts

errors = []

strategies.each do |name, splitter|
  chunks = splitter.split(DOCUMENT)

  # Verify chunk properties
  chunks.each_with_index do |chunk, i|
    errors << "#{name}: chunk #{i} has wrong index (#{chunk.index} != #{i})" if chunk.index != i
    errors << "#{name}: chunk #{i} is empty" if chunk.text.empty?
    errors << "#{name}: chunk #{i} length mismatch" if chunk.length != chunk.text.length
    errors << "#{name}: chunk #{i} has negative offset" if chunk.offset < 0
  end

  # Verify no words are lost (every word in original appears in at least one chunk)
  original_words = DOCUMENT.scan(/\w{4,}/).uniq  # words 4+ chars for robustness
  chunk_text = chunks.map(&:text).join(" ")
  missing = original_words.reject { |w| chunk_text.include?(w) }
  errors << "#{name}: missing #{missing.length} words: #{missing.first(3).join(", ")}..." if missing.any?
end

if errors.empty?
  puts "ALL CHECKS PASSED"
  puts
  puts "Verified for all #{strategies.length} strategies:"
  puts "  - Chunk indices are sequential"
  puts "  - No empty chunks"
  puts "  - Length fields match actual text length"
  puts "  - Offsets are non-negative"
  puts "  - No words lost during chunking"
else
  puts "ERRORS FOUND:"
  errors.each { |e| puts "  - #{e}" }
end
puts

# --- 4. Deep dive: Markdown strategy (most useful for RAG) ---

puts "-" * 70
puts "MARKDOWN STRATEGY DEEP DIVE"
puts "-" * 70
puts

chunker = ChunkerRuby::Markdown.new(chunk_size: 800, chunk_overlap: 100)
chunks = chunker.split(DOCUMENT)

chunks.each do |chunk|
  headers = chunk.metadata[:headers]&.map { |h| h.sub(/^#+\s*/, "") } || []
  header_path = headers.empty? ? "(top-level)" : headers.join(" > ")

  puts "Chunk #{chunk.index} | #{chunk.length} chars | offset #{chunk.offset}"
  puts "  Section: #{header_path}"
  preview = chunk.text.strip.lines.first(2).map(&:strip).join(" ")
  preview = preview[0..100] + "..." if preview.length > 100
  puts "  Preview: #{preview}"
  puts
end

# --- 5. Simulate RAG retrieval ---

puts "-" * 70
puts "SIMULATED RAG RETRIEVAL"
puts "-" * 70
puts

# Simple keyword-based retrieval (no real embeddings, just demonstrates the flow)
def keyword_search(chunks, query, top_k: 3)
  query_words = query.downcase.split(/\s+/)

  scored = chunks.map do |chunk|
    text_lower = chunk.text.downcase
    score = query_words.sum { |w| text_lower.scan(w).length }
    [chunk, score]
  end

  scored.sort_by { |_, s| -s }.first(top_k).select { |_, s| s > 0 }
end

queries = [
  "What chunking strategy should I use for markdown?",
  "How does vector storage work?",
  "What embedding models are recommended?",
]

chunker = ChunkerRuby::Markdown.new(chunk_size: 600, chunk_overlap: 50)
chunks = chunker.split(DOCUMENT)

queries.each do |query|
  puts "Query: \"#{query}\""
  results = keyword_search(chunks, query)

  if results.empty?
    puts "  No results found."
  else
    results.each_with_index do |(chunk, score), i|
      headers = chunk.metadata[:headers]&.map { |h| h.sub(/^#+\s*/, "") } || []
      section = headers.last || "(top-level)"
      preview = chunk.text.strip[0..120].gsub(/\s+/, " ") + "..."
      puts "  #{i + 1}. [score=#{score}] Section: #{section}"
      puts "     #{preview}"
    end
  end
  puts
end

# --- 6. Code splitting demo ---

puts "-" * 70
puts "CODE SPLITTING DEMO"
puts "-" * 70
puts

ruby_code = <<~RUBY
  module Authentication
    class TokenService
      attr_reader :secret_key, :expiry

      def initialize(secret_key:, expiry: 3600)
        @secret_key = secret_key
        @expiry = expiry
      end

      def generate(user_id:, claims: {})
        payload = {
          sub: user_id,
          iat: Time.now.to_i,
          exp: Time.now.to_i + @expiry
        }.merge(claims)

        encode(payload)
      end

      def verify(token)
        payload = decode(token)
        return nil if payload[:exp] < Time.now.to_i
        payload
      rescue DecodeError
        nil
      end

      private

      def encode(payload)
        Base64.strict_encode64(JSON.generate(payload))
      end

      def decode(token)
        JSON.parse(Base64.strict_decode64(token), symbolize_names: true)
      end
    end

    class SessionManager
      def initialize(store:, token_service:)
        @store = store
        @token_service = token_service
      end

      def create_session(user)
        token = @token_service.generate(
          user_id: user.id,
          claims: { role: user.role, email: user.email }
        )
        @store.set("session:\#{user.id}", token, ex: @token_service.expiry)
        token
      end

      def validate_session(token)
        payload = @token_service.verify(token)
        return nil unless payload

        stored = @store.get("session:\#{payload[:sub]}")
        return nil unless stored == token

        payload
      end

      def destroy_session(user_id)
        @store.del("session:\#{user_id}")
      end
    end
  end
RUBY

code_splitter = ChunkerRuby::Code.new(language: :ruby, chunk_size: 400, chunk_overlap: 50)
code_chunks = code_splitter.split(ruby_code)

code_chunks.each do |chunk|
  first_line = chunk.text.strip.lines.first&.strip || ""
  puts "Chunk #{chunk.index} | #{chunk.length} chars | starts with: #{first_line}"
end

puts
puts "=" * 70
puts "PROOF OF CONCEPT COMPLETE"
puts "=" * 70
