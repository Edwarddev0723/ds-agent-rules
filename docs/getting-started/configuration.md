# Configuration

## `.ai-rules.yaml` (per-project)

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

## Team Rules

Append company/team-specific `.md` rules after all snippets:

```bash
mkdir team-rules && vim team-rules/our-standards.md

# Via CLI
./sync.sh --team ./team-rules ds-ml rag

# Or in .ai-rules.yaml
# team_dir: ./team-rules
```

## Extending

| Action | Command |
|--------|---------|
| **New overlay** | `cp base/ds-ml.md base/my-type.md` → edit → `./sync.sh my-type` |
| **New snippet** | Create `snippets/my-domain.md` → `./sync.sh ds-ml my-domain` |
| **New preset** | `echo "ds-ml my-domain mlops" > presets/my-preset.txt` |
| **Update a rule** | Edit snippet → `./sync.sh` → `git commit` |

## Installation Strategies

```bash
# Option 1: Standalone
git clone https://github.com/Edwarddev0723/ds-agent-rules ~/.ai-rules

# Option 2: Git submodule in dotfiles
cd ~/.dotfiles && git submodule add https://github.com/Edwarddev0723/ds-agent-rules
```

### Committing generated files?

| Scenario | Recommendation |
|----------|---------------|
| Solo / personal | `.gitignore` them, regenerate with `sync.sh` |
| Team project | Commit — consistent agent behavior across the team |
| Open source | Commit — doubles as contributor onboarding context |
