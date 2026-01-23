# Global Claude Code Instructions

## Package Manager Preferences

### JavaScript/TypeScript Projects
- **Always use `bun` instead of `npm`** for new projects or projects without an existing package manager
- **Exception**: If a project already has `package-lock.json` or clearly uses npm (check for npm scripts, npm-specific config), continue using npm
- For dependency installation: `bun install` or `bun add <package>`
- For running scripts: `bun run <script>` or `bun <script>`
- For executing files: `bun run <file>`

### Python Projects
- **Always use `uv` instead of `pip`** for dependency management
- **Exception**: If a project explicitly uses pip/virtualenv patterns (requirements.txt with pip freeze format, no pyproject.toml), continue using pip
- For dependency installation: `uv pip install <package>` or `uv add <package>`
- For syncing dependencies: `uv sync`
- For running Python files: `uv run python <file>`
- For running specific tools: `uv run pytest`, `uv run black`, etc.

## Detection Logic
Before choosing a package manager:
1. Check for lock files (`package-lock.json`, `bun.lockb`, `uv.lock`, `requirements.txt`)
2. Check for configuration files (`package.json` scripts, `pyproject.toml`)
3. If ambiguous or new project, default to `bun` (JS/TS) or `uv` (Python)
