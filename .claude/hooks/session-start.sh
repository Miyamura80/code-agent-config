#!/bin/bash
# SessionStart hook: install deps and wire up prek git hooks so commits made in
# Claude Code on the web run the same checks as local clones.
#
# Scoped to remote (web/cloud) sessions via the CLAUDE_CODE_REMOTE guard.
# Remove the guard to also run on local sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}"

# Ensure user-local tool bin is on PATH for this and later session commands.
export PATH="$HOME/.local/bin:$PATH"
path_line='export PATH="$HOME/.local/bin:$PATH"'
if [ -n "${CLAUDE_ENV_FILE:-}" ] && ! grep -qF "$path_line" "$CLAUDE_ENV_FILE" 2>/dev/null; then
  echo "$path_line" >> "$CLAUDE_ENV_FILE"
fi

# This repo is a config/scripting repo (shell + JS). No package manager sync is
# required. If you add a Python or Node toolchain, install it here, e.g.:
#   uv sync        (Python/uv)
#   bun install    (Node/bun)

# Install prek if missing, then wire up the git hooks so cloud commits run them.
# prek is a standalone binary installed via the official installer.
if ! command -v prek >/dev/null 2>&1; then
  curl -LsSf https://prek.j178.dev/install.sh | sh
fi
prek install

exit 0
