#!/bin/bash
set -euo pipefail
# =============================================================================
# new-project.sh
# Interactive project initializer — sets up ai-rules and basic project structure
#
# Usage:
#   ./new-project.sh                              # interactive mode
#   ./new-project.sh --preset llm-project --yes   # non-interactive
#   ./new-project.sh --type ds-ml --snippets rag,mlops --scaffold --yes
#
# Non-interactive flags:
#   --preset <name>        Use a preset (same as sync.sh presets)
#   --type <overlay>       Base overlay: ds-ml, llm-eng, data-eng, software-eng, research
#   --snippets <a,b,c>    Comma-separated snippet names
#   --scaffold             Create project directory scaffold
#   --gitignore            Add generated rule files to .gitignore
#   --save-config          Save .ai-rules.yaml (default in non-interactive)
#   --no-save-config       Do not save .ai-rules.yaml
#   --yes / -y             Accept all defaults (non-interactive mode)
# =============================================================================

RULES_DIR="${RULES_DIR_OVERRIDE:-$(cd "$(dirname "$0")" && pwd)}"

# ─── Parse flags ──────────────────────────────────────────────────────────────
ARG_PRESET=""
ARG_TYPE=""
ARG_SNIPPETS=""
ARG_SCAFFOLD=""
ARG_GITIGNORE=""
ARG_SAVE_CONFIG=""
NON_INTERACTIVE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset)     ARG_PRESET="$2"; shift 2 ;;
    --type)       ARG_TYPE="$2"; shift 2 ;;
    --snippets)   ARG_SNIPPETS="$2"; shift 2 ;;
    --scaffold)   ARG_SCAFFOLD=true; shift ;;
    --gitignore)  ARG_GITIGNORE=true; shift ;;
    --save-config)    ARG_SAVE_CONFIG=true; shift ;;
    --no-save-config) ARG_SAVE_CONFIG=false; shift ;;
    --yes|-y)     NON_INTERACTIVE=true; shift ;;
    --help|-h)
      echo "Usage: new-project.sh [OPTIONS]"
      echo ""
      echo "Interactive project initializer. Pass flags for non-interactive mode."
      echo ""
      echo "Options:"
      echo "  --preset <name>       Use a preset (see sync.sh --list)"
      echo "  --type <overlay>      Base overlay: ds-ml, llm-eng, data-eng, software-eng, research"
      echo "  --snippets <a,b,c>    Comma-separated snippet names"
      echo "  --scaffold            Create project directory scaffold"
      echo "  --gitignore           Add generated rule files to .gitignore"
      echo "  --save-config         Save .ai-rules.yaml (default in non-interactive)"
      echo "  --no-save-config      Do not save .ai-rules.yaml"
      echo "  --yes, -y             Accept all defaults (non-interactive mode)"
      echo "  --help, -h            Show this help"
      exit 0
      ;;
    *) echo "❌ Unknown flag: $1"; exit 1 ;;
  esac
done

# Auto-enable non-interactive if --preset or --type was given
if [[ -n "$ARG_PRESET" || -n "$ARG_TYPE" ]]; then
  NON_INTERACTIVE=true
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 AI Rules — New Project Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Non-interactive path ─────────────────────────────────────────────────────
if [[ "$NON_INTERACTIVE" == true ]]; then
  if [[ -n "$ARG_PRESET" ]]; then
    PRESET_FILE="$RULES_DIR/presets/$ARG_PRESET.txt"
    if [[ ! -f "$PRESET_FILE" ]]; then
      echo "❌ Unknown preset: $ARG_PRESET"
      echo "   Available: $(find "$RULES_DIR/presets/" -name '*.txt' -exec basename {} .txt \; | sort | tr '\n' ' ')"
      exit 1
    fi
    PRESET_ARGS=$(grep -v '^#' "$PRESET_FILE" | grep -v '^$' | head -1)
    read -ra PRESET_PARTS <<< "$PRESET_ARGS"
    PROJECT_TYPE="${PRESET_PARTS[0]}"
    SNIPPETS=("${PRESET_PARTS[@]:1}")
    echo "📦 Preset '$ARG_PRESET' → base: $PROJECT_TYPE, snippets: ${SNIPPETS[*]}"
  elif [[ -n "$ARG_TYPE" ]]; then
    PROJECT_TYPE="$ARG_TYPE"
    SNIPPETS=()
    if [[ -n "$ARG_SNIPPETS" ]]; then
      IFS=',' read -ra SNIPPETS <<< "$ARG_SNIPPETS"
    fi
    echo "📋 Type: $PROJECT_TYPE, snippets: ${SNIPPETS[*]:-none}"
  else
    echo "❌ Non-interactive mode requires --preset or --type"
    exit 1
  fi

  SCAFFOLD="${ARG_SCAFFOLD:-false}"
  gitignore_choice="${ARG_GITIGNORE:-false}"
  save_config="${ARG_SAVE_CONFIG:-true}"

else
# ─── Interactive path ─────────────────────────────────────────────────────────

# ─── Preset vs. manual selection ──────────────────────────────────────────────
echo ""
echo "Setup mode:"
echo "  1) Use a preset          (recommended for common project types)"
echo "  2) Manual selection      (pick base overlay + snippets yourself)"
echo ""
read -rp "Choice [1-2]: " mode_choice

if [[ "$mode_choice" == "1" ]]; then
  # ─── Preset selection ─────────────────────────────────────────────────────
  echo ""
  echo "Available presets:"
  PRESET_FILES=("$RULES_DIR/presets"/*.txt)
  for i in "${!PRESET_FILES[@]}"; do
    name=$(basename "${PRESET_FILES[$i]}" .txt)
    content=$(grep -v '^#' "${PRESET_FILES[$i]}" | grep -v '^$' | head -1)
    echo "  $((i+1))) $name  →  $content"
  done
  echo ""
  read -rp "Preset [1-${#PRESET_FILES[@]}]: " preset_choice

  idx=$((preset_choice-1))
  if [[ $idx -ge 0 && $idx -lt ${#PRESET_FILES[@]} ]]; then
    PRESET_NAME=$(basename "${PRESET_FILES[$idx]}" .txt)
  else
    echo "❌ Invalid choice"; exit 1
  fi

  # Read preset args
  PRESET_ARGS=$(grep -v '^#' "$RULES_DIR/presets/$PRESET_NAME.txt" | grep -v '^$' | head -1)
  read -ra PRESET_PARTS <<< "$PRESET_ARGS"
  PROJECT_TYPE="${PRESET_PARTS[0]}"
  SNIPPETS=("${PRESET_PARTS[@]:1}")

  echo ""
  echo "📦 Preset '$PRESET_NAME' → base: $PROJECT_TYPE, snippets: ${SNIPPETS[*]}"

else
  # ─── Project type selection ───────────────────────────────────────────────
  echo ""
  echo "Select project type:"
  echo "  1) ds-ml          Data Science / ML"
  echo "  2) llm-eng        LLM / GenAI Engineering"
  echo "  3) data-eng       Data Engineering"
  echo "  4) software-eng   Traditional Software Engineering"
  echo "  5) research       Research / Academic"
  echo "  6) core           Core rules only"
  echo ""
  read -rp "Choice [1-6]: " type_choice

  case $type_choice in
    1) PROJECT_TYPE="ds-ml" ;;
    2) PROJECT_TYPE="llm-eng" ;;
    3) PROJECT_TYPE="data-eng" ;;
    4) PROJECT_TYPE="software-eng" ;;
    5) PROJECT_TYPE="research" ;;
    6) PROJECT_TYPE="" ;;
    *) echo "❌ Invalid choice"; exit 1 ;;
  esac

  # ─── Snippet selection ──────────────────────────────────────────────────────
  echo ""
  echo "Select snippets to include (space-separated numbers, or Enter to skip):"
  SNIPPET_FILES=("$RULES_DIR/snippets"/*.md)
  for i in "${!SNIPPET_FILES[@]}"; do
    echo "  $((i+1))) $(basename "${SNIPPET_FILES[$i]}" .md)"
  done
  echo ""
  read -rp "Snippets: " snippet_input

  SNIPPETS=()
  for num in $snippet_input; do
    idx=$((num-1))
    if [[ $idx -ge 0 && $idx -lt ${#SNIPPET_FILES[@]} ]]; then
      SNIPPETS+=("$(basename "${SNIPPET_FILES[$idx]}" .md)")
    fi
  done
fi

# ─── Scaffold preference ─────────────────────────────────────────────────────
SCAFFOLD=false
TEMPLATE_TYPE="${PROJECT_TYPE:-ds-ml}"
if [[ -f "$RULES_DIR/templates/$TEMPLATE_TYPE.txt" ]]; then
  echo ""
  read -rp "Create project directory scaffold for '$TEMPLATE_TYPE'? (y/N): " scaffold_choice
  if [[ "$scaffold_choice" =~ ^[Yy]$ ]]; then
    SCAFFOLD=true
  fi
fi

# ─── .gitignore preference ───────────────────────────────────────────────────
echo ""
read -rp "Add generated rule files to .gitignore? (y/N): " gitignore_choice
save_config=""

fi  # end interactive/non-interactive branch

# ─── Run sync ────────────────────────────────────────────────────────────────
echo ""
"$RULES_DIR/sync.sh" "$PROJECT_TYPE" "${SNIPPETS[@]}"

# ─── Create scaffold ─────────────────────────────────────────────────────────
if [[ "$SCAFFOLD" == true ]]; then
  echo ""
  echo "📁 Creating project scaffold..."
  while IFS= read -r line; do
    line=$(echo "$line" | xargs)  # trim whitespace
    [[ -z "$line" || "$line" == \#* || "$line" == "dirs:" ]] && continue
    [[ "$line" == "- "* ]] && line="${line#- }"
    if [[ -n "$line" ]]; then
      mkdir -p "$line"
      echo "   ✓ $line/"
    fi
  done < "$RULES_DIR/templates/$TEMPLATE_TYPE.txt"
fi

# ─── Optional .gitignore update ──────────────────────────────────────────────
if [[ "$gitignore_choice" == true || "$gitignore_choice" =~ ^[Yy]$ ]]; then
  {
    echo ""
    echo "# AI rule files (generated by ai-rules/sync.sh)"
    echo "CLAUDE.md"
    echo "AGENTS.md"
    echo ".github/copilot-instructions.md"
    echo ".gemini/"
    echo ".cursorrules"
    echo ".windsurfrules"
  } >> .gitignore
  echo "📝 Added rule files to .gitignore"
fi

# ─── Generate .ai-rules.yaml ─────────────────────────────────────────────────
if [[ "$NON_INTERACTIVE" != true ]]; then
  echo ""
  read -rp "Save config to .ai-rules.yaml for future sync? (Y/n): " save_config
fi
if [[ "$save_config" != false && ! "$save_config" =~ ^[Nn]$ ]]; then
  {
    echo "# .ai-rules.yaml — auto-generated by new-project.sh"
    echo "profile: ${PROJECT_TYPE:-core}"
    echo "snippets:"
    for s in "${SNIPPETS[@]}"; do
      echo "  - $s"
    done
  } > .ai-rules.yaml
  echo "📝 Saved .ai-rules.yaml — run sync.sh with no args to re-sync"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Project initialized!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Useful commands:"
echo "  $RULES_DIR/sync.sh                    # re-sync from .ai-rules.yaml"
echo "  $RULES_DIR/sync.sh --validate          # check project against rules"
echo "  $RULES_DIR/sync.sh --list              # see all available options"
echo ""
