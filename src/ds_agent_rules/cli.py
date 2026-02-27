"""CLI wrapper for ds-agent-rules shell scripts."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

# Data files are bundled alongside this module
_DATA_DIR = Path(__file__).resolve().parent / "data"
_SYNC = _DATA_DIR / "sync.sh"
_NEW_PROJECT = _DATA_DIR / "new-project.sh"

HELP = """\
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
  ds-agent-rules init
  ds-agent-rules sync ds-ml rag mlops
  ds-agent-rules preset llm-project
  ds-agent-rules list

More info: https://github.com/Edwarddev0723/ds-agent-rules
"""


def _run(script: Path, args: list[str]) -> None:
    """Execute a shell script with the bundled data directory."""
    env_override = {"RULES_DIR_OVERRIDE": str(_DATA_DIR)}
    import os

    env = {**os.environ, **env_override}
    result = subprocess.run(
        ["bash", str(script), *args],
        env=env,
    )
    sys.exit(result.returncode)


def main() -> None:
    """Entry point for the ds-agent-rules CLI."""
    args = sys.argv[1:]
    command = args[0] if args else "--help"
    rest = args[1:]

    if command in ("sync",):
        _run(_SYNC, rest)
    elif command in ("init",):
        _run(_SYNC, ["--init", *rest])
    elif command in ("new-project", "new"):
        _run(_NEW_PROJECT, rest)
    elif command in ("list",):
        _run(_SYNC, ["--list", *rest])
    elif command in ("preset",):
        if not rest:
            print(
                "Error: preset name required. "
                "Run 'ds-agent-rules list' to see options.",
                file=sys.stderr,
            )
            sys.exit(1)
        _run(_SYNC, ["--preset", *rest])
    elif command in ("validate",):
        _run(_SYNC, ["--validate", *rest])
    elif command in ("diff",):
        _run(_SYNC, ["--diff", *rest])
    elif command in ("--help", "-h", "help"):
        print(HELP)
    elif command in ("--version", "-v"):
        from ds_agent_rules import __version__

        print(__version__)
    else:
        # Pass everything directly to sync.sh
        _run(_SYNC, args)


if __name__ == "__main__":
    main()
