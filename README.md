# ds-agent-rules

> **[繁體中文版 README](README_zh-TW.md)**

A portable, composable rules system for AI coding agents — one source of truth for **Data Science, Machine Learning, and AI Engineering** projects.

Write rules once. Sync to **Claude Code · GitHub Copilot · OpenAI Codex · Gemini Code** — all at once.

---

## The Problem

Without explicit rules, AI agents silently introduce bad habits:

| What goes wrong | Impact |
|----------------|--------|
| No random seeds | Irreproducible experiments |
| Random train/test splits on time-series | Data leakage |
| Skipped evaluation baselines | Unverifiable model claims |
| Hardcoded hyperparameters | Untrackable experiments |

**ds-agent-rules** solves this with a layered, composable rule system that keeps every AI tool aligned.

---

## How It Works

```
 ┌────────────────────┐
 │   base/core.md     │  ← always loaded
 │   base/ds-ml.md    │  ← project-type overlay
 │   snippets/rag.md  │  ← domain-specific rules
 │   team/*.md        │  ← team overrides (optional)
 └────────┬───────────┘
          │  sync.sh
          ▼
 ┌────────────────────────────────────┐
 │  CLAUDE.md                        │
 │  AGENTS.md                        │
 │  .github/copilot-instructions.md  │
 │  .gemini/styleguide.md            │
 └────────────────────────────────────┘
```

**Layer model:** `core` (always) → `overlay` (project type) → `snippets` (domains) → `team` (overrides)

---

## Quickstart

### 1. Clone

```bash
git clone https://github.com/YOUR_USERNAME/ds-agent-rules ~/.ai-rules
cd ~/.ai-rules && chmod +x sync.sh new-project.sh
```

### 2. Pick your path

<details>
<summary><b>A) Interactive setup</b> — guided walkthrough</summary>

```bash
cd /path/to/your/project
~/.ai-rules/new-project.sh
```

Creates `.ai-rules.yaml`, syncs rules, and scaffolds directories.
</details>

<details>
<summary><b>B) One-liner with preset</b> — fastest for common setups</summary>

```bash
cd /path/to/your/project
~/.ai-rules/sync.sh --preset llm-project
```
</details>

<details>
<summary><b>C) Config file</b> — recommended for ongoing projects</summary>

```bash
cd /path/to/your/project
~/.ai-rules/sync.sh --init          # creates .ai-rules.yaml template
vim .ai-rules.yaml                   # edit to match your project
~/.ai-rules/sync.sh                  # sync (auto-reads config)
```
</details>

### 3. Useful flags

```bash
./sync.sh --list                     # show all overlays, snippets, presets
./sync.sh --dry-run ds-ml rag        # preview without writing files
./sync.sh --validate                 # check project structure against rules
./sync.sh --output-dir /other/proj   # write to a different project
./sync.sh --team ./team-rules        # include team-specific rules
```

---

## Project Structure

```
ds-agent-rules/
├── base/                    # Project-type overlays
│   ├── core.md              # Universal rules (always included)
│   ├── ds-ml.md             # Data Science / ML
│   ├── llm-eng.md           # LLM / GenAI Engineering
│   ├── data-eng.md          # Data Engineering
│   ├── software-eng.md      # Traditional Software Engineering
│   └── research.md          # Research / Academic
│
├── snippets/                # Domain-specific rule modules (mix & match)
│   ├── agentic-ai.md        # AI Agents & tool use
│   ├── audio-speech.md      # ASR / TTS / Audio
│   ├── chinese-nlp.md       # Traditional Chinese NLP
│   ├── ctr-prediction.md    # CTR / Recommendation Systems
│   ├── cv.md                # Computer Vision
│   ├── data-labeling.md     # Annotation & Active Learning
│   ├── distributed-training.md  # Multi-GPU/Node (DeepSpeed, FSDP)
│   ├── edge-inference.md    # Mobile / Edge Deployment
│   ├── evaluation-framework.md  # Systematic Evaluation
│   ├── graph-ml.md          # Graph Neural Networks
│   ├── jax.md               # JAX / Flax
│   ├── llm-finetuning.md    # LLM Fine-Tuning (LoRA, RLHF)
│   ├── mlops.md             # MLOps & Deployment
│   ├── nlp-general.md       # General NLP
│   ├── prompt-engineering.md    # Prompt Design & Versioning
│   ├── pytorch.md           # PyTorch
│   ├── rag.md               # RAG Pipeline
│   ├── responsible-ai.md    # Responsible AI & Safety
│   ├── streaming-ml.md      # Online Learning & Streaming
│   ├── synthetic-data.md    # Synthetic Data & Privacy
│   ├── tabular-ml.md        # Tabular ML
│   ├── time-series.md       # Time Series Forecasting
│   └── vlm.md               # Vision-Language Models
│
├── presets/                  # Named combos for one-command setup
├── templates/                # Directory scaffolds per project type
├── sync.sh                   # Main sync script
├── new-project.sh            # Interactive project initializer
└── README.md
```

---

## Presets

> Run `./sync.sh --list` to see your local presets.

| Preset | Overlay | Included Snippets |
|--------|---------|-------------------|
| `llm-project` | ds-ml | llm-finetuning, rag, mlops, responsible-ai |
| `agentic-ai` | llm-eng | agentic-ai, prompt-engineering, rag, mlops, responsible-ai |
| `distributed-llm` | ds-ml | llm-finetuning, distributed-training, pytorch, mlops |
| `cv-project` | ds-ml | cv, mlops |
| `recsys-project` | ds-ml | ctr-prediction, tabular-ml, mlops |
| `tabular-project` | ds-ml | tabular-ml, mlops |
| `ts-forecast` | ds-ml | time-series, mlops |
| `nlp-project` | ds-ml | nlp-general, evaluation-framework, mlops |
| `research-llm` | research | llm-finetuning, rag, responsible-ai |
| `full-stack-ai` | llm-eng | llm-finetuning, rag, mlops, responsible-ai |
| `data-platform` | data-eng | streaming-ml, mlops |

---

## Configuration

### `.ai-rules.yaml` (per-project)

Drop this in your project root. `sync.sh` auto-detects it.

```yaml
profile: ds-ml
snippets:
  - llm-finetuning
  - rag
  - pytorch
  - mlops

# team_dir: ./team-rules     # optional: team-specific rules
# preset: llm-project        # optional: use a preset instead
```

### Team Rules

Append company/team-specific `.md` rules after all snippets:

```bash
mkdir team-rules && vim team-rules/our-standards.md

# Via CLI
./sync.sh --team ./team-rules ds-ml rag

# Or in .ai-rules.yaml
# team_dir: ./team-rules
```

---

## Extending

| Action | Command |
|--------|---------|
| **New overlay** | `cp base/ds-ml.md base/my-type.md` → edit → `./sync.sh my-type` |
| **New snippet** | Create `snippets/my-domain.md` → `./sync.sh ds-ml my-domain` |
| **New preset** | `echo "ds-ml my-domain mlops" > presets/my-preset.txt` |
| **Update a rule** | Edit snippet → `./sync.sh` → `git commit` |

---

## Installation & Git Strategy

```bash
# Option 1: Standalone
git clone https://github.com/YOUR_USERNAME/ds-agent-rules ~/.ai-rules

# Option 2: Git submodule in dotfiles
cd ~/.dotfiles && git submodule add https://github.com/YOUR_USERNAME/ds-agent-rules
```

### Committing generated files?

| Scenario | Recommendation |
|----------|---------------|
| Solo / personal | `.gitignore` them, regenerate with `sync.sh` |
| Team project | Commit — consistent agent behavior across the team |
| Open source | Commit — doubles as contributor onboarding context |

---

## Recommended Workflow

```bash
# 1. Start a new project
mkdir my-project && cd my-project && git init

# 2. Initialize (pick one)
~/.ai-rules/new-project.sh              # interactive
~/.ai-rules/sync.sh --preset llm-project # one-liner
~/.ai-rules/sync.sh --init              # config file

# 3. Work with your AI tools — they auto-read the generated files

# 4. Validate project structure
~/.ai-rules/sync.sh --validate

# 5. Evolve your rules
vim ~/.ai-rules/snippets/rag.md
~/.ai-rules/sync.sh
cd ~/.ai-rules && git add -A && git commit -m "rule: ..."
```

---

## AI Tool → File Mapping

| AI Tool | Config File |
|---------|-------------|
| Claude Code | `CLAUDE.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| OpenAI Codex / ChatGPT | `AGENTS.md` |
| Google Gemini Code | `.gemini/styleguide.md` |

---

## License

[MIT](LICENSE)
