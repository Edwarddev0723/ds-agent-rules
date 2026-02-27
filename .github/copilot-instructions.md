# AI Agent Ground Rules (Core)
> Loaded in every project regardless of type.

## Identity & Context
You are assisting a practitioner working in Data Science, Machine Learning, and/or AI Engineering.
Assume intermediate-to-expert level — skip basic explanations unless explicitly asked.
Prefer showing working code over describing what could be done.
Adapt your depth to the project type: research rigor for experiments, production readiness for deployments.

---

## Before Writing Any Code
1. State your assumptions explicitly before proceeding
2. If requirements are ambiguous, ask ONE clarifying question — not multiple at once
3. Check if similar code already exists in the project before creating new files
4. Identify potential side effects on existing functionality

---

## Code Standards
- **Language**: Python 3.10+ preferred; TypeScript for frontend
- **Type hints**: always required in Python function signatures
- **Formatting**: assume black + isort + pre-commit hooks are present
- **Paths**: use `pathlib.Path`, never `os.path`
- **Logging**: use `logging` module, never `print()` for debug output
- **Error handling**: never use bare `except:`; always catch specific exceptions
- **Config**: never hardcode values that could change — use env vars or YAML config files
- **Secrets**: never hardcode API keys, tokens, passwords, or PII anywhere

---

## Communication Protocol
- When modifying existing code, explicitly state **what** changed and **why**
- If uncertain about the correct approach, say so — don't silently pick one
- Proactively flag: security issues, performance bottlenecks, tech debt
- After completing a task, suggest the **next logical step**
- Use inline comments only for non-obvious logic, not line-by-line narration

---

## Prohibited Actions
- Never delete files without explicit user confirmation
- Never commit secrets, credentials, or personal data
- Never assume a task is complete until tests pass
- Do not refactor code outside the scope of the current task unless asked
- Do not introduce new dependencies without mentioning them

---

## Version Control Discipline
- Write clear, semantic commit messages: `type: concise description` (feat, fix, refactor, data, exp)
- Never commit large data files, model weights, or credentials to Git
- Use `.gitignore` properly: data/, models/, outputs/, *.pyc, .env
- One logical change per commit — don't mix feature code with config changes

---

## Project Structure Expectations
```
project/
├── src/            ← all production Python modules
├── tests/          ← mirrors src/ structure
├── configs/        ← YAML config files
├── scripts/        ← one-off utility scripts
├── docs/           ← documentation
└── notebooks/      ← exploration only (DS projects)
```

---

# Data Science / ML Project Overlay
> Appended on top of core.md for DS/ML projects.

## Project Mindset
This is a research-engineering hybrid. **Reproducibility > code elegance.**
Every experiment must be traceable, comparable, and reversible.
Treat each run as a scientific trial — not a software deployment.

---

## Experiment Management
- Set ALL random seeds at the start: `torch`, `numpy`, `random`, `transformers`
- All hyperparameters live in YAML config — never hardcoded in training scripts
- Every training run must log to an experiment tracker (W&B or MLflow)
- Run naming convention: `{model}_{dataset}_{key_param}_{YYYYMMDD_HHMM}`
- Save the config file alongside every checkpoint

---

## Data Pipeline Rules
- `data/raw/` is **read-only** — never overwrite source data
- Always write outputs to `data/processed/` or `data/features/`
- Validate schema at every pipeline boundary: shape, dtype, value ranges, null %
- Log dataset statistics before any training: class distribution, size, sample previews
- Large files (>50MB) managed by DVC, not Git

---

## Code Organization
- Notebooks are for **exploration only** — no production logic inside `.ipynb`
- Refactor notebook code to `src/` modules before marking any task complete
- Model classes must implement: `train()`, `evaluate()`, `save()`, `load()`, `predict()`
- No business logic in `if __name__ == "__main__"` blocks

---

## Evaluation Standards
- Never evaluate on training data — always maintain strict train/val/test split
- For time-series data: **temporal split only**, never random split
- Always include at least one baseline comparison
- Report format: `metric: mean ± std` (run with ≥3 seeds)
- Always report alongside primary metric: inference latency (ms), model size (MB)
- Feature leakage check is **mandatory** before any model evaluation

---

## Training Checklist (remind me if I skip any)
- [ ] Seeds set
- [ ] Config logged to experiment tracker
- [ ] Data validation passed
- [ ] Baseline exists for comparison
- [ ] Early stopping configured
- [ ] Checkpoint saving enabled

---

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

---

# Snippet: RAG (Retrieval-Augmented Generation)

## Domain Context
Building systems that retrieve relevant context to ground LLM generation.
The retrieval quality is the ceiling for generation quality — invest heavily in retrieval.

## Chunking Strategy
- Chunk size matters enormously — experiment with 256, 512, 1024 tokens systematically
- Prefer semantic chunking (by paragraph/section) over fixed-size windowing
- Always include overlap between chunks (10-20% of chunk size)
- Preserve metadata with each chunk: source document, page, section title, timestamp
- Never split code blocks, tables, or lists mid-element

## Embedding & Indexing
- Evaluate multiple embedding models on YOUR data before committing to one
- Benchmark embedding models on domain-specific retrieval tasks, not just MTEB leaderboard
- Normalize embeddings before storing if using cosine similarity
- Index type selection: HNSW for <10M vectors; IVF or ScaNN for larger scale
- Always version your embedding model — re-index when the model changes

## Retrieval Pipeline
- Hybrid search (dense + sparse/BM25) consistently outperforms dense-only — use it by default
- Reranking stage (cross-encoder) after initial retrieval significantly improves precision
- Retrieve more than you need (top-k=20), then rerank and select (top-n=5)
- Implement and log retrieval metrics: Recall@K, MRR, NDCG before optimizing generation
- Handle "no relevant results" explicitly — don't force the model to answer with irrelevant context

## Generation
- Always include retrieved sources in the prompt with clear delimiters
- Instruct the model to cite sources and say "I don't know" when context is insufficient
- System prompt must specify: answer based on provided context only
- Max context window utilization: leave 20% headroom for output tokens
- Test with adversarial queries: irrelevant questions, contradictory context, empty retrieval

## Evaluation
- Evaluate retrieval and generation **separately** — don't conflate pipeline errors
- Retrieval eval: relevance of retrieved chunks (human-labeled ground truth)
- Generation eval: faithfulness (no hallucination), relevance, completeness
- End-to-end eval: answer correctness against gold-standard QA pairs
- Track hallucination rate as a first-class metric — it's the #1 user complaint

## Common Pitfalls
- Chunk size too large → retrieves irrelevant content; too small → loses context
- Embedding model trained on English performs poorly on other languages — verify explicitly
- Stale index: documents updated but embeddings not re-indexed
- Context stuffing: more retrieved chunks ≠ better answers (often worse)

---

# Snippet: MLOps & Model Deployment

## Domain Context
Taking models from experimentation to production with reliability, monitoring, and automation.
The model is only as good as the system around it.

## CI/CD for ML
- Model training pipelines must be reproducible from a single command or config
- Every model artifact must be traceable: commit hash, data version, config, training logs
- Automated tests for data pipelines: schema validation, distribution drift, missing values
- Automated tests for model quality: eval metrics must pass a minimum threshold gate
- Separate pipelines: data prep → training → evaluation → packaging → deployment

## Model Registry
- Every production model must be registered with: version, metrics, training config, data hash
- Promote models through stages: `dev → staging → production` — never skip staging
- Keep at least 2 previous production model versions for instant rollback
- Model metadata must include: input/output schema, expected latency, resource requirements

## Serving & Inference
- Define SLA upfront: latency p99, throughput, availability target
- Health checks must verify model is loaded and producing valid outputs, not just HTTP 200
- Implement graceful degradation: fallback model or cached responses when primary fails
- Batch inference: prefer offline batch processing for non-real-time use cases (cheaper, simpler)
- A/B testing infrastructure: route traffic by percentage, log predictions for both models

## Monitoring in Production
- **Data drift detection** is mandatory — monitor input feature distributions daily
- **Model performance monitoring**: track prediction distribution shift, not just system metrics
- Alert on: prediction latency spike, error rate increase, confidence score distribution shift
- Log all predictions with timestamps — enables retroactive analysis when issues are discovered
- Dashboard must show: request volume, latency percentiles, error rate, model version, drift score

## Infrastructure
- Containerize everything: model serving, data pipelines, evaluation jobs
- GPU resource management: right-size instances, use spot/preemptible for training
- Model artifacts stored in versioned object storage (S3/GCS), not local filesystem
- Secrets and credentials: use vault/secret manager, never env files in containers

## Common Pitfalls
- Training-serving skew: feature engineering differs between training and inference
- Silent model degradation: model still returns predictions but quality drops over weeks
- Missing monitoring: team discovers issues from user complaints, not alerts
- Over-engineering: not every model needs Kubernetes — start simple, scale when needed

---

# Snippet: Responsible AI & Safety

## Domain Context
Ensuring AI systems are fair, safe, transparent, and accountable.
These rules apply to any model that affects people — which is nearly all of them.

## Bias & Fairness
- Define protected attributes upfront (age, gender, ethnicity, etc.) — document which ones are relevant and why
- Measure fairness metrics across protected groups using AIF360 or Fairlearn:
  - Demographic parity difference (< 0.1 for low-risk, < 0.05 for high-risk applications)
  - Equalized odds difference (< 0.1)
  - Calibration: prediction means should be within 5% across groups
- Disparate impact check: any metric gap >20% across groups requires investigation and documentation
- Training data audit: check for representation imbalance and historical bias before training — log group counts
- If debiasing is applied, document the method (resampling, reweighting, adversarial) and its impact on overall performance
- Intersectional analysis: check bias across combinations of protected attributes (e.g., age × gender), not just individual axes
- Run bias evaluation on a held-out slice analysis set — never reuse the general test set for fairness audits

## Safety Guardrails
- All user-facing models must have output filtering: toxicity (Perspective API / Detoxify, threshold > 0.7 = block), PII (Presidio), harmful content
- Input validation: detect and reject adversarial inputs, prompt injections (rebuff / LLM-Guard), out-of-distribution queries
- Define a "refuse to answer" policy — model should abstain rather than produce harmful output; document the refusal categories
- Maintain a safety test suite: ≥100 adversarial prompts covering toxicity, bias, PII leakage, jailbreaks — version-controlled
- Regular red-team testing: quarterly at minimum for production systems, with documented findings and remediation timeline
- Toxicity threshold: block outputs scoring >0.7 on Perspective API; flag for human review at >0.5
- Rate limiting: cap per-user requests to prevent abuse (e.g., 60 req/min for general use, stricter for generation endpoints)
- Content classifiers must be updated quarterly — new attack patterns emerge faster than model update cycles

## Transparency & Explainability
- Document model limitations explicitly — what the model CANNOT do is as important as what it can
- Provide explanations appropriate to the audience: SHAP/LIME for data scientists, plain language for end users
- Model cards: every production model must have one — include intended use, limitations, performance by demographic group, training data summary
- Decision audit trail: for high-stakes decisions (credit, hiring, medical), log inputs, model version, outputs, and explanations — retain for ≥2 years
- Confidence/uncertainty: expose prediction confidence to downstream consumers; define a minimum confidence threshold (e.g., 0.7) below which the model defers to human judgment
- Watermarking: for generative models, consider output watermarking for traceability (e.g., text watermarking via green/red token lists)

## Data Privacy
- PII detection and redaction in training data — automated scan (Presidio or custom regex) before any training run
- Data retention policy: define how long model inputs/outputs are stored; default to 90 days unless compliance requires longer
- Right to deletion: ensure ability to remove individual's data and retrain if requested; document the DSAR process
- Synthetic data: consider for sensitive domains — document the generation method, privacy guarantees, and fidelity metrics
- Federated learning: evaluate when data cannot leave its origin for regulatory reasons
- Differential privacy: for sensitive training data, use DP-SGD with ε ≤ 10 and document the privacy budget

## Governance & Documentation
- Risk assessment for every new model: who is affected, what can go wrong, mitigations, residual risk acceptance
- Incident response plan: what happens when the model produces harmful output in production — define SLA (e.g., <4hr for severity-1)
- Regular model reviews: scheduled re-evaluation of fairness metrics and performance drift — at minimum every 6 months
- Regulatory compliance: identify applicable regulations (GDPR, EU AI Act, CCPA, sector-specific) at project start
- Stakeholder communication: non-technical summary of model behavior, risks, and limitations — update with each release
- AI system inventory: maintain a registry of all deployed models with ownership, risk level, and review schedule

## Testing & Monitoring
- A/B testing: include fairness metrics in experiment dashboards, not just engagement/revenue
- Production monitoring: alert on fairness metric drift — set threshold at 1.5× the training-time gap
- Shadow scoring: run bias assessments on live traffic samples weekly, not just at deploy time
- Regression testing: every model update must re-run the safety test suite — automate in CI; gate deployment on pass
- User feedback loop: provide a mechanism for users to report biased or harmful outputs; track resolution rate (target: 100% triaged within 48hr)
- Hallucination monitoring (generative models): sample ≥100 production outputs/week for factual accuracy audit

## Accessibility
- Model outputs must be compatible with screen readers — avoid emoji-heavy or ASCII art responses
- For multi-language models, test outputs across all supported languages — quality often varies 20–40%
- Color-dependent visualizations (e.g., SHAP plots) must be colorblind-safe — use viridis or cividis palettes
- Provide alternative text for any model-generated images or charts

## Common Pitfalls
- "The model is unbiased because we removed protected attributes" — proxy variables (zip code → race) still exist
- Fairness metrics can conflict with each other (demographic parity vs. equalized odds) — document which ones you prioritize and why
- Safety testing only at launch, never revisited — models face new attack vectors over time; schedule recurring audits
- Explainability as afterthought — design for interpretability from the start; retrofitting is 5× more expensive
- Assuming open-source model = safe model — independent safety evaluation is still required
- Over-reliance on automated toxicity classifiers — they miss context-dependent harm and cultural nuance; human review is mandatory for edge cases
- Treating responsible AI as a one-time checklist instead of a continuous process — embed it in sprint workflows

---

> **Generated by ai-rules/sync.sh**\n> Profile: `ds-ml`\n> Snippets: `llm-finetuning rag mlops responsible-ai`\n> Date: 2026-02-27 23:10
