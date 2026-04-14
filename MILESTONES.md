# chunker-ruby — Milestones

> **Source of truth:** https://github.com/johannesdwicahyo/chunker-ruby/milestones
> **Last synced:** 2026-04-14

This file mirrors the GitHub milestones for this repo. Edit the milestone or issues on GitHub and re-sync, do not hand-edit.

## v1.0.0 — Stable Release (**open**)

_Production-ready: verified offsets, 100% API coverage, documentation site, semver commitment_

- [ ] #41 Verify all offset calculations are correct
- [ ] #42 100% test coverage on public API
- [ ] #43 Battle-test Rails integration
- [ ] #44 Published documentation site
- [ ] #45 Add CHANGELOG.md
- [ ] #46 Semantic versioning commitment
- [ ] #47 Document performance baselines

## v0.8.0 — zvec-ruby Integration (**open**)

_Built-in RAG pipeline combining chunker-ruby with zvec-ruby for chunk + embed + store_

- [ ] #36 Built-in Pipeline class for chunk + embed + store
- [ ] #37 Pipeline#index(document) — chunk + embed + store in one call
- [ ] #38 Pipeline#query(text, top_k:) — embed + search
- [ ] #39 Integration tests with zvec-ruby
- [ ] #40 Example: full RAG pipeline with chunker-ruby + zvec-ruby

## v0.7.0 — Performance & Observability (**open**)

_Benchmarks, lazy splitting, streaming for large files, debug logging_

- [ ] #31 Benchmark suite with 1MB, 10MB, 100MB documents
- [ ] #32 Lazy splitting with #split_lazy returning an Enumerator
- [ ] #33 Streaming support for very large files
- [ ] #34 Add ChunkerRuby.logger for debug logging
- [ ] #35 Add Chunk#overlap? to check overlapping chunks

## v0.6.0 — Token Splitter & Tokenizer Integration (**open**)

_First-class tokenizer-ruby integration, tiktoken support, max_tokens option_

- [ ] #26 First-class tokenizer-ruby integration with tested path
- [ ] #27 Support tiktoken models (cl100k_base, o200k_base)
- [ ] #28 Accurate chunk.token_count when tokenizer is available
- [ ] #29 Add max_tokens option to all splitters
- [ ] #30 Benchmark character estimation vs real tokenizer accuracy

## v0.5.0 — More Languages & Formats (**open**)

_Expand Code splitter languages, improve Markdown/HTML handling, add YAML and CSV splitters_

- [ ] #19 Code splitter: Add Go, Rust, Java, C/C++, PHP, Swift, Kotlin
- [ ] #20 Code splitter: Detect language from file extension
- [ ] #21 Markdown: Handle YAML frontmatter
- [ ] #22 Markdown: Table-aware splitting
- [ ] #23 HTML: Improve nested structure handling and strip script/style
- [ ] #24 Add YAML splitter
- [ ] #25 Add CSV/TSV splitter

## v0.4.0 — Rails Integration Complete (**open**)

_Complete Rails integration with generators, migration, tests, and full strategy support_

- [ ] #13 Add missing strategies to Rails resolver
- [ ] #14 Add Rails generator for migration
- [ ] #15 Create DocumentChunk model template
- [ ] #16 Add Rails integration tests
- [ ] #17 Document required table schema in README
- [ ] #18 Add rechunk_all! class method for bulk re-chunking

## v0.3.0 — Sentence Splitter Improvements (**open**)

_Better sentence boundary detection: URLs, ellipsis, decimals, configurable abbreviations_

- [ ] #8 Handle URLs in sentence splitting
- [ ] #9 Handle ellipsis edge cases more robustly
- [ ] #10 Handle decimal numbers in more contexts
- [ ] #11 Handle multi-line sentence boundaries
- [ ] #12 Add configurable abbreviation list

## v0.2.0 — Critical Fixes & Reliability (**closed**)

_Fix offset calculation bugs, harden Token and Semantic splitters, add correctness tests_

- [x] #1 Fix offset calculation in BaseSplitter#build_chunks
- [x] #2 Fix Token splitter offset with .strip() on decoded text
- [x] #3 Fix Semantic splitter sentence joining not matching original spacing
- [x] #4 Add offset correctness tests for all strategies
- [x] #5 Add tests for duplicate text offset accuracy
- [x] #6 Add unicode offset validation tests
- [x] #7 Add large document (>1MB) performance benchmarks
