# Contributing to ds-agent-rules

Thank you for helping make AI agent rules better for the entire DS/ML community!

## Quick Start

```bash
git clone https://github.com/Edwarddev0723/ds-agent-rules
cd ds-agent-rules
make lint    # requires shellcheck
make test    # requires bats-core
```

## How to Contribute

### 1. Improve an existing snippet

Edit a file in `snippets/`, then run:

```bash
make lint && make test
```

### 2. Add a new snippet

Create `snippets/your-domain.md` following the **Snippet Format Spec** below. Then:

1. Add it to at least one preset in `presets/` (or create a new preset)
2. Run `make lint && make test`
3. Open a PR

### 3. Add a new base overlay

Create `base/your-type.md` and a corresponding `templates/your-type.txt` scaffold. Update `new-project.sh` to include it in the selection menu.

### 4. Fix a bug or improve tooling

All changes to `sync.sh` and `new-project.sh` must pass ShellCheck and the bats test suite.

---

## Snippet Format Spec

Every snippet **must** follow this structure:

```markdown
# Snippet: <Display Name>

## Domain Context
<1-3 sentences explaining when this snippet applies>

## <Section 1>
- <Actionable rule>
- <Actionable rule>

## <Section 2>
- ...

## Common Pitfalls
- <Specific, experience-based mistake to avoid>
- <Another pitfall>
```

### Quality Criteria

| Criterion | Required | Example |
|-----------|----------|---------|
| **Actionable** | ✅ | "Use LoRA r=16, alpha=32 as defaults" not "Consider using parameter-efficient methods" |
| **Specific** | ✅ | "Report R@1, R@5, R@10" not "Use appropriate metrics" |
| **Domain Context** | ✅ | First section explains when the snippet applies |
| **Common Pitfalls** | ✅ | Last section with experience-based warnings |
| **Minimum 30 lines** | ✅ | Thin snippets don't provide enough value |
| **Maximum 80 lines** | Recommended | Keep focused; split large topics into multiple snippets |
| **Tool/library names** | Recommended | Mention specific tools: "prefer Optuna over GridSearch" |
| **Numeric thresholds** | Recommended | "Cohen's Kappa ≥ 0.7", "bootstrap with ≥1000 resamples" |

### What Makes a Good Rule

**Good** (specific, actionable, prevents real mistakes):
```
- Temporal split only — never random split for time-series data
- Always report mean ± std across ≥3 seeds
- Use `torch.compile()` for PyTorch ≥2.0 before manual optimization
```

**Bad** (vague, generic, obvious):
```
- Use appropriate evaluation metrics
- Follow best practices for data preprocessing
- Consider model performance carefully
```

---

## Preset Format

Preset files live in `presets/` as `.txt` files:

```
# Description of this preset
overlay snippet1 snippet2 snippet3
```

- First non-comment, non-empty line = arguments passed to `sync.sh`
- First word = base overlay name
- Remaining words = snippet names

---

## Commit Convention

```
<type>: <short description>

Types:
  rule:     New or updated rule content (snippets, overlays)
  feat:     New feature in sync.sh or new-project.sh
  fix:      Bug fix
  docs:     Documentation only
  test:     Adding or updating tests
  chore:    Maintenance (CI, deps, etc.)
```

Examples:
```
rule: add distributed training snippet
feat: add --diff flag to sync.sh
fix: YAML parser handles inline comments
test: add bats tests for --validate flag
docs: update README preset table
```

---

## Pull Request Checklist

- [ ] `make lint` passes (ShellCheck)
- [ ] `make test` passes (bats)
- [ ] New snippets follow the Snippet Format Spec
- [ ] New presets reference only existing overlays and snippets
- [ ] README updated if adding new overlays/snippets/features
- [ ] README_zh-TW.md updated in parallel (or request help in PR)

---

## Code of Conduct

Be kind. Be constructive. We're all here to build better AI agent guardrails.
