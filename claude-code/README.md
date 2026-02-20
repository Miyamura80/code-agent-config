# Claude Code Configuration

This directory contains configuration files for Claude Code.

## Where Claude Code Stores Global Config

- Global user settings: `~/.claude/settings.json`
- Global user local-only settings: `~/.claude/settings.local.json`
- Global helper scripts (for hooks): `~/.claude/scripts/`

Per-project overrides live inside the repo:

- Project settings: `<repo>/.claude/settings.json`

## What This Repo Contains

- Reference global settings: `claude-code/settings.json`
- Hook script (project-scope write guard): `claude-code/scripts/validate-project-file-ops.sh`

To apply these globally, copy them into:

- `~/.claude/settings.json` (merge with your existing settings)
- `~/.claude/scripts/validate-project-file-ops.sh`

## Recommendations

- Terminal recommendation lives in the root `README.md`.
