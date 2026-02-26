# Snippet: Vision-Language Models (VLM)

## Domain Context
This project involves VLM training, fine-tuning, or dataset construction.
Images and text are jointly processed — treat multimodal alignment as a first-class concern.

## Data Quality Rules
- Caption quality gate: CLIPScore > 0.28 before adding to training set
- Traditional Chinese output only — flag and reject any Simplified Chinese
- Taiwan-specific landmarks and cultural references require human review before adding to ground truth
- Image resolution minimum: 224×224; log and skip corrupted files rather than crashing

## Multi-Stage Pipeline
- Each pipeline stage output must be **checkpointed separately** (never recompute from scratch)
- Stage naming: `00_raw → 01_filtered → 02_captioned → 03_quality_checked → 04_final`
- Log per-stage statistics: count, rejection rate, avg quality score

## Evaluation
- Report both: image→text retrieval and text→image retrieval (R@1, R@5, R@10)
- Evaluate on Taiwan-specific subset separately from general benchmark
- Human evaluation required for cultural accuracy — CLIPScore alone is insufficient

## Common Pitfalls (learned from experience)
- Watch for caption hallucinations on low-resolution inputs
- CLIP embeddings can be poor for Traditional Chinese text — verify with dedicated TC-CLIP
- Batch size affects contrastive loss significantly — note batch size in every experiment log
