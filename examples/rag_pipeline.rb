#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/chunker_ruby"

# Simulated RAG pipeline showing how chunker-ruby fits between
# document ingestion and vector storage.

# 1. Ingest documents
documents = {
  "intro.md" => <<~MD,
    # Introduction to RAG

    Retrieval-Augmented Generation (RAG) combines retrieval and generation
    to produce more accurate and grounded responses.

    ## How It Works

    The process involves three steps: chunking, embedding, and retrieval.
    First, documents are split into manageable chunks. Then each chunk is
    converted to a vector embedding. Finally, relevant chunks are retrieved
    based on query similarity.

    ## Benefits

    RAG reduces hallucination and keeps responses grounded in source material.
  MD
  "guide.md" => <<~MD
    # Implementation Guide

    ## Step 1: Chunking

    Choose a chunking strategy based on your document format. For markdown
    documents, use the Markdown splitter. For plain text, RecursiveCharacter
    works well.

    ## Step 2: Embedding

    Convert each chunk to a vector using an embedding model. Popular choices
    include OpenAI's text-embedding-3-small and Cohere's embed-v3.

    ## Step 3: Storage

    Store embeddings in a vector database like zvec-ruby, pgvector, or Pinecone.
  MD
}

# 2. Chunk all documents
chunker = ChunkerRuby::Markdown.new(chunk_size: 300, chunk_overlap: 50)

all_chunks = documents.flat_map do |filename, content|
  chunker.split(content, metadata: { source: filename })
end

puts "Chunked #{documents.size} documents into #{all_chunks.size} chunks\n\n"

all_chunks.each do |chunk|
  puts "--- #{chunk.metadata[:source]} | Chunk #{chunk.index} | #{chunk.length} chars ---"
  puts "Headers: #{chunk.metadata[:headers]&.join(" > ")}"
  puts chunk.text.strip[0..80] + "..."
  puts
end

# 3. In a real pipeline, you would now:
#    - Embed each chunk: embedding = embed_model.encode(chunk.text)
#    - Store in vector DB: db.insert(embedding, chunk.to_h)
#    - Query: results = db.search(query_embedding, limit: 5)
