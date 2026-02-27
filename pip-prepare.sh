#!/usr/bin/env bash
# =============================================================================
# Prepare the Python package data directory for pip distribution.
# Copies shell scripts and rule files into src/ds_agent_rules/data/.
# Run this before: python -m build
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/src/ds_agent_rules/data"

echo "📦 Preparing pip package data..."

# Clean and recreate
rm -rf "$DATA_DIR"
mkdir -p "$DATA_DIR/base" "$DATA_DIR/snippets" "$DATA_DIR/presets" "$DATA_DIR/templates"

# Copy rule files
cp "$SCRIPT_DIR"/base/*.md       "$DATA_DIR/base/"
cp "$SCRIPT_DIR"/snippets/*.md   "$DATA_DIR/snippets/"
cp "$SCRIPT_DIR"/presets/*.txt   "$DATA_DIR/presets/"
cp "$SCRIPT_DIR"/templates/*.txt "$DATA_DIR/templates/"

# Copy shell scripts
cp "$SCRIPT_DIR/sync.sh"         "$DATA_DIR/"
cp "$SCRIPT_DIR/new-project.sh"  "$DATA_DIR/"
chmod +x "$DATA_DIR/sync.sh" "$DATA_DIR/new-project.sh"

echo "✅ Package data ready at $DATA_DIR"
echo "   Run: python -m build"
