# Snippet: PyTorch Best Practices

## Domain Context
Framework-specific rules for PyTorch training, model development, and debugging.

## Model Definition
- Inherit from `nn.Module`; implement `forward()` only — never override `__call__`
- Initialize weights explicitly when not using pretrained — document initialization scheme
- Use `nn.Sequential` or `nn.ModuleList` for dynamic layers — never plain Python lists (breaks `.parameters()`)
- Register buffers with `self.register_buffer()` for non-parameter tensors that need device movement
- Type hints on forward: `def forward(self, x: torch.Tensor) -> torch.Tensor:`

## Training Loop
- Always call: `model.train()` before training, `model.eval()` before validation
- Use `torch.no_grad()` or `torch.inference_mode()` during evaluation — saves memory and speeds up
- Gradient clipping: `torch.nn.utils.clip_grad_norm_()` — set max_norm and log when clipping occurs
- Zero gradients with `optimizer.zero_grad(set_to_none=True)` — more memory efficient
- Mixed precision: use `torch.amp.autocast` + `GradScaler` for fp16; bf16 doesn't need scaling

## Data Loading
- `num_workers`: start with 4 per GPU; tune based on CPU/IO bottleneck profiling
- `pin_memory=True` when using GPU — speeds up host-to-device transfer
- `persistent_workers=True` for PyTorch ≥1.7 to avoid worker restart overhead
- Custom datasets: implement `__len__` and `__getitem__`; use `IterableDataset` for streaming data
- Reproducible data loading: set `worker_init_fn` with seed offset per worker

## Debugging & Profiling
- `torch.autograd.set_detect_anomaly(True)` during debugging — disable in production (slow)
- Use `torch.profiler` with TensorBoard for bottleneck analysis
- Memory profiling: `torch.cuda.memory_summary()` to diagnose OOM issues
- Gradient checking: `torch.autograd.gradcheck()` for custom autograd functions
- NaN detection: check for NaN in loss before backward pass — fail fast with informative error

## Checkpointing
- Save: `{'model': model.state_dict(), 'optimizer': optimizer.state_dict(), 'epoch': epoch, 'config': config}`
- Load with `strict=False` when architecture has changed — log mismatched/missing keys
- For distributed: save only on rank 0; load with `map_location` to handle device mapping
- Use `safetensors` format for security and speed when sharing model weights

## Performance Optimization
- `torch.compile()` (PyTorch 2.0+): use for production models — significant speedup with minimal code change
- Channels-last memory format: `model.to(memory_format=torch.channels_last)` for CNN speedup
- Prefer `torch.einsum` or `torch.matmul` over manual loops
- Avoid Python-level loops over tensor dimensions — use vectorized operations
- Profile before optimizing: the bottleneck is rarely where you think it is

## Common Pitfalls
- Forgetting `model.eval()` → BatchNorm and Dropout behave incorrectly during inference
- `.item()` in training loop → forces GPU sync, kills throughput — only use for logging
- Tensor on wrong device → runtime error; always use `.to(device)` consistently
- In-place operations (e.g., `x += 1`) can break autograd — avoid in differentiable paths
- DataLoader with `shuffle=True` + `DistributedSampler` → double shuffling; let sampler handle it
