#!/usr/bin/env node
// =============================================================================
// ds-agent-rules CLI — thin wrapper around sync.sh / new-project.sh
//
// Usage:
//   npx ds-agent-rules sync [args...]         # run sync.sh with args
//   npx ds-agent-rules init                   # run sync.sh --init
//   npx ds-agent-rules new-project [args...]  # run new-project.sh
//   npx ds-agent-rules list                   # list overlays, snippets, presets
//   npx ds-agent-rules --help
// =============================================================================
"use strict";

const { execFileSync } = require("child_process");
const path = require("path");

const PKG_ROOT = path.resolve(__dirname, "..");
const SYNC = path.join(PKG_ROOT, "sync.sh");
const NEW_PROJECT = path.join(PKG_ROOT, "new-project.sh");

const HELP = `
ds-agent-rules — AI agent rules for DS/ML/AI Engineering

Commands:
  sync [args...]         Sync rules to current directory (runs sync.sh)
  init                   Create .ai-rules.yaml in current directory
  new-project [args...]  Interactive project initializer
  list                   List available overlays, snippets, and presets
  preset <name>          Sync using a named preset
  validate               Check project structure against rules
  diff                   Show changes before applying

Examples:
  npx ds-agent-rules init
  npx ds-agent-rules sync ds-ml rag mlops
  npx ds-agent-rules preset llm-project
  npx ds-agent-rules list

More info: https://github.com/Edwarddev0723/ds-agent-rules
`.trim();

function run(script, args) {
  try {
    execFileSync("bash", [script, ...args], {
      stdio: "inherit",
      cwd: process.cwd(),
      env: { ...process.env, RULES_DIR_OVERRIDE: PKG_ROOT },
    });
  } catch (err) {
    process.exit(err.status || 1);
  }
}

const args = process.argv.slice(2);
const command = args[0] || "--help";
const rest = args.slice(1);

switch (command) {
  case "sync":
    run(SYNC, rest);
    break;
  case "init":
    run(SYNC, ["--init", ...rest]);
    break;
  case "new-project":
  case "new":
    run(NEW_PROJECT, rest);
    break;
  case "list":
    run(SYNC, ["--list", ...rest]);
    break;
  case "preset":
    if (!rest[0]) {
      console.error("Error: preset name required. Run 'ds-agent-rules list' to see options.");
      process.exit(1);
    }
    run(SYNC, ["--preset", ...rest]);
    break;
  case "validate":
    run(SYNC, ["--validate", ...rest]);
    break;
  case "diff":
    run(SYNC, ["--diff", ...rest]);
    break;
  case "--help":
  case "-h":
  case "help":
    console.log(HELP);
    break;
  case "--version":
  case "-v":
    console.log(require("../package.json").version);
    break;
  default:
    // Pass everything directly to sync.sh (e.g., `ds-agent-rules ds-ml rag`)
    run(SYNC, args);
    break;
}
