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
