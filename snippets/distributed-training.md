# Snippet: Distributed Training

## Domain Context
Training models across multiple GPUs, nodes, or clusters.
Configuration errors here are expensive — a wasted 8-GPU run costs 8x a single-GPU mistake.

## Strategy Selection
- **Single GPU**: no parallelism needed — keep it simple
- **Data Parallel (DDP)**: default for multi-GPU single-node — use this first
- **FSDP / DeepSpeed ZeRO**: when model doesn't fit in single GPU memory
- **Tensor Parallel**: for very large models (>70B) across fast interconnects (NVLink)
- **Pipeline Parallel**: when tensor parallel alone is insufficient — adds complexity
- Always justify the parallelism strategy in experiment config — never use distributed by default

## DeepSpeed Configuration
- Start with ZeRO Stage 2 — covers most use cases with good efficiency
- ZeRO Stage 3: only when Stage 2 OOMs — adds communication overhead
- Offloading (CPU/NVMe): last resort — significant slowdown, use only if no other option
- Pin DeepSpeed version in requirements — config behavior changes between versions
- Save the DeepSpeed config JSON alongside every checkpoint

## FSDP Configuration
- Wrapping policy: wrap at transformer layer level, not individual modules
- Sharding strategy: `FULL_SHARD` for memory savings, `SHARD_GRAD_OP` for speed
- Mixed precision: use `bf16` policy on Ampere+; `fp16` with loss scaling on older GPUs
- Activation checkpointing: enable for models >7B to reduce memory at ~30% speed cost
- State dict type: use `FULL_STATE_DICT` for checkpointing compatibility

## Communication & Performance
- Profile before optimizing: use `torch.profiler` or NVIDIA Nsight to find bottlenecks
- Communication backend: NCCL for GPU, Gloo for CPU — never mix them accidentally
- Gradient accumulation: use to simulate larger batch sizes without more GPUs
- Effective batch size = per_gpu_batch × num_gpus × gradient_accumulation_steps — log this always
- Overlap communication with computation when possible (enabled by default in DDP)

## Checkpointing
- Save distributed checkpoints that can be loaded on different GPU counts
- Checkpoint frequency: balance between safety (frequent) and I/O overhead (infrequent)
- Always test checkpoint loading before starting a long training run
- Save optimizer state alongside model state — resuming without it wastes the warmup
- Use async checkpointing when available to avoid training stalls

## Resource Management
- Estimate GPU memory requirement before launching: model params × bytes_per_param × overhead_factor
- Monitor GPU utilization during training — below 80% usually means a bottleneck elsewhere
- Set `CUDA_VISIBLE_DEVICES` explicitly — never rely on default GPU assignment
- Log per-node throughput (samples/sec) to detect stragglers
- Cost tracking: log GPU-hours per experiment, compare efficiency across configurations

## Common Pitfalls
- Batch size scaling: learning rate should scale with effective batch size (linear or sqrt)
- Random seed: each rank must produce different data batches but same model initialization
- Deadlocks: all ranks must execute the same collective operations in the same order
- OOM on one rank: usually means uneven data distribution or model shard imbalance
- Silent data corruption: gradient sync errors don't always crash — validate loss curves across ranks
