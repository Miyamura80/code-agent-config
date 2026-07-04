# code-agent-config
🤖🦾🛞 Coding agent configs - CC, OpenCode

## Recommendation

### Terminal: Ghostty

We highly recommend using [Ghostty](https://ghostty.org/) as your terminal emulator when working with Claude Code. Ghostty provides a superior user experience with features like:

- **OSC 9 Support**: Enables native system notifications from Claude Code
- **Modern Architecture**: Better performance and stability for interactive CLI tools
- **Advanced Pane Management**: Ideal for multitasking with code and agent windows

## Code Hygiene Checks

Four checks keep the repo tidy, each wired at three layers that share one
source-of-truth extension set (`SOURCE_EXTS` in the scripts == the `files=`
regex in `prek.toml` == the `paths:` globs in the workflows):

- **Large-file check** (`scripts/check_large_files.sh`): line-count limit per source file.
- **Folder-size check** (`scripts/check_folder_sizes.sh`): file-count limit per folder.
- **Em-dash check** (`scripts/check_ai_writing.py`): flags the em-dash AI tell.
- **Contrastive-parallelism check** (same script): flags the "not X / rather Y" AI tell.

The two shell scripts are shared verbatim between prek and CI (no forked logic).

```
                 SOURCE_EXTS (one shared set)
                          |
        +-----------------+-----------------+
        |                 |                 |
        v                 v                 v
   +---------+       +----------+     +--------------+
   |  prek   |       |  GitHub  |     | Claude Code  |
   | (local  |       |  Actions |     |  on the web  |
   | commit) |       |  (PR CI) |     | (SessionStart|
   |         |       |          |     |  installs +  |
   |         |       |          |     |  wires prek) |
   +---------+       +----------+     +--------------+
   prek.toml     .github/workflows/   .claude/hooks/
                                       session-start.sh
```

Run locally with `prek run --all-files` (install prek via `uv tool install prek`).

## Documentation
- [Global OpenCode Configuration](./opencode/README.md)
- [Claude Code Configuration](./claude-code/README.md)
