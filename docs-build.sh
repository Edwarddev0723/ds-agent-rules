#!/usr/bin/env bash
# Build docs by symlinking source .md files into docs/ tree.
# Run this before `mkdocs serve` or `mkdocs build`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ─── Symlink base overlays ───────────────────────────────────────────────────
mkdir -p docs/overlays
for f in base/*.md; do
  name=$(basename "$f")
  ln -sf "../../$f" "docs/overlays/$name"
done

# ─── Symlink snippets ────────────────────────────────────────────────────────
mkdir -p docs/snippets
for f in snippets/*.md; do
  name=$(basename "$f")
  ln -sf "../../$f" "docs/snippets/$name"
done

# ─── Symlink top-level docs ──────────────────────────────────────────────────
ln -sf ../CONTRIBUTING.md docs/contributing.md
ln -sf ../CHANGELOG.md docs/changelog.md

# ─── Generate presets page ───────────────────────────────────────────────────
cat > docs/presets.md << 'PRESETS_EOF'
# Presets

Presets are named combinations of an overlay + snippets for one-command setup.

```bash
./sync.sh --preset llm-project
```

## Available Presets

| Preset | Overlay | Snippets |
|--------|---------|----------|
PRESETS_EOF

for preset_file in presets/*.txt; do
  name=$(basename "$preset_file" .txt)
  args=$(grep -v '^#' "$preset_file" | grep -v '^$' | head -1)
  read -ra parts <<< "$args"
  overlay="${parts[0]}"
  snippets="${parts[*]:1}"
  echo "| \`$name\` | $overlay | ${snippets// /, } |" >> docs/presets.md
done

echo ""
echo "✅ Docs symlinks created. Run: mkdocs serve"
