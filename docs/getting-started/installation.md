# Installation

ds-agent-rules can be installed via **npm**, **pip**, or **git clone**. All methods give you the same rules and CLI commands.

## npm

Best for JavaScript/TypeScript developers or anyone with Node.js installed.

```bash
# Zero-install (runs directly, nothing persisted globally)
npx ds-agent-rules sync ds-ml rag

# Or install globally
npm install -g ds-agent-rules
ds-agent-rules sync ds-ml rag
```

**Links:** [npmjs.com/package/ds-agent-rules](https://www.npmjs.com/package/ds-agent-rules)

## pip

Best for Python developers.

```bash
pip install ds-agent-rules
ds-agent-rules sync ds-ml rag
```

!!! tip "Use a virtual environment"
    ```bash
    python -m venv .venv && source .venv/bin/activate
    pip install ds-agent-rules
    ```

**Links:** [pypi.org/project/ds-agent-rules](https://pypi.org/project/ds-agent-rules/)

## git clone

Best when you want full control, want to customize rules, or contribute upstream.

```bash
git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules
cd ~/.ai-rules && chmod +x sync.sh new-project.sh
```

## git submodule

Best for embedding rules into your dotfiles repo.

```bash
cd ~/.dotfiles
git submodule add https://github.com/Edwarddev0723/ds-agent-rules
```

## Available commands

All install methods provide the same CLI:

| Command | Description |
|---------|-------------|
| `ds-agent-rules sync <profile> [snippets...]` | Generate rule files |
| `ds-agent-rules preset <name>` | Apply a preset configuration |
| `ds-agent-rules init` | Create `.ai-rules.yaml` in current directory |
| `ds-agent-rules new-project` | Interactive project setup |
| `ds-agent-rules list` | Show all overlays, snippets, and presets |
| `ds-agent-rules validate` | Check project structure against rules |
| `ds-agent-rules diff` | Show unified diff before applying changes |
| `ds-agent-rules --version` | Show version |

## Requirements

- **npm/npx:** Node.js ≥ 16
- **pip:** Python ≥ 3.10
- **Shell:** bash ≥ 3.2 (macOS default) or ≥ 4.0 (Linux)
