#!/bin/bash
set -euo pipefail
# =============================================================================
# ai-rules sync.sh  v1.0.0
# Combines base rules + project overlay + snippets into all AI tool formats
#
# Usage:
#   ./sync.sh                              # auto from .ai-rules.yaml, or core only
#   ./sync.sh ds-ml                        # core + DS/ML overlay
#   ./sync.sh ds-ml vlm chinese-nlp        # core + DS/ML + snippets
#   ./sync.sh --preset llm-project         # use a named preset
#   ./sync.sh --list                       # show available options
#   ./sync.sh --dry-run ds-ml vlm          # preview without writing files
#   ./sync.sh --output-dir /path/to/proj   # write to a specific directory
#   ./sync.sh --validate                   # check project structure against rules
#   ./sync.sh --init                       # create .ai-rules.yaml in current dir
#   ./sync.sh --team ./team-rules          # include team-specific rules
#   ./sync.sh --diff                       # show changes before writing
# =============================================================================

RULES_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
OUTPUT_DIR="."
PRESET=""
VALIDATE=false
INIT_CONFIG=false
TEAM_DIR=""
DIFF_MODE=false
PROJECT_TYPE=""
SNIPPETS=()

# ─── Parse flags ──────────────────────────────────────────────────────────────
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --dry-run)    DRY_RUN=true; shift ;;
    --diff)       DIFF_MODE=true; shift ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --preset)     PRESET="$2"; shift 2 ;;
    --team)       TEAM_DIR="$2"; shift 2 ;;
    --validate)   VALIDATE=true; shift ;;
    --init)       INIT_CONFIG=true; shift ;;
    --list)
      echo "📁 Available base overlays:"
      for f in "$RULES_DIR/base"/*.md; do
        name=$(basename "$f" .md)
        [[ "$name" != "core" ]] && echo "   - $name"
      done
      echo ""
      echo "🧩 Available snippets:"
      for f in "$RULES_DIR/snippets"/*.md; do
        echo "   - $(basename "$f" .md)"
      done
      echo ""
      echo "📦 Available presets:"
      if [[ -d "$RULES_DIR/presets" ]]; then
        for f in "$RULES_DIR/presets"/*.txt; do
          name=$(basename "$f" .txt)
          content=$(grep -v '^#' "$f" | grep -v '^$' | head -1 | xargs)
          echo "   - $name  →  $content"
        done
      else
        echo "   (none)"
      fi
      exit 0
      ;;
    *)
      echo "❌ Unknown flag: $1"
      echo "   Flags: --dry-run, --diff, --preset, --output-dir, --team, --validate, --init, --list"
      exit 1
      ;;
  esac
done

# ─── --init: create .ai-rules.yaml ───────────────────────────────────────────
if [[ "$INIT_CONFIG" == true ]]; then
  TARGET="$OUTPUT_DIR/.ai-rules.yaml"
  if [[ -f "$TARGET" ]]; then
    read -rp "⚠️  .ai-rules.yaml already exists. Overwrite? (y/N): " ow
    [[ ! "$ow" =~ ^[Yy]$ ]] && exit 0
  fi
  cat > "$TARGET" << 'YAMLEOF'
# .ai-rules.yaml — project-level AI rules configuration
# Run `sync.sh` with no args to auto-load this config

# Base overlay (run `sync.sh --list` to see options):
#   ds-ml | llm-eng | software-eng | research | data-eng
profile: ds-ml

# Snippets to include:
snippets:
  - llm-finetuning
  - rag
  - mlops

# Optional: use a preset instead of profile+snippets (overrides both)
# preset: llm-project

# Optional: team rules directory (relative to this file, or absolute)
# team_dir: ./team-rules
YAMLEOF
  echo "✅ Created $TARGET — edit it, then run sync.sh"
  exit 0
fi

# ─── Auto-detect .ai-rules.yaml ──────────────────────────────────────────────
CONFIG_FILE="$OUTPUT_DIR/.ai-rules.yaml"
HAS_POSITIONAL_ARGS=false
[[ -n "${1:-}" ]] && HAS_POSITIONAL_ARGS=true

if [[ -z "$PRESET" && "$HAS_POSITIONAL_ARGS" == false && -f "$CONFIG_FILE" ]]; then
  echo "📄 Auto-detected .ai-rules.yaml"

  # ─── YAML parser: prefer yq if available, fallback to grep+sed ───────────
  if command -v yq &>/dev/null; then
    # Robust parser via yq (supports comments, quotes, anchors)
    _yaml_val() {
      yq -r ".${1} // \"\"" "$CONFIG_FILE" 2>/dev/null || true
    }
    _yaml_list() {
      yq -r ".${1}[]? // empty" "$CONFIG_FILE" 2>/dev/null | xargs || true
    }
  else
    # Lightweight YAML parser (no external dependencies)
    # Handles: inline comments (# ...), single/double quotes, trailing whitespace
    _yaml_val() {
      grep "^${1}:" "$CONFIG_FILE" 2>/dev/null \
        | head -1 \
        | sed "s/^${1}:[[:space:]]*//" \
        | sed 's/[[:space:]]*#.*$//' \
        | sed "s/^['\"]//; s/['\"]$//" \
        | xargs || true
    }
    _yaml_list() {
      awk "
        /^${1}:/ { found=1; next }
        found && /^[a-zA-Z]/ { exit }
        found && /^[[:space:]]*-/ { print }
      " "$CONFIG_FILE" \
        | sed 's/^[[:space:]]*-[[:space:]]*//' \
        | sed 's/[[:space:]]*#.*$//' \
        | sed "s/^['\"]//; s/['\"]$//" \
        | xargs || true
    }
  fi

  CFG_PRESET=$(_yaml_val "preset")
  CFG_PROFILE=$(_yaml_val "profile")
  CFG_SNIPPETS=$(_yaml_list "snippets")
  CFG_TEAM=$(_yaml_val "team_dir")

  if [[ -n "$CFG_PRESET" ]]; then
    PRESET="$CFG_PRESET"
  else
    PROJECT_TYPE="$CFG_PROFILE"
    read -ra SNIPPETS <<< "$CFG_SNIPPETS"
  fi

  # Resolve team_dir from config
  if [[ -n "$CFG_TEAM" && -z "$TEAM_DIR" ]]; then
    if [[ "$CFG_TEAM" == /* ]]; then
      TEAM_DIR="$CFG_TEAM"
    else
      TEAM_DIR="$OUTPUT_DIR/$CFG_TEAM"
    fi
  fi
fi

# ─── Resolve preset ──────────────────────────────────────────────────────────
if [[ -n "$PRESET" ]]; then
  PRESET_FILE="$RULES_DIR/presets/$PRESET.txt"
  if [[ ! -f "$PRESET_FILE" ]]; then
    echo "❌ Unknown preset: $PRESET"
    echo "   Run './sync.sh --list' to see available presets"
    exit 1
  fi
  PRESET_ARGS=$(grep -v '^#' "$PRESET_FILE" | grep -v '^$' | head -1)
  read -ra PRESET_PARTS <<< "$PRESET_ARGS"
  PROJECT_TYPE="${PRESET_PARTS[0]}"
  SNIPPETS=("${PRESET_PARTS[@]:1}")
  echo "📦 Using preset: $PRESET → $PROJECT_TYPE ${SNIPPETS[*]}"
elif [[ -z "${PROJECT_TYPE:-}" && ${#SNIPPETS[@]} -eq 0 ]]; then
  PROJECT_TYPE=${1:-""}
  shift 2>/dev/null || true
  SNIPPETS=("$@")
fi

# ─── Validate inputs ─────────────────────────────────────────────────────────
if [[ -n "$PROJECT_TYPE" && ! -f "$RULES_DIR/base/$PROJECT_TYPE.md" ]]; then
  echo "❌ Unknown project type: $PROJECT_TYPE"
  echo "   Run './sync.sh --list' to see available options"
  exit 1
fi

if [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "❌ Output directory does not exist: $OUTPUT_DIR"
  exit 1
fi

if [[ ${#SNIPPETS[@]} -gt 0 ]]; then
  for snippet in "${SNIPPETS[@]}"; do
    if [[ ! -f "$RULES_DIR/snippets/$snippet.md" ]]; then
      echo "❌ Unknown snippet: $snippet"
      echo "   Run './sync.sh --list' to see available options"
      exit 1
    fi
  done
fi

if [[ -n "$TEAM_DIR" && ! -d "$TEAM_DIR" ]]; then
  echo "⚠️  Team directory not found: $TEAM_DIR (skipping team rules)"
  TEAM_DIR=""
fi

# ─── Build combined content ──────────────────────────────────────────────────
COMBINED=""

# Always include core
COMBINED+=$(cat "$RULES_DIR/base/core.md")

# Add project type overlay
if [[ -n "$PROJECT_TYPE" ]]; then
  COMBINED+=$'\n\n---\n\n'
  COMBINED+=$(cat "$RULES_DIR/base/$PROJECT_TYPE.md")
fi

# Add snippets
if [[ ${#SNIPPETS[@]} -gt 0 ]]; then
  for snippet in "${SNIPPETS[@]}"; do
    COMBINED+=$'\n\n---\n\n'
    COMBINED+=$(cat "$RULES_DIR/snippets/$snippet.md")
  done
fi

# Add team rules (all .md files in team directory)
if [[ -n "$TEAM_DIR" && -d "$TEAM_DIR" ]]; then
  TEAM_FILES=("$TEAM_DIR"/*.md)
  if [[ -f "${TEAM_FILES[0]}" ]]; then
    echo "👥 Including team rules from: $TEAM_DIR/"
    for tf in "${TEAM_FILES[@]}"; do
      COMBINED+=$'\n\n---\n\n'
      COMBINED+=$(cat "$tf")
    done
  fi
fi

# Add generation footer
COMBINED+=$'\n\n---\n'
COMBINED+=$'\n> **Generated by ai-rules/sync.sh**'
COMBINED+=$"\n> Profile: \`${PROJECT_TYPE:-core}\`"
if [[ ${#SNIPPETS[@]} -gt 0 ]]; then
  COMBINED+=$"\n> Snippets: \`${SNIPPETS[*]}\`"
fi
if [[ -n "$TEAM_DIR" ]]; then
  COMBINED+=$"\n> Team rules: \`$TEAM_DIR\`"
fi
COMBINED+=$"\n> Date: $(date '+%Y-%m-%d %H:%M')"

# ─── --validate: check project structure against rules ────────────────────────
if [[ "$VALIDATE" == true ]]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔍 Validating project against rules..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  ISSUES=0

  # Check: src/ directory exists
  if [[ ! -d "$OUTPUT_DIR/src" ]]; then
    echo "   ⚠️  Missing src/ directory"
    ISSUES=$((ISSUES + 1))
  fi

  # Check: tests/ directory exists
  if [[ ! -d "$OUTPUT_DIR/tests" ]]; then
    echo "   ⚠️  Missing tests/ directory"
    ISSUES=$((ISSUES + 1))
  fi

  # Check: configs/ directory exists
  if [[ ! -d "$OUTPUT_DIR/configs" ]]; then
    echo "   ⚠️  Missing configs/ directory"
    ISSUES=$((ISSUES + 1))
  fi

  # Check: no hardcoded secrets patterns
  if [[ -d "$OUTPUT_DIR/src" ]]; then
    SECRET_HITS=$(grep -rn 'sk-[a-zA-Z0-9]\{20,\}\|AKIA[A-Z0-9]\{16\}\|ghp_[a-zA-Z0-9]\{36\}' "$OUTPUT_DIR/src" "$OUTPUT_DIR/configs" 2>/dev/null | head -5 || true)
    if [[ -n "$SECRET_HITS" ]]; then
      echo "   🚨 Potential hardcoded secrets detected:"
      echo "$SECRET_HITS"
      ISSUES=$((ISSUES + 1))
    fi
  fi

  # Check: no print() in Python files (should use logging)
  if [[ -d "$OUTPUT_DIR/src" ]]; then
    PRINT_COUNT=$(grep -rn '^\s*print(' "$OUTPUT_DIR/src" 2>/dev/null | wc -l | xargs || echo 0)
    if [[ "$PRINT_COUNT" -gt 0 ]]; then
      echo "   ⚠️  Found $PRINT_COUNT print() calls in src/ — use logging module instead"
      ISSUES=$((ISSUES + 1))
    fi
  fi

  # Check: no bare except
  if [[ -d "$OUTPUT_DIR/src" ]]; then
    BARE_EXCEPT=$(grep -rn '^\s*except:\s*$' "$OUTPUT_DIR/src" 2>/dev/null | wc -l | xargs || echo 0)
    if [[ "$BARE_EXCEPT" -gt 0 ]]; then
      echo "   ⚠️  Found $BARE_EXCEPT bare except: clauses — catch specific exceptions"
      ISSUES=$((ISSUES + 1))
    fi
  fi

  # Check: type hints in Python function signatures
  if [[ -d "$OUTPUT_DIR/src" ]]; then
    NO_HINTS=$(grep -rn 'def [a-z].*)\s*:' "$OUTPUT_DIR/src" 2>/dev/null | grep -vc '\->' || echo 0)
    if [[ "$NO_HINTS" -gt 5 ]]; then
      echo "   ⚠️  Found $NO_HINTS functions without return type hints in src/"
      ISSUES=$((ISSUES + 1))
    fi
  fi

  # DS/ML specific checks
  if [[ "$PROJECT_TYPE" == "ds-ml" || "$PROJECT_TYPE" == "llm-eng" ]]; then
    if [[ ! -d "$OUTPUT_DIR/data" ]]; then
      echo "   ⚠️  Missing data/ directory (expected for $PROJECT_TYPE projects)"
      ISSUES=$((ISSUES + 1))
    fi
    if [[ ! -d "$OUTPUT_DIR/notebooks" && ! -d "$OUTPUT_DIR/experiments" ]]; then
      echo "   ⚠️  Missing notebooks/ or experiments/ directory"
      ISSUES=$((ISSUES + 1))
    fi
  fi

  echo ""
  if [[ "$ISSUES" -eq 0 ]]; then
    echo "   ✅ All checks passed!"
  else
    echo "   Found $ISSUES issue(s) — review above warnings"
  fi
  exit 0
fi

# ─── Dry run: just preview ───────────────────────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔍 DRY RUN — preview of combined rules:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$COMBINED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Files that WOULD be written to: $OUTPUT_DIR/"
  echo "   CLAUDE.md"
  echo "   AGENTS.md"
  echo "   .github/copilot-instructions.md"
  echo "   .gemini/styleguide.md"
  echo "   .cursorrules"
  echo "   .windsurfrules"
  exit 0
fi

# ─── Diff mode: show what would change ───────────────────────────────────────
_show_diff() {
  local target="$1"
  if [[ -f "$target" ]]; then
    local tmpfile
    tmpfile=$(mktemp)
    echo "$COMBINED" > "$tmpfile"
    if ! diff -u "$target" "$tmpfile" 2>/dev/null; then
      true  # diff found differences, already printed
    else
      echo "   (no changes) $target"
    fi
    rm -f "$tmpfile"
  else
    echo "   (new file) $target"
  fi
}

if [[ "$DIFF_MODE" == true ]]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔍 DIFF — changes that will be applied:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  _show_diff "$OUTPUT_DIR/CLAUDE.md"
  _show_diff "$OUTPUT_DIR/AGENTS.md"
  _show_diff "$OUTPUT_DIR/.github/copilot-instructions.md"
  _show_diff "$OUTPUT_DIR/.gemini/styleguide.md"
  _show_diff "$OUTPUT_DIR/.cursorrules"
  _show_diff "$OUTPUT_DIR/.windsurfrules"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  read -rp "Apply these changes? (y/N): " apply
  if [[ ! "$apply" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# ─── Write to all tool locations ─────────────────────────────────────────────
echo "$COMBINED" > "$OUTPUT_DIR/CLAUDE.md"
echo "$COMBINED" > "$OUTPUT_DIR/AGENTS.md"

mkdir -p "$OUTPUT_DIR/.github"
echo "$COMBINED" > "$OUTPUT_DIR/.github/copilot-instructions.md"

mkdir -p "$OUTPUT_DIR/.gemini"
echo "$COMBINED" > "$OUTPUT_DIR/.gemini/styleguide.md"

# Cursor / Windsurf support
echo "$COMBINED" > "$OUTPUT_DIR/.cursorrules"
echo "$COMBINED" > "$OUTPUT_DIR/.windsurfrules"

# ─── Summary ─────────────────────────────────────────────────────────────────
echo "✅ AI rules synced successfully"
echo ""
echo "   Profile  : ${PROJECT_TYPE:-core only}"
if [[ ${#SNIPPETS[@]} -gt 0 ]]; then
  echo "   Snippets : ${SNIPPETS[*]}"
fi
if [[ -n "$PRESET" ]]; then
  echo "   Preset   : $PRESET"
fi
if [[ -n "$TEAM_DIR" ]]; then
  echo "   Team     : $TEAM_DIR/"
fi
echo "   Output   : $OUTPUT_DIR/"
echo ""
echo "   Written to:"
echo "   → CLAUDE.md                           (Claude Code)"
echo "   → AGENTS.md                           (OpenAI Codex / ChatGPT)"
echo "   → .github/copilot-instructions.md     (GitHub Copilot)"
echo "   → .gemini/styleguide.md               (Google Gemini Code)"
echo "   → .cursorrules                        (Cursor)"
echo "   → .windsurfrules                      (Windsurf)"
echo ""
echo "💡 Tip: run --validate to check your project against these rules"
