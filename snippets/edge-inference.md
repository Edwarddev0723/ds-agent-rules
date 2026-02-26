# Snippet: Edge / Mobile LLM Inference

## Domain Context
Deploying LLMs on mobile or edge devices with constrained compute, memory, and battery.
Every optimization decision has real-world tradeoffs — document them explicitly.

## Optimization Priority Order
1. Quantization (INT8/INT4) — biggest wins with acceptable quality loss
2. Pruning — effective for attention heads; structured pruning preferred (2:4 sparsity on Ampere+)
3. Knowledge distillation — best quality retention, highest engineering cost
4. Architecture changes (e.g., replace MHA with GQA/MQA) — last resort, requires retraining

## Benchmarking Standards
- Always measure on **target hardware**, not development machine — results are non-transferable
- Report: latency (p50, p95, p99), throughput (tokens/sec), memory footprint (peak RSS), model file size
- Test across battery levels (100%, 50%, 20%) — thermal throttling reduces perf 30–50% on mobile
- Include cold-start latency separately from steady-state latency
- Run ≥100 inference passes for each measurement — first 10 are warm-up, discard them
- Profile power consumption (mW) using platform tools: Xcode Energy Gauge, Android Battery Historian

## Quality vs. Efficiency Tradeoff
- Always report quality degradation from FP32 baseline alongside efficiency gains
- Define acceptable quality loss threshold **before** starting optimization (e.g., "≤2% accuracy drop")
- Run human evaluation for subjective quality checks — perplexity alone is insufficient for user-facing apps
- Measure on ≥3 task-specific benchmarks — a single metric can hide regressions in specific domains

## Mobile-Specific Rules
- Test on both iOS (Apple Silicon) and Android (Qualcomm/MediaTek) if cross-platform
- Memory budget: assume 2GB max for model + runtime on mid-range devices (4GB on flagship)
- Prefer ONNX Runtime Mobile, CoreML, or TFLite for deployment — document which backend and version
- Use platform-specific NPU/GPU delegates when available: CoreML ANE, Qualcomm QNN, MediaTek NeuroPilot
- Bundle model with app or download on first launch — document the tradeoff and model size budget
- Background inference: yield CPU cores to foreground tasks — never pin all cores to model inference
- Handle device rotation and app lifecycle: save/restore KV-cache state across `onPause`/`viewDidDisappear`

## Quantization Guidelines
- Start with post-training quantization (PTQ) INT8 — cheapest and usually sufficient
- If quality drops >2% on key metric, use quantization-aware training (QAT)
- Mixed-precision: keep first/last layers and attention logits in FP16, quantize feed-forward to INT8/INT4
- Always compare: FP32 → FP16 → INT8 → INT4 — report each step's quality/speed tradeoff in a table
- For LLMs: GPTQ or AWQ quantization to 4-bit is the current sweet spot for on-device inference
- Calibration dataset: use ≥500 representative samples from production-like distribution for PTQ
- Validate quantized model on edge cases: long sequences, rare tokens, multilingual input — failures cluster there

## Model Packaging & Updates
- Version every model artifact with a SHA-256 checksum — the app must verify integrity at load time
- OTA model updates: implement automatic rollback if inference error rate > baseline + 5%
- Model size budget: <100MB for bundled models, <500MB for on-demand downloads — enforce in CI
- Split large models into shards (≤50MB each) for incremental download — users on slow networks will abandon large downloads
- Store model metadata alongside binary: input/output shapes, quantization config, min framework version

## CI/CD Integration
- Run inference benchmarks in CI on target device simulators (Xcode Instruments, Android Emulator with HW profile)
- Gate deployments on latency regression: p95 latency must not regress >10% vs. previous release
- Automated model size checks: fail CI if model exceeds size budget
- Include a smoke test that loads the model and runs ≥5 inferences on each target platform
- Track latency trend over releases — alert if 3 consecutive releases show >5% regression trend

## Common Pitfalls
- Benchmarking on desktop GPU instead of target device — numbers are meaningless without target hardware
- Ignoring thermal throttling: sustained inference perf is 30–50% lower than burst perf on mobile
- Assuming ONNX export "just works" — dynamic shapes, custom ops, and control flow frequently break
- Model compiles fine but OOMs at runtime — profile peak RSS + 20% headroom, not just model file size
- Skipping battery impact testing — a model that drains 10% battery/hour will get your app uninstalled
- Quantization without calibration data leads to outlier activations destroying quality — always calibrate
- Testing only on high-end devices (iPhone 16 Pro, Pixel 9 Pro) — mid-range devices are 2–3× slower
- Ignoring tokenizer overhead: on-device tokenizer can add 50–100ms per request — profile it separately
