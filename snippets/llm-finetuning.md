# Snippet: LLM Fine-Tuning

## Domain Context
Fine-tuning pre-trained language models for domain-specific tasks.
Balance between training cost, data quality, and model performance.

## Data Preparation
- Deduplicate training data — exact and near-duplicate removal (MinHash or embedding similarity)
- Format: always use the model's expected chat template (ChatML, Llama-style, etc.)
- Minimum dataset size heuristic: 500+ high-quality examples for LoRA, 10K+ for full fine-tune
- Include diverse examples — cover edge cases, not just the happy path
- Quality > quantity: 1K curated examples often beats 100K noisy ones

## Training Configuration
- **Start with LoRA/QLoRA** before attempting full fine-tune — justify if full fine-tune is needed
- LoRA defaults to try first: r=16, alpha=32, dropout=0.05 — tune from there
- Learning rate: 1e-4 to 2e-5 for LoRA; 1e-5 to 5e-6 for full fine-tune
- Always use cosine learning rate scheduler with warmup (5-10% of total steps)
- Gradient checkpointing: enable by default for models >7B parameters
- Mixed precision: bf16 preferred on Ampere+; fp16 as fallback

## Evaluation Protocol
- Eval at every epoch + end of training — not just final checkpoint
- Compare against baselines: base model zero-shot, base model few-shot, previous fine-tune
- Task-specific metrics are primary; perplexity/loss are secondary signals only
- Check for catastrophic forgetting: eval on a held-out general capability set
- Overfitting signals: train loss dropping but eval metrics plateauing or degrading

## Common Pitfalls
- Data contamination: verify eval set has zero overlap with training data
- Chat template mismatch between training and inference causes silent quality degradation
- Tokenizer issues: special tokens must be consistent between base model and fine-tune
- LoRA target modules: include both attention AND MLP layers for best results
- Learning rate too high → forgetting; too low → undertrained. When in doubt, start lower
