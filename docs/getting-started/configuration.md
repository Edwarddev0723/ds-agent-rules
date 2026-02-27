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

## External Rule Dependencies

You can pull snippets from any public GitHub repository or HTTPS URL, enabling a decentralized ecosystem of community-maintained rules:

```yaml
profile: ds-ml
snippets:
  - rag
  - mlops
  # Pull from any public GitHub repo (resolves to the main branch)
  - github:someone/awesome-ai-rules/snippets/langchain.md
  # Or a direct HTTPS URL
  - https://example.com/team-security-rules.md
```

**`github:` shorthand** — format: `github:owner/repo/path/to/file.md`
Resolves to `https://raw.githubusercontent.com/{owner}/{repo}/main/{path}`.

**Requirements**: `curl` must be installed (pre-installed on macOS and most Linux distributions).

**Caching**: External snippets are fetched once per `sync.sh` invocation into an ephemeral temp directory. They are not cached between runs.

**Error handling**: If a fetch fails (network error, HTTP 4xx/5xx), `sync.sh` exits immediately with a clear error message.

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
