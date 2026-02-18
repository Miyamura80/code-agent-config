#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook: allow edits/writes only within the current project directory.
# Claude Code sets CLAUDE_PROJECT_DIR for the active project.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$PROJECT_DIR" ]; then
  # If Claude didn't provide a project dir, don't block tool usage.
  exit 0
fi

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  # Can't validate without a JSON parser.
  exit 0
fi

INPUT_JSON="$(cat)"

printf '%s' "$INPUT_JSON" | "$PYTHON_BIN" - <<'PY'
import json
import os
import sys


def deny(reason: str) -> None:
    sys.stderr.write(json.dumps({"decision": "deny", "reason": reason}))
    sys.stderr.write("\n")
    raise SystemExit(2)


project_dir = os.environ.get("CLAUDE_PROJECT_DIR")
if not project_dir:
    raise SystemExit(0)

try:
    payload = json.loads(sys.stdin.read() or "{}")
except Exception:
    # Fail open if hook input is unknown/unparseable.
    raise SystemExit(0)

tool_input = payload.get("tool_input")
if not isinstance(tool_input, dict):
    raise SystemExit(0)


def collect_paths(obj) -> list[str]:
    paths: list[str] = []

    if isinstance(obj, dict):
        for k in ("file_path", "path"):
            v = obj.get(k)
            if isinstance(v, str) and v:
                paths.append(v)

        edits = obj.get("edits")
        if isinstance(edits, list):
            for e in edits:
                if isinstance(e, dict):
                    v = e.get("file_path") or e.get("path")
                    if isinstance(v, str) and v:
                        paths.append(v)

        files = obj.get("files")
        if isinstance(files, list):
            for f in files:
                if isinstance(f, dict):
                    v = f.get("file_path") or f.get("path")
                    if isinstance(v, str) and v:
                        paths.append(v)

    return paths


paths = collect_paths(tool_input)
if not paths:
    raise SystemExit(0)

project_real = os.path.realpath(project_dir)

for p in paths:
    if p.startswith("~"):
        deny("Edits/writes must stay within the project directory")

    abs_path = p if os.path.isabs(p) else os.path.join(project_dir, p)
    real_path = os.path.realpath(abs_path)

    try:
        common = os.path.commonpath([project_real, real_path])
    except Exception:
        deny("Edits/writes must stay within the project directory")

    if common != project_real:
        deny(f"Blocked file change outside project: {p}")

raise SystemExit(0)
PY
