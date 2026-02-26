# Snippet: General NLP

## Domain Context
Text classification, named entity recognition, sentiment analysis, text summarization, and other core NLP tasks.
Pre-LLM techniques remain highly relevant for production systems where cost, latency, and interpretability matter.

## Task Selection Guide
- Classification: start with TF-IDF + logistic regression baseline before using transformers
- NER: use token classification with pretrained transformer; SpaCy for quick prototyping
- Summarization: extractive first (cheaper, more faithful), abstractive only when extractive is insufficient
- Sentiment: few-shot LLM for prototyping, fine-tuned classifier for production (cost + latency)
- Document choice depends on: data volume, latency budget, accuracy requirements, and interpretability needs

## Text Preprocessing
- Document the preprocessing pipeline explicitly: lowercase, stopwords, stemming/lemmatization choices
- **Never** silently truncate text — log truncation events and their frequency
- Handle encoding issues upfront: UTF-8 normalize, remove control characters, fix mojibake
- Language detection: run on all inputs; route non-target-language text to appropriate handler
- Tokenization: verify tokenizer handles your domain vocabulary (medical, legal, code, etc.)

## Model Selection
- Baseline progression: rule-based → TF-IDF + classical ML → fine-tuned transformer → LLM
- For labeled data <1K examples: few-shot LLM or SetFit (no full fine-tune)
- For labeled data 1K-50K: fine-tuned BERT-family model (domain-specific if available)
- For labeled data >50K: fine-tuned transformer with hyperparameter optimization
- Always document model size, inference latency, and cost alongside accuracy

## Evaluation
- Classification: precision, recall, F1 per class + macro/weighted average; confusion matrix
- NER: entity-level F1 (not token-level) — partial matches must be handled explicitly
- Summarization: ROUGE-L + human evaluation for faithfulness
- Report metrics on each label/entity type separately — aggregate metrics hide class-level failures
- Error analysis: manually review ≥50 misclassified examples to identify patterns

## Production Considerations
- Input length distribution matters: profile it and set max_length accordingly
- Batch inference: group by similar length to minimize padding waste
- Model distillation: if transformer is accurate but slow, distill to smaller model for serving
- Caching: cache predictions for identical or near-identical inputs
- Graceful degradation: define fallback behavior when model confidence is below threshold

## Common Pitfalls
- Class imbalance: accuracy is misleading — use F1 or AUC, apply sampling strategies
- Label noise: crowdsourced labels often have 5-15% error rate — measure and account for it
- Domain shift: model trained on news text performs poorly on social media — validate on target domain
- Tokenizer mismatch: using a different tokenizer at inference vs. training causes silent degradation
- Evaluation contamination: test set overlapping with training data (especially from web-scraped corpora)
