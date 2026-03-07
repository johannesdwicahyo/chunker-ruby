# Introduction

This is a sample markdown document used for testing the chunker-ruby gem. It contains various markdown elements to ensure proper splitting.

## Background

The field of natural language processing has evolved significantly. Modern approaches use transformer-based architectures that require careful text preprocessing.

### Key Concepts

- **Tokenization**: Breaking text into tokens
- **Embedding**: Converting tokens to vectors
- **Chunking**: Splitting documents into pieces

## Implementation

Here is an example of a basic chunker:

```ruby
class SimpleChunker
  def split(text, size: 1000)
    text.scan(/.{1,#{size}}/m)
  end
end
```

The code above demonstrates a naive approach. In practice, we need smarter splitting.

## Results

Our testing shows that recursive character splitting outperforms naive approaches by 40% in retrieval accuracy.

### Metrics

| Strategy | Precision | Recall |
|----------|-----------|--------|
| Naive    | 0.65      | 0.70   |
| Recursive| 0.85      | 0.88   |
| Semantic | 0.92      | 0.90   |

## Conclusion

Proper text chunking is essential for RAG pipelines. The choice of strategy depends on the document format and use case.
