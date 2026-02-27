# ds-agent-rules

[![npm version](https://img.shields.io/npm/v/ds-agent-rules)](https://www.npmjs.com/package/ds-agent-rules)
[![PyPI version](https://img.shields.io/pypi/v/ds-agent-rules)](https://pypi.org/project/ds-agent-rules/)
[![CI](https://github.com/Edwarddev0723/ds-agent-rules/actions/workflows/ci.yml/badge.svg)](https://github.com/Edwarddev0723/ds-agent-rules/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/Edwarddev0723/ds-agent-rules/blob/main/LICENSE)

A portable, composable rules system for AI coding agents — one source of truth for **Data Science, Machine Learning, and AI Engineering** projects.

Write rules once. Sync to **Claude Code · GitHub Copilot · OpenAI Codex · Gemini Code · Cursor · Windsurf** — all at once.

## Install

=== "npm"

    ```bash
    npx ds-agent-rules init
    ```

=== "pip"

    ```bash
    pip install ds-agent-rules
    ds-agent-rules init
    ```

=== "git clone"

    ```bash
    git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules
    cd ~/.ai-rules && chmod +x sync.sh new-project.sh
    ```

## Why?

Without explicit rules, AI agents silently introduce bad habits:

| What goes wrong | Impact |
|----------------|--------|
| No random seeds | Irreproducible experiments |
| Random train/test splits on time-series | Data leakage |
| Skipped evaluation baselines | Unverifiable model claims |
| Hardcoded hyperparameters | Untrackable experiments |

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

## Quick Links

- [Quickstart](getting-started/quickstart.md) — get up and running in 2 minutes
- [Browse Snippets](snippets/index.md) — 23 domain-specific rule modules
- [Presets](presets.md) — one-command setups for common project types
- [Contributing](contributing.md) — how to add or improve rules

## Supported AI Tools

| AI Tool | Config File |
|---------|-------------|
| Claude Code | `CLAUDE.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| OpenAI Codex / ChatGPT | `AGENTS.md` |
| Google Gemini Code | `.gemini/styleguide.md` |
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |
