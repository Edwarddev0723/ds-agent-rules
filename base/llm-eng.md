# LLM / GenAI Engineering Overlay
> Appended on top of core.md for LLM-centric projects (fine-tuning, serving, agents, RAG).

## Project Mindset
You are building with Large Language Models — outputs are **non-deterministic by design**.
Prioritize: evaluation rigor, prompt versioning, cost awareness, and safety guardrails.
Never assume a model is "working correctly" without systematic evaluation.

---

## Prompt Engineering Standards
- All prompts must be stored in version-controlled files — never inline in application code
- Use a structured prompt template system (Jinja2, YAML, or dedicated prompt library)
- Every prompt change must be accompanied by an eval run against a held-out test set
- Document the model name, temperature, and system prompt for every deployment config
- Prompt naming convention: `{task}_{version}_{model}.txt`

---

## Model Selection & Management
- Always start with the **smallest feasible model** — upgrade only when eval proves it necessary
- Maintain a model comparison table: model name, param count, latency, cost/1K tokens, eval score
- Pin model versions in config (e.g., `gpt-4o-2024-08-06`, not just `gpt-4o`)
- For self-hosted models, track: quantization method, serving framework, GPU memory usage

---

## Evaluation Framework
- Define eval metrics **before** building the pipeline, not after
- Every task must have: automated metrics + human evaluation criteria
- Minimum eval dimensions: correctness, relevance, safety, latency, cost
- Use an eval dataset of ≥100 samples; track eval results over time in a leaderboard
- Red-team testing is mandatory before any user-facing deployment
- LLM-as-judge requires calibration against human ratings — report agreement rate

---

## Cost & Latency Awareness
- Log token usage (input + output) for every API call
- Set budget alerts and hard limits per environment (dev / staging / prod)
- Estimate cost per query at design time — include in architecture docs
- Prefer caching (semantic or exact) for repeated or similar queries
- Streaming responses: measure Time-to-First-Token (TTFT) separately from total latency

---

## Safety & Guardrails
- All user-facing LLM outputs must pass through content filtering
- Implement input validation: reject prompt injection attempts, PII in prompts
- Define and enforce output schema — use structured output / JSON mode where supported
- Maintain a "known failure" test suite — adversarial inputs that previously caused issues
- Log all model inputs/outputs for audit (with PII redaction)

---

## Fine-Tuning Checklist (remind me if I skip any)
- [ ] Base model selected with justification
- [ ] Training data cleaned and deduplicated
- [ ] Eval dataset created (separate from training data)
- [ ] Baseline established (base model zero-shot / few-shot)
- [ ] Hyperparameters logged to experiment tracker
- [ ] Output quality evaluated (automated + human)
- [ ] Cost analysis: training cost + projected inference cost
