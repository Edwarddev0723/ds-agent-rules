# Recipe: Enterprise RAG Chatbot

> **Use Case**: This configuration is ideal for projects building production-grade Retrieval-Augmented Generation (RAG) systems — such as internal knowledge bases, document Q&A, and enterprise chatbots. It directly addresses pain points like hallucination, missing citations, and inconsistent prompt versioning.

## Configuration (`.ai-rules.yaml`)

Copy the following into your project's root `.ai-rules.yaml`:

```yaml
profile: llm-eng
snippets:
  - rag
  - prompt-engineering
  - responsible-ai
```

## Why this stack?

**`llm-eng` (profile)**: LLM Engineering overlay enforces strict standards for non-deterministic LLM output — including prompt versioning, fallback handling, and structured output contracts — which are essential for reliable RAG pipelines.

**`rag`**: Requires the AI agent to implement hybrid search (dense + sparse), preserve document metadata, enforce chunk overlap strategies, and always include source citations in responses.

**`prompt-engineering`**: Mandates version-controlled prompt templates with explicit variable declarations. Prevents prompt drift across development iterations and ensures reproducible retrieval behavior.

**`responsible-ai`**: Adds guardrails for hallucination detection, bias auditing, and PII handling — critical when the RAG system surfaces sensitive enterprise documents to end users.
