# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.0] — 2026-02-26

### Added
- MkDocs Material documentation site with GitHub Pages deployment (`mkdocs.yml`, `docs/`, `docs-build.sh`)
- GitHub Actions workflow for automatic docs deployment (`.github/workflows/docs.yml`)
- `make docs` and `make docs-serve` targets
- README badges: CI status, license, release version, GitHub stars
- "Who Uses This" section in README

### Changed
- **vlm.md** (52→62 lines): added numeric thresholds (CLIPScore, POPE F1 > 0.85), dataset validation rules, quantization guidance, EXIF orientation pitfall
- **edge-inference.md** (57→67 lines): added power profiling, structured pruning detail, calibration & validation rules, tokenizer overhead pitfall, lifecycle handling
- **chinese-nlp.md** (56→65 lines): added numeric benchmarks (DRCD F1, CER < 5%), hybrid search guidance, currency/font rules, zero-width char cleaning
- **responsible-ai.md** (63→74 lines): added intersectional analysis, rate limiting, watermarking, differential privacy (ε ≤ 10), SLA for incidents, hallucination monitoring, accessibility for generated images

## [1.0.0] — 2026-02-26

### Added

#### Core Architecture
- Layered rule composition: `core` → `overlay` → `snippets` → `team`
- `sync.sh` — main sync engine with flags: `--preset`, `--dry-run`, `--output-dir`, `--validate`, `--init`, `--team`, `--list`, `--diff`
- `new-project.sh` — interactive project initializer with scaffold support
- `.ai-rules.yaml` — per-project config with auto-detection
- Multi-tool output: CLAUDE.md, AGENTS.md, .github/copilot-instructions.md, .gemini/styleguide.md, .cursorrules, .windsurfrules

#### Base Overlays (6)
- `core.md` — universal coding standards (always loaded)
- `ds-ml.md` — Data Science / Machine Learning
- `llm-eng.md` — LLM / GenAI Engineering
- `data-eng.md` — Data Engineering
- `software-eng.md` — Software Engineering
- `research.md` — Research / Academic

#### Snippets (23)
- agentic-ai, audio-speech, chinese-nlp, ctr-prediction, cv, data-labeling, distributed-training, edge-inference, evaluation-framework, graph-ml, jax, llm-finetuning, mlops, nlp-general, prompt-engineering, pytorch, rag, responsible-ai, streaming-ml, synthetic-data, tabular-ml, time-series, vlm

#### Presets (11+)
- llm-project, agentic-ai, distributed-llm, cv-project, recsys-project, tabular-project, ts-forecast, nlp-project, research-llm, full-stack-ai, data-platform

#### Project Quality
- CI/CD with GitHub Actions (ShellCheck + bats)
- Bats test suite for sync.sh
- CONTRIBUTING.md with snippet format spec
- PR and Issue templates
- Makefile for common tasks
- .gitignore
