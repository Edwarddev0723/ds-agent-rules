# Snippets Overview

**ds-agent-rules** includes 23 domain-specific snippet modules. Mix and match them to build the perfect rule set for your project.

## How to use snippets

```bash
# Add individual snippets
./sync.sh ds-ml rag mlops pytorch

# Or list them in .ai-rules.yaml
# snippets:
#   - rag
#   - mlops
#   - pytorch
```

## Available Snippets

| Snippet | Domain | Recommended Preset |
|---------|--------|-------------------|
| [agentic-ai](agentic-ai.md) | AI Agents & Tool Use | `agentic-ai` |
| [audio-speech](audio-speech.md) | ASR / TTS / Audio | — |
| [chinese-nlp](chinese-nlp.md) | Traditional Chinese NLP | — |
| [ctr-prediction](ctr-prediction.md) | CTR / Recommendations | `recsys-project` |
| [cv](cv.md) | Computer Vision | `cv-project` |
| [data-labeling](data-labeling.md) | Annotation & Active Learning | `labeling-project` |
| [distributed-training](distributed-training.md) | Multi-GPU/Node | `distributed-llm` |
| [edge-inference](edge-inference.md) | Mobile / Edge Deployment | `edge-deploy` |
| [evaluation-framework](evaluation-framework.md) | Systematic Evaluation | `nlp-project` |
| [graph-ml](graph-ml.md) | Graph Neural Networks | `graph-ml-project` |
| [jax](jax.md) | JAX / Flax | `jax-research` |
| [llm-finetuning](llm-finetuning.md) | LLM Fine-Tuning (LoRA, RLHF) | `llm-project` |
| [mlops](mlops.md) | MLOps & Deployment | Most presets |
| [nlp-general](nlp-general.md) | General NLP | `nlp-project` |
| [prompt-engineering](prompt-engineering.md) | Prompt Design & Versioning | `agentic-ai` |
| [pytorch](pytorch.md) | PyTorch | `distributed-llm` |
| [rag](rag.md) | RAG Pipeline | `llm-project` |
| [responsible-ai](responsible-ai.md) | Responsible AI & Safety | `llm-project` |
| [streaming-ml](streaming-ml.md) | Online Learning & Streaming | `data-platform` |
| [synthetic-data](synthetic-data.md) | Synthetic Data & Privacy | — |
| [tabular-ml](tabular-ml.md) | Tabular ML | `tabular-project` |
| [time-series](time-series.md) | Time Series Forecasting | `ts-forecast` |
| [vlm](vlm.md) | Vision-Language Models | `vlm-project` |

## Writing Your Own Snippet

See the [Contributing Guide](../contributing.md) for the snippet format specification and quality criteria.
