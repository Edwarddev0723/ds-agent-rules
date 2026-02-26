# Snippet: Computer Vision

## Domain Context
Image/video understanding tasks: classification, detection, segmentation, generation.
Visual data has unique pitfalls around augmentation, resolution, and compute cost.

## Data Pipeline
- Store images in original resolution; resize on-the-fly during data loading
- Validate images on ingest: check for corruption, zero-byte files, unusual aspect ratios
- Maintain a class distribution summary — log before every training run
- For detection/segmentation: validate annotation format (COCO, VOC, YOLO) before training starts
- Dataset versioning is mandatory — hash the image list + annotations together

## Augmentation Strategy
- Start with standard augmentations: random crop, horizontal flip, color jitter, normalize
- Test-time augmentation (TTA): use for final evaluation, not during development iteration
- Domain-specific augmentations: medical (elastic deform), satellite (rotation invariance), etc.
- **Never augment the validation/test set** — only training data
- Document the augmentation pipeline in config — random augmentations must be reproducible via seed

## Model Selection
- Use pretrained backbones by default — training from scratch requires strong justification
- Architecture heuristics:
  - Classification: start with EfficientNet/ConvNeXt; ViT for >10K training images
  - Detection: YOLO family for speed; DETR family for accuracy
  - Segmentation: U-Net for medical; Mask2Former for general purpose
- Always benchmark against the previous SOTA on your specific dataset, not just ImageNet numbers

## Training Practices
- Learning rate: use cosine schedule with warmup; lr finder for initial value
- Freeze backbone initially (2-5 epochs), then unfreeze with lower lr (10x smaller)
- Mixed precision (bf16/fp16) by default — no reason not to on modern hardware
- Monitor both loss and metric curves — divergence between them signals issues
- Save best checkpoint by validation metric, not by lowest loss

## Evaluation
- Report: accuracy, precision, recall, F1 (per-class for imbalanced datasets)
- For detection: mAP@0.5 and mAP@0.5:0.95; report per-class AP for important classes
- Visualize predictions on failure cases — not just aggregate metrics
- Test on different conditions: lighting, occlusion, scale variation if applicable
- Inference benchmarks: FPS and latency on target hardware

## Common Pitfalls
- Data leakage: same object/scene in both train and test splits (especially video frames)
- Resolution mismatch: training on 224px but deploying on 1080p without proper handling
- Augmentation too aggressive → model underfits; too weak → model overfits
- Batch normalization behaves differently at train vs. eval — always call `model.eval()`
- Color space issues: OpenCV loads BGR, PIL loads RGB — inconsistency causes silent bugs
