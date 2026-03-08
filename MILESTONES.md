# Milestones

## v0.2.0 — Critical Fixes & Reliability

**Bug Fixes:**
- [ ] Fix offset calculation in `BaseSplitter#build_chunks` — uses `.index()`/`.rindex()` which returns wrong offsets when text has repeated substrings. Should track offsets during splitting instead.
- [ ] Fix `Token` splitter offset using `.strip()` on decoded text — can mismatch original
- [ ] Fix `Semantic` splitter joining sentences with `" "` which won't match original spacing

**Tests to Add:**
- [ ] Offset correctness: verify `original_text[chunk.offset, chunk.length] == chunk.text` for all strategies
- [ ] Duplicate text offset accuracy
- [ ] Unicode offset validation
- [ ] Large document (>1MB) performance benchmarks

## v0.3.0 — Sentence Splitter Improvements

- [ ] Handle URLs (`http://example.com.` should not split on the dot)
- [ ] Handle ellipsis edge cases more robustly
- [ ] Handle decimal numbers in more contexts (e.g., `$3.50`)
- [ ] Handle multi-line sentence boundaries (newlines as sentence breaks)
- [ ] Add configurable abbreviation list

## v0.4.0 — Rails Integration Complete

- [ ] Add missing strategies to Rails resolver: `:semantic`, `:json`, `:sliding_window`
- [ ] Add Rails generator for migration (`rails g chunker_ruby:install`)
- [ ] Create `DocumentChunk` model template with `text`, `chunk_index`, `offset`, `metadata` columns
- [ ] Add integration tests (mocked ActiveRecord)
- [ ] Document required table schema in README
- [ ] Add `rechunk_all!` class method for bulk re-chunking

## v0.5.0 — More Languages & Formats

- [ ] **Code splitter**: Add Go, Rust, Java, C/C++, PHP, Swift, Kotlin
- [ ] **Code splitter**: Detect language automatically from file extension
- [ ] **Markdown**: Handle frontmatter (YAML between `---`)
- [ ] **Markdown**: Table-aware splitting (don't break mid-table)
- [ ] **HTML**: Handle nested structures better, add `<script>`/`<style>` stripping
- [ ] **New: YAML splitter** for config files
- [ ] **New: CSV/TSV splitter** for tabular data

## v0.6.0 — Token Splitter & Tokenizer Integration

- [ ] First-class `tokenizer-ruby` integration with tested path
- [ ] Support `tiktoken` models (cl100k_base for GPT-4, o200k_base for GPT-4o)
- [ ] Add `chunk.token_count` that's accurate when tokenizer is available
- [ ] Add `max_tokens` option to all splitters as an alternative to `chunk_size`
- [ ] Benchmark: character estimation vs real tokenizer accuracy

## v0.7.0 — Performance & Observability

- [ ] Benchmark suite with 1MB, 10MB, 100MB documents
- [ ] Lazy splitting with `#split_lazy(text)` returning an Enumerator
- [ ] Streaming support for very large files (read + chunk without loading all into memory)
- [ ] Add `ChunkerRuby.logger` for debug logging
- [ ] Add `Chunk#overlap?` to check if two chunks have overlapping text

## v0.8.0 — zvec-ruby Integration

- [ ] Built-in pipeline: `ChunkerRuby::Pipeline.new(chunker:, embedder:, store:)`
- [ ] `pipeline.index(document)` — chunk + embed + store in one call
- [ ] `pipeline.query(text, top_k:)` — embed + search
- [ ] Integration tests with zvec-ruby
- [ ] Example: full RAG pipeline with both gems

## v1.0.0 — Stable Release

- [ ] All offset calculations verified correct
- [ ] 100% test coverage on public API
- [ ] Rails integration battle-tested
- [ ] Published documentation site
- [ ] CHANGELOG.md
- [ ] Semantic versioning commitment
- [ ] Performance baselines documented
