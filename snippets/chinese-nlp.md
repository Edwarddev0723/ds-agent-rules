# Snippet: Traditional Chinese NLP / Taiwan-Specific

## Language Rules
- Output Traditional Chinese (繁體中文) only — Simplified Chinese is always wrong here
- Use Taiwan-standard terminology, not China/Hong Kong variants when they differ
  - e.g., 軟體 not 软件, 資料 not 数据, 網路 not 网络
- For Taiwan-specific cultural content, prefer human review over automated validation

## Tokenization
- Never assume character-level tokenization is sufficient — use proper TC tokenizers
- Recommended: ckip-transformers for segmentation, or use BPE tokenizers trained on TC corpus
- Test tokenizer output on Taiwan-specific named entities before committing

## Model Selection Heuristics
- Prefer models with TC pretraining data: CKIP-BERT, Breeze-7B, Taiwan-LLM
- When using multilingual models (mBERT, mT5), verify TC performance explicitly — it varies widely
- Document language distribution of training data for any fine-tuned model

## Evaluation
- Use TC-specific benchmarks when available (DRCD for QA, etc.)
- Never evaluate TC output using Simplified Chinese metrics or tokenizers
- Manual evaluation by a TC speaker is required for any production-facing output
