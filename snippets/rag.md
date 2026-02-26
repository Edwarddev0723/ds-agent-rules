# Snippet: RAG (Retrieval-Augmented Generation)

## Domain Context
Building systems that retrieve relevant context to ground LLM generation.
The retrieval quality is the ceiling for generation quality — invest heavily in retrieval.

## Chunking Strategy
- Chunk size matters enormously — experiment with 256, 512, 1024 tokens systematically
- Prefer semantic chunking (by paragraph/section) over fixed-size windowing
- Always include overlap between chunks (10-20% of chunk size)
- Preserve metadata with each chunk: source document, page, section title, timestamp
- Never split code blocks, tables, or lists mid-element

## Embedding & Indexing
- Evaluate multiple embedding models on YOUR data before committing to one
- Benchmark embedding models on domain-specific retrieval tasks, not just MTEB leaderboard
- Normalize embeddings before storing if using cosine similarity
- Index type selection: HNSW for <10M vectors; IVF or ScaNN for larger scale
- Always version your embedding model — re-index when the model changes

## Retrieval Pipeline
- Hybrid search (dense + sparse/BM25) consistently outperforms dense-only — use it by default
- Reranking stage (cross-encoder) after initial retrieval significantly improves precision
- Retrieve more than you need (top-k=20), then rerank and select (top-n=5)
- Implement and log retrieval metrics: Recall@K, MRR, NDCG before optimizing generation
- Handle "no relevant results" explicitly — don't force the model to answer with irrelevant context

## Generation
- Always include retrieved sources in the prompt with clear delimiters
- Instruct the model to cite sources and say "I don't know" when context is insufficient
- System prompt must specify: answer based on provided context only
- Max context window utilization: leave 20% headroom for output tokens
- Test with adversarial queries: irrelevant questions, contradictory context, empty retrieval

## Evaluation
- Evaluate retrieval and generation **separately** — don't conflate pipeline errors
- Retrieval eval: relevance of retrieved chunks (human-labeled ground truth)
- Generation eval: faithfulness (no hallucination), relevance, completeness
- End-to-end eval: answer correctness against gold-standard QA pairs
- Track hallucination rate as a first-class metric — it's the #1 user complaint

## Common Pitfalls
- Chunk size too large → retrieves irrelevant content; too small → loses context
- Embedding model trained on English performs poorly on other languages — verify explicitly
- Stale index: documents updated but embeddings not re-indexed
- Context stuffing: more retrieved chunks ≠ better answers (often worse)
