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

# ─── Append Remote Rules section to presets page ─────────────────────────────
BASE_URL="https://edwarddev0723.github.io/ds-agent-rules/r"

cat >> docs/presets.md << 'REMOTE_HEADER_EOF'

---

## Remote Rules (Zero-Install)

Paste a URL directly into your AI IDE — no `git clone`, `pip install`, or any setup needed.

Each URL returns **`core.md` + overlay + all snippets** compiled into a single plain-text file,
ready for Cursor, Windsurf, or any IDE that accepts a remote rules URL.

### How to use

=== "Cursor"

    **Settings → Rules for AI → Add Rule → paste URL**

    ```
    https://edwarddev0723.github.io/ds-agent-rules/r/<preset>.txt
    ```

=== "Windsurf"

    **Settings → AI Rules → Remote URL → paste URL**

    ```
    https://edwarddev0723.github.io/ds-agent-rules/r/<preset>.txt
    ```

=== "Any IDE"

    Fetch the raw text and copy into your rules config:

    ```bash
    curl https://edwarddev0723.github.io/ds-agent-rules/r/llm-project.txt
    ```

### Available Remote URLs

| Preset | Remote URL |
|--------|-----------|
REMOTE_HEADER_EOF

for preset_file in presets/*.txt; do
  name=$(basename "$preset_file" .txt)
  echo "| \`$name\` | \`${BASE_URL}/${name}.txt\` |" >> docs/presets.md
done

# ─── Compile presets into remote-ready combined plain-text files ──────────────
mkdir -p docs/r
for preset_file in presets/*.txt; do
  name=$(basename "$preset_file" .txt)
  args=$(grep -v '^#' "$preset_file" | grep -v '^$' | head -1)
  read -ra parts <<< "$args"
  overlay="${parts[0]}"
  snippets=("${parts[@]:1}")
  out="docs/r/${name}.txt"
  {
    cat "base/core.md"
    if [[ -f "base/${overlay}.md" ]]; then
      printf '\n\n---\n\n'
      cat "base/${overlay}.md"
    fi
    for snippet in "${snippets[@]}"; do
      if [[ -f "snippets/${snippet}.md" ]]; then
        printf '\n\n---\n\n'
        cat "snippets/${snippet}.md"
      fi
    done
  } > "$out"
done

echo ""
echo "✅ Docs symlinks + remote rules compiled (docs/r/). Run: mkdocs serve"
