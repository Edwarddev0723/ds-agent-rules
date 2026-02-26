# Quickstart

## 1. Clone

```bash
git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules
cd ~/.ai-rules && chmod +x sync.sh new-project.sh
```

## 2. Pick your path

### A) Interactive setup — guided walkthrough

```bash
cd /path/to/your/project
~/.ai-rules/new-project.sh
```

Creates `.ai-rules.yaml`, syncs rules, and scaffolds directories.

### B) One-liner with preset — fastest for common setups

```bash
cd /path/to/your/project
~/.ai-rules/sync.sh --preset llm-project
```

### C) Config file — recommended for ongoing projects

```bash
cd /path/to/your/project
~/.ai-rules/sync.sh --init          # creates .ai-rules.yaml template
vim .ai-rules.yaml                   # edit to match your project
~/.ai-rules/sync.sh                  # sync (auto-reads config)
```

## 3. Useful flags

```bash
./sync.sh --list                     # show all overlays, snippets, presets
./sync.sh --dry-run ds-ml rag        # preview without writing files
./sync.sh --diff                     # show unified diff before applying changes
./sync.sh --validate                 # check project structure against rules
./sync.sh --output-dir /other/proj   # write to a different project
./sync.sh --team ./team-rules        # include team-specific rules
```

## 4. Make targets

```bash
make help                            # show all available targets
make lint                            # run ShellCheck on all scripts
make test                            # run bats test suite
make validate                        # validate current project
make ci                              # lint + test (same as CI)
```

## Non-interactive mode (CI/CD)

```bash
# Use in automation:
~/.ai-rules/new-project.sh --preset llm-project --yes
~/.ai-rules/new-project.sh --type ds-ml --snippets rag,mlops --yes
```
