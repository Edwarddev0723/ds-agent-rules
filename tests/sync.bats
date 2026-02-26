#!/usr/bin/env bats
# =============================================================================
# Integration tests for sync.sh
# Requires: bats-core (https://github.com/bats-core/bats-core)
# Run: bats tests/ or make test
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
SYNC="$SCRIPT_DIR/sync.sh"

setup() {
  TEST_DIR=$(mktemp -d)
}

teardown() {
  rm -rf "$TEST_DIR"
}

# ─── Basic functionality ─────────────────────────────────────────────────────

@test "sync.sh runs with no args (core only)" {
  run bash "$SYNC" --output-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/CLAUDE.md" ]
  [ -f "$TEST_DIR/AGENTS.md" ]
  [ -f "$TEST_DIR/.github/copilot-instructions.md" ]
  [ -f "$TEST_DIR/.gemini/styleguide.md" ]
  [ -f "$TEST_DIR/.cursorrules" ]
  [ -f "$TEST_DIR/.windsurfrules" ]
}

@test "all 6 output files have identical content" {
  run bash "$SYNC" --output-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  local md5_claude md5_agents md5_copilot md5_gemini md5_cursor md5_windsurf
  if command -v md5sum &>/dev/null; then
    md5_claude=$(md5sum "$TEST_DIR/CLAUDE.md" | awk '{print $1}')
    md5_agents=$(md5sum "$TEST_DIR/AGENTS.md" | awk '{print $1}')
    md5_copilot=$(md5sum "$TEST_DIR/.github/copilot-instructions.md" | awk '{print $1}')
    md5_gemini=$(md5sum "$TEST_DIR/.gemini/styleguide.md" | awk '{print $1}')
    md5_cursor=$(md5sum "$TEST_DIR/.cursorrules" | awk '{print $1}')
    md5_windsurf=$(md5sum "$TEST_DIR/.windsurfrules" | awk '{print $1}')
  else
    md5_claude=$(md5 -q "$TEST_DIR/CLAUDE.md")
    md5_agents=$(md5 -q "$TEST_DIR/AGENTS.md")
    md5_copilot=$(md5 -q "$TEST_DIR/.github/copilot-instructions.md")
    md5_gemini=$(md5 -q "$TEST_DIR/.gemini/styleguide.md")
    md5_cursor=$(md5 -q "$TEST_DIR/.cursorrules")
    md5_windsurf=$(md5 -q "$TEST_DIR/.windsurfrules")
  fi
  [ "$md5_claude" = "$md5_agents" ]
  [ "$md5_claude" = "$md5_copilot" ]
  [ "$md5_claude" = "$md5_gemini" ]
  [ "$md5_claude" = "$md5_cursor" ]
  [ "$md5_claude" = "$md5_windsurf" ]
}

@test "core.md content is always present" {
  run bash "$SYNC" --output-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  # Check that the first heading from core.md appears in the output
  local first_heading
  first_heading=$(grep '^#' "$SCRIPT_DIR/base/core.md" | head -1)
  grep -qF "$first_heading" "$TEST_DIR/CLAUDE.md"
}

# ─── Overlay loading ─────────────────────────────────────────────────────────

@test "sync with ds-ml overlay includes ds-ml content" {
  run bash "$SYNC" --output-dir "$TEST_DIR" ds-ml
  [ "$status" -eq 0 ]
  grep -q "ds-ml\|Data Science\|ML" "$TEST_DIR/CLAUDE.md"
}

@test "sync with llm-eng overlay includes llm-eng content" {
  run bash "$SYNC" --output-dir "$TEST_DIR" llm-eng
  [ "$status" -eq 0 ]
  grep -q "llm-eng\|LLM\|Prompt" "$TEST_DIR/CLAUDE.md"
}

@test "unknown overlay exits with error" {
  run bash "$SYNC" --output-dir "$TEST_DIR" nonexistent-overlay
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown project type"* ]]
}

# ─── Snippet loading ─────────────────────────────────────────────────────────

@test "snippet rag is appended correctly" {
  run bash "$SYNC" --output-dir "$TEST_DIR" ds-ml rag
  [ "$status" -eq 0 ]
  grep -qi "RAG\|retrieval\|chunking" "$TEST_DIR/CLAUDE.md"
}

@test "multiple snippets are all included" {
  run bash "$SYNC" --output-dir "$TEST_DIR" ds-ml rag mlops
  [ "$status" -eq 0 ]
  grep -qi "RAG\|retrieval" "$TEST_DIR/CLAUDE.md"
  grep -qi "MLOps\|deployment\|CI/CD" "$TEST_DIR/CLAUDE.md"
}

@test "unknown snippet exits with error" {
  run bash "$SYNC" --output-dir "$TEST_DIR" ds-ml nonexistent-snippet
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown snippet"* ]]
}

# ─── Presets ──────────────────────────────────────────────────────────────────

@test "--preset llm-project works" {
  run bash "$SYNC" --output-dir "$TEST_DIR" --preset llm-project
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/CLAUDE.md" ]
  grep -qi "LLM\|fine-tun" "$TEST_DIR/CLAUDE.md"
}

@test "--preset unknown exits with error" {
  run bash "$SYNC" --output-dir "$TEST_DIR" --preset nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown preset"* ]]
}

@test "all preset files are valid (reference existing overlays and snippets)" {
  for preset_file in "$SCRIPT_DIR/presets"/*.txt; do
    local args
    args=$(grep -v '^#' "$preset_file" | grep -v '^$' | head -1)
    read -ra parts <<< "$args"
    # First part should be a valid overlay
    [ -f "$SCRIPT_DIR/base/${parts[0]}.md" ]
    # Remaining parts should be valid snippets
    for snippet in "${parts[@]:1}"; do
      [ -f "$SCRIPT_DIR/snippets/$snippet.md" ]
    done
  done
}

# ─── Flags ────────────────────────────────────────────────────────────────────

@test "--list shows overlays, snippets, and presets" {
  run bash "$SYNC" --list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available base overlays"* ]]
  [[ "$output" == *"Available snippets"* ]]
  [[ "$output" == *"Available presets"* ]]
  [[ "$output" == *"ds-ml"* ]]
  [[ "$output" == *"rag"* ]]
}

@test "--dry-run does not write files" {
  run bash "$SYNC" --output-dir "$TEST_DIR" --dry-run ds-ml
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_DIR/CLAUDE.md" ]
  [[ "$output" == *"DRY RUN"* ]]
}

@test "--output-dir writes to specified directory" {
  local subdir="$TEST_DIR/subproject"
  mkdir -p "$subdir"
  run bash "$SYNC" --output-dir "$subdir" ds-ml
  [ "$status" -eq 0 ]
  [ -f "$subdir/CLAUDE.md" ]
  [ ! -f "$TEST_DIR/CLAUDE.md" ]  # should NOT be in parent
}

@test "--output-dir with nonexistent dir exits with error" {
  run bash "$SYNC" --output-dir "$TEST_DIR/nonexistent"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "unknown flag exits with error" {
  run bash "$SYNC" --nonexistent-flag
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown flag"* ]]
}

# ─── .ai-rules.yaml ──────────────────────────────────────────────────────────

@test "--init creates .ai-rules.yaml" {
  run bash "$SYNC" --output-dir "$TEST_DIR" --init
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.ai-rules.yaml" ]
  grep -q "profile:" "$TEST_DIR/.ai-rules.yaml"
  grep -q "snippets:" "$TEST_DIR/.ai-rules.yaml"
}

@test "auto-detects .ai-rules.yaml with profile + snippets" {
  cat > "$TEST_DIR/.ai-rules.yaml" << 'EOF'
profile: ds-ml
snippets:
  - rag
  - mlops
EOF
  run bash "$SYNC" --output-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  grep -qi "RAG\|retrieval" "$TEST_DIR/CLAUDE.md"
  grep -qi "MLOps" "$TEST_DIR/CLAUDE.md"
}

@test "auto-detects .ai-rules.yaml with preset" {
  cat > "$TEST_DIR/.ai-rules.yaml" << 'EOF'
preset: llm-project
EOF
  run bash "$SYNC" --output-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  grep -qi "LLM\|fine-tun" "$TEST_DIR/CLAUDE.md"
}

# ─── Team rules ──────────────────────────────────────────────────────────────

@test "--team includes team rules" {
  local team_dir="$TEST_DIR/team"
  mkdir -p "$team_dir"
  echo "# Team Rule: Always use our internal API" > "$team_dir/internal.md"
  run bash "$SYNC" --output-dir "$TEST_DIR" --team "$team_dir" ds-ml
  [ "$status" -eq 0 ]
  grep -q "internal API" "$TEST_DIR/CLAUDE.md"
}

@test "--team with nonexistent dir warns but continues" {
  run bash "$SYNC" --output-dir "$TEST_DIR" --team "$TEST_DIR/nope" ds-ml
  [ "$status" -eq 0 ]
  [[ "$output" == *"not found"* ]]
}

# ─── Generation footer ───────────────────────────────────────────────────────

@test "output includes generation footer" {
  run bash "$SYNC" --output-dir "$TEST_DIR" ds-ml rag
  [ "$status" -eq 0 ]
  grep -q "Generated by ai-rules/sync.sh" "$TEST_DIR/CLAUDE.md"
  grep -q "Profile:" "$TEST_DIR/CLAUDE.md"
  grep -q "Snippets:" "$TEST_DIR/CLAUDE.md"
  grep -q "Date:" "$TEST_DIR/CLAUDE.md"
}

# ─── Validate ────────────────────────────────────────────────────────────────

@test "--validate checks project structure" {
  mkdir -p "$TEST_DIR/src" "$TEST_DIR/tests" "$TEST_DIR/configs"
  run bash "$SYNC" --output-dir "$TEST_DIR" --validate
  [ "$status" -eq 0 ]
  [[ "$output" == *"Validating"* ]]
}

@test "--validate detects missing src/" {
  run bash "$SYNC" --output-dir "$TEST_DIR" --validate
  [ "$status" -eq 0 ]
  [[ "$output" == *"Missing src/"* ]]
}

# ─── Snippet format compliance ────────────────────────────────────────────────

@test "all snippets have Common Pitfalls section" {
  for f in "$SCRIPT_DIR/snippets"/*.md; do
    grep -qi "pitfall" "$f" || {
      echo "Missing pitfalls section in $(basename "$f")"
      return 1
    }
  done
}

@test "all snippets have at least 25 lines" {
  for f in "$SCRIPT_DIR/snippets"/*.md; do
    local lines
    lines=$(wc -l < "$f" | xargs)
    [ "$lines" -ge 25 ] || {
      echo "$(basename "$f") has only $lines lines (minimum 25)"
      return 1
    }
  done
}

@test "all base overlays exist and are non-empty" {
  for f in "$SCRIPT_DIR/base"/*.md; do
    [ -s "$f" ]
  done
}

# ─── YAML parser: inline comments and quotes ─────────────────────────────────

@test "YAML parser handles inline comments" {
  cat > "$TEST_DIR/.ai-rules.yaml" << 'EOF'
profile: ds-ml  # my project type
snippets:
  - rag    # core retrieval
  - mlops  # deployment
EOF
  run bash "$SYNC" --output-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  grep -qi "RAG\|retrieval" "$TEST_DIR/CLAUDE.md"
  grep -qi "MLOps" "$TEST_DIR/CLAUDE.md"
}

@test "YAML parser handles quoted values" {
  cat > "$TEST_DIR/.ai-rules.yaml" << 'EOF'
profile: "ds-ml"
snippets:
  - 'rag'
  - "mlops"
EOF
  run bash "$SYNC" --output-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  grep -qi "RAG\|retrieval" "$TEST_DIR/CLAUDE.md"
  grep -qi "MLOps" "$TEST_DIR/CLAUDE.md"
}

# ─── new-project.sh non-interactive mode ──────────────────────────────────────

@test "new-project.sh --preset works non-interactively" {
  run bash "$SCRIPT_DIR/new-project.sh" --preset llm-project --no-save-config
  [ "$status" -eq 0 ]
  [[ "$output" == *"Preset 'llm-project'"* ]]
  [ -f "CLAUDE.md" ] || [ -f "$PWD/CLAUDE.md" ]
}

@test "new-project.sh --type + --snippets works non-interactively" {
  local out_dir
  out_dir=$(mktemp -d)
  cd "$out_dir"
  run bash "$SCRIPT_DIR/new-project.sh" --type ds-ml --snippets rag,mlops --no-save-config
  [ "$status" -eq 0 ]
  [[ "$output" == *"Type: ds-ml"* ]]
  cd -
  rm -rf "$out_dir"
}

@test "new-project.sh --help shows usage" {
  run bash "$SCRIPT_DIR/new-project.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--preset"* ]]
  [[ "$output" == *"--yes"* ]]
}

@test "new-project.sh rejects unknown flags" {
  run bash "$SCRIPT_DIR/new-project.sh" --nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown flag"* ]]
}

# ─── All presets can be synced ────────────────────────────────────────────────

@test "every preset produces valid output" {
  for preset_file in "$SCRIPT_DIR/presets"/*.txt; do
    local name
    name=$(basename "$preset_file" .txt)
    run bash "$SYNC" --output-dir "$TEST_DIR" --preset "$name"
    [ "$status" -eq 0 ] || {
      echo "Preset $name failed with status $status"
      echo "$output"
      return 1
    }
    [ -f "$TEST_DIR/CLAUDE.md" ]
    rm -f "$TEST_DIR/CLAUDE.md" "$TEST_DIR/AGENTS.md" "$TEST_DIR/.cursorrules" "$TEST_DIR/.windsurfrules"
    rm -rf "$TEST_DIR/.github" "$TEST_DIR/.gemini"
  done
}

# ─── Every snippet has required format ────────────────────────────────────────

@test "all snippets have Domain Context section" {
  for f in "$SCRIPT_DIR/snippets"/*.md; do
    grep -q "^## Domain Context" "$f" || {
      echo "Missing Domain Context in $(basename "$f")"
      return 1
    }
  done
}

@test "all snippets have Snippet title" {
  for f in "$SCRIPT_DIR/snippets"/*.md; do
    grep -q "^# Snippet:" "$f" || {
      echo "Missing '# Snippet:' title in $(basename "$f")"
      return 1
    }
  done
}

@test "no orphan snippets — every snippet is used in at least one preset" {
  for f in "$SCRIPT_DIR/snippets"/*.md; do
    local name
    name=$(basename "$f" .md)
    local count
    count=$(grep -rl "$name" "$SCRIPT_DIR/presets/" 2>/dev/null | wc -l | xargs)
    [ "$count" -gt 0 ] || {
      echo "Orphan snippet: $name (not in any preset)"
      return 1
    }
  done
}
