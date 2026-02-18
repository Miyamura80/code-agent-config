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

### Terminal: Ghostty

We highly recommend using [Ghostty](https://ghostty.org/) as your terminal emulator when working with Claude Code. Ghostty provides a superior user experience with features like:

- **OSC 9 Support**: Enables native system notifications from Claude Code
- **Modern Architecture**: Better performance and stability for interactive CLI tools
- **Advanced Pane Management**: Ideal for multitasking with code and agent windows
