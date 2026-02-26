# Snippet: Vision-Language Models (VLM)

## Domain Context
This project involves VLM training, fine-tuning, or dataset construction.
Images and text are jointly processed — treat multimodal alignment as a first-class concern.

## Data Quality Rules
- Caption quality gate: CLIPScore > 0.28 before adding to training set; reject below 0.20 outright
- Image resolution minimum: 224×224; log and skip corrupted files rather than crashing
- Aspect ratio: preserve original aspect ratios — pad or resize, never distort
- De-duplicate images by perceptual hash (pHash, hamming distance ≤ 8) — near-duplicates bias contrastive learning
- For multilingual captions, verify alignment per language pair (not just source language quality)
- Validate image-text pairing: run a CLIP retrieval check — if the correct caption is not in top-10 for 20%+ of images, re-clean the dataset
- Log dataset health: images per size bucket, caption length distribution (median, p5, p95), language mix

## Multi-Stage Pipeline
- Each pipeline stage output must be **checkpointed separately** (never recompute from scratch)
- Stage naming: `00_raw → 01_filtered → 02_captioned → 03_quality_checked → 04_final`
- Log per-stage statistics: count, rejection rate, avg quality score
- Set max retry = 3 for captioning API calls; log failures separately — do not silently skip images

## Training & Fine-Tuning
- Contrastive loss is sensitive to batch size — minimum effective batch size is 256 for CLIP-style; document actual batch size in every run
- Use gradient checkpointing for models >1B params — memory savings outweigh speed cost
- Freeze vision encoder first, fine-tune text adapter, then optionally unfreeze with LR = base_lr / 10
- Mixed-precision: BF16 default on Ampere+; use FP32 for loss computation to avoid NaN instability
- Learning rate schedule: warmup 5–10% of steps, cosine decay to 1e-6 — log the schedule
- Image augmentation: use RandomResizedCrop + horizontal flip during training; disable augmentation during eval
- Monitor vision–text loss components separately — an imbalanced loss indicates alignment drift

## Model Selection Heuristics
- Image understanding: start with LLaVA-style architecture for general VLM tasks
- For OCR / document understanding: prefer models with high-res support (>768px) — InternVL, Qwen-VL, GOT-OCR
- For video: decide frame sampling strategy before choosing architecture (uniform vs. keyframe, max 32 frames typical)
- Small models (<3B): MobileVLM, PaliGemma — target edge/mobile deployment
- Region-level tasks (grounding, referring): use models with coordinate output (Kosmos-2, Qwen-VL, Ferret)
- Document the tokenizer's image token budget: e.g., LLaVA uses 576 tokens per image — this affects max context

## Inference & Deployment
- Image preprocessing must match training config exactly — resolution, normalization, padding strategy
- KV-cache management: vision tokens consume significant cache; profile memory before setting batch size
- For multi-image inputs, document the max image count the model supports — silent truncation is common
- Streaming output: verify that partial token generation doesn't produce hallucinated image descriptions
- Latency budget: profile encoder vs. LLM decode time separately — encoder is often 40–60% of total latency
- Quantization: INT8 for vision encoder is usually safe; INT4 for LLM backbone — verify with ≥200 test images

## Evaluation
- Report both: image→text retrieval and text→image retrieval (R@1, R@5, R@10)
- For generative VLMs: use GPT-4o or human evaluation for open-ended quality — BLEU < 0.3 correlation with human judgment on VLM tasks
- Benchmark on ≥2 standard sets: MMMU, MMBench, SEEDBench, RealWorldQA — report version and split
- Hallucination detection: run object presence checks — does the model describe objects not in the image? (use POPE benchmark, target F1 > 0.85)
- Human evaluation required for cultural/locale-specific accuracy — CLIPScore alone is insufficient
- Report inference cost: tokens/image, average latency per image, peak GPU memory

## Common Pitfalls
- Caption hallucinations on low-resolution inputs — the model invents details it cannot see
- CLIP embeddings are poor for non-English text — verify with dedicated multilingual CLIP (e.g., OpenCLIP xlm-roberta)
- Batch size affects contrastive loss significantly — note batch size in every experiment log
- Training on image-text pairs with misaligned captions silently degrades quality — verify alignment before training
- Forgetting to normalize inputs to the model's expected range ([0,1] vs. [-1,1] vs. ImageNet mean/std)
- Resizing images with wrong interpolation (nearest vs. bilinear vs. bicubic) — match the original training config
- Ignoring EXIF orientation: rotated images get fed in wrong orientation — use `ImageOps.exif_transpose()` before processing
