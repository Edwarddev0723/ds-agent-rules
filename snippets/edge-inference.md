# Snippet: Edge / Mobile LLM Inference

## Domain Context
Deploying LLMs on mobile or edge devices with constrained compute, memory, and battery.
Every optimization decision has real-world tradeoffs — document them explicitly.

## Optimization Priority Order
1. Quantization (INT8/INT4) — biggest wins with acceptable quality loss
2. Pruning — effective for attention heads
3. Knowledge distillation — best quality retention, highest engineering cost
4. Architecture changes — last resort, requires retraining

## Benchmarking Standards
- Always measure on **target hardware**, not development machine
- Report: latency (p50, p95, p99), throughput (tokens/sec), memory footprint (peak RSS)
- Test across battery levels — thermal throttling affects real-world performance significantly
- Include cold-start latency separately from steady-state latency

## Quality vs. Efficiency Tradeoff
- Always report quality degradation from baseline alongside efficiency gains
- Acceptable quality loss threshold must be defined before starting optimization
- Run human evaluation for subjective quality checks — perplexity alone is insufficient for user-facing apps

## Mobile-Specific Rules
- Test on both iOS (Apple Silicon) and Android (Qualcomm/MediaTek) if cross-platform
- Memory budget: assume 2GB max for model + runtime on mid-range devices
- Prefer ONNX Runtime or CoreML for deployment — document which backend is used
