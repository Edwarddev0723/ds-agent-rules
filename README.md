# ds-agent-rules

[![CI](https://github.com/Edwarddev0723/ds-agent-rules/actions/workflows/ci.yml/badge.svg)](https://github.com/Edwarddev0723/ds-agent-rules/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/ds-agent-rules)](https://www.npmjs.com/package/ds-agent-rules)
[![PyPI version](https://img.shields.io/pypi/v/ds-agent-rules)](https://pypi.org/project/ds-agent-rules/)
[![GitHub release](https://img.shields.io/github/v/release/Edwarddev0723/ds-agent-rules)](https://github.com/Edwarddev0723/ds-agent-rules/releases)
[![GitHub stars](https://img.shields.io/github/stars/Edwarddev0723/ds-agent-rules?style=social)](https://github.com/Edwarddev0723/ds-agent-rules/stargazers)

> **[繁體中文版 README](README_zh-TW.md)**

A portable, composable rules system for AI coding agents — one source of truth for **Data Science, Machine Learning, and AI Engineering** projects.

Write rules once. Sync to **Claude Code · GitHub Copilot · OpenAI Codex · Gemini Code · Cursor · Windsurf** — all at once.

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
 │  .cursorrules                     │
 │  .windsurfrules                   │
 └────────────────────────────────────┘
```

**Layer model:** `core` (always) → `overlay` (project type) → `snippets` (domains) → `team` (overrides)

---

## Remote Rules (Zero-Install)

> No `git clone`, no `pip install` — paste a URL and you're done.

Each URL below returns a fully compiled rule file (`core.md` + overlay + snippets) for use in
**Cursor**, **Windsurf**, or any AI IDE that supports loading rules from a remote URL.

| Preset | Remote URL |
|--------|-----------|
| `llm-project` | `https://edwarddev0723.github.io/ds-agent-rules/r/llm-project.txt` |
| `agentic-ai` | `https://edwarddev0723.github.io/ds-agent-rules/r/agentic-ai.txt` |
| `cv-project` | `https://edwarddev0723.github.io/ds-agent-rules/r/cv-project.txt` |
| `distributed-llm` | `https://edwarddev0723.github.io/ds-agent-rules/r/distributed-llm.txt` |
| `data-platform` | `https://edwarddev0723.github.io/ds-agent-rules/r/data-platform.txt` |
| `tabular-project` | `https://edwarddev0723.github.io/ds-agent-rules/r/tabular-project.txt` |
| `ts-forecast` | `https://edwarddev0723.github.io/ds-agent-rules/r/ts-forecast.txt` |
| `full-stack-ai` | `https://edwarddev0723.github.io/ds-agent-rules/r/full-stack-ai.txt` |

> See [all 16 presets →](https://edwarddev0723.github.io/ds-agent-rules/presets/)

**Cursor:** Settings → Rules for AI → Add Rule → paste URL

**Windsurf / others:** fetch with `curl` and paste, or use your IDE's remote URL field

```bash
# Preview any preset locally
curl https://edwarddev0723.github.io/ds-agent-rules/r/llm-project.txt
```

---

## GitHub Action (Auto-Sync for Teams)

> Forget manual `sync.sh` runs. Every push to `.ai-rules.yaml` triggers an automatic sync and commit.

Add two files to your project and you're done:

**`.ai-rules.yaml`** (your project config):

```yaml
profile: ds-ml
snippets:
  - llm-finetuning
  - rag
  - mlops
```

**`.github/workflows/sync-ai-rules.yml`** ([copy from examples/](examples/sync-ai-rules.yml)):

```yaml
name: Sync AI Agent Rules

on:
  push:
    branches: [main]
    paths:
      - '.ai-rules.yaml'
  workflow_dispatch:

permissions:
  contents: write

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Edwarddev0723/ds-agent-rules@v1
```

When anyone edits `.ai-rules.yaml` and pushes, GitHub Actions automatically re-generates and commits `CLAUDE.md`, `.cursorrules`, `AGENTS.md`, and all other AI tool config files. No one ever needs to remember to run `sync.sh`.

**Optional inputs:**

| Input | Default | Description |
|-------|---------|-------------|
| `preset` | _(reads `.ai-rules.yaml`)_ | Named preset; overrides config file |
| `rules-version` | `main` | Branch, tag, or SHA of ds-agent-rules to use |
| `commit-message` | `chore: sync AI agent rules` | Message on the auto-commit |

```yaml
      - uses: Edwarddev0723/ds-agent-rules@v1
        with:
          preset: llm-project       # override .ai-rules.yaml
          rules-version: v1.3.0     # pin for reproducibility
```

---

## Quickstart

### 1. Install

Choose your preferred method:

```bash
# npm (zero-install via npx)
npx ds-agent-rules init

# pip
pip install ds-agent-rules
ds-agent-rules init

# git clone (full control)
git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules
cd ~/.ai-rules && chmod +x sync.sh new-project.sh
```

### 2. Pick your path

<details>
<summary><b>A) npx / pip</b> — zero-clone workflow</summary>

```bash
cd /path/to/your/project
npx ds-agent-rules preset llm-project    # npm
ds-agent-rules preset llm-project        # pip

# or interactive
npx ds-agent-rules new-project
```
</details>

<details>
<summary><b>B) Interactive setup</b> (git clone) — guided walkthrough</summary>

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
./sync.sh --diff                     # show unified diff before applying changes
./sync.sh --validate                 # check project structure against rules
./sync.sh --output-dir /other/proj   # write to a different project
./sync.sh --team ./team-rules        # include team-specific rules
```

### 4. Make targets

```bash
make help                            # show all available targets
make lint                            # run ShellCheck on all scripts
make test                            # run bats test suite
make validate                        # validate current project
make ci                              # lint + test (same as CI)
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
├── presets/                  # Named combos for one-command setup (15 presets)
├── templates/                # Directory scaffolds per project type (5 templates)
├── tests/                    # bats test suite
│   └── sync.bats
├── .github/
│   ├── workflows/ci.yml      # CI (ShellCheck + bats on ubuntu & macos)
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/       # Issue templates (new snippet, bug report)
├── sync.sh                   # Main sync script
├── new-project.sh            # Interactive project initializer
├── Makefile                  # make lint / test / validate / ci
├── CONTRIBUTING.md           # Contributor guide & snippet format spec
├── CHANGELOG.md              # Release history
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
| `graph-ml-project` | ds-ml | graph-ml, evaluation-framework, mlops |
| `labeling-project` | ds-ml | data-labeling, evaluation-framework, responsible-ai |
| `edge-deploy` | ds-ml | edge-inference, pytorch, mlops |
| `vlm-project` | ds-ml | vlm, cv, llm-finetuning, evaluation-framework |

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
| **External snippet** | Add `github:owner/repo/snippets/foo.md` or `https://...` to `.ai-rules.yaml` snippets list |

---

## Installation & Git Strategy

```bash
# Option 1: npm (recommended for JS/TS developers)
npm install -g ds-agent-rules        # global install
npx ds-agent-rules sync ds-ml rag    # or run directly via npx

# Option 2: pip (recommended for Python developers)
pip install ds-agent-rules
ds-agent-rules sync ds-ml rag

# Option 3: Standalone (git clone)
git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules

# Option 4: Git submodule in dotfiles
cd ~/.dotfiles && git submodule add https://github.com/Edwarddev0723/ds-agent-rules
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
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Snippet format specification & quality criteria
- Preset & overlay format
- Commit conventions
- PR checklist

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## Show Your Support

If you are using **ds-agent-rules** to keep your AI agents in check, proudly display this badge in your project's `README.md`!

[![AI Rules: ds-agent-rules](https://img.shields.io/badge/AI%20Rules-ds--agent--rules-3F51B5?logo=robot&logoColor=white)](https://github.com/Edwarddev0723/ds-agent-rules)

```markdown
[![AI Rules: ds-agent-rules](https://img.shields.io/badge/AI%20Rules-ds--agent--rules-3F51B5?logo=robot&logoColor=white)](https://github.com/Edwarddev0723/ds-agent-rules)
```

---

## Who Uses This

Using **ds-agent-rules** in your project or team? We'd love to hear about it! Open an issue or PR to add your name here.

<!-- Add your project/team below -->
<!-- - [Your Project](https://github.com/...) — short description -->

---

## License

[MIT](LICENSE)
