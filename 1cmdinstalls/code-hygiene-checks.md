Task: Port four code-hygiene checks (folder-size, large-file, em-dash, contrastive-parallelism) with matching prek + CI + Claude-Code-cloud wiring — LANGUAGE-AGNOSTIC
Re-implement these four checks in THIS repository. Each runs at three layers, all kept in sync:

1. prek (pre-commit hook manager — `prek.toml` at repo root; overrides `.pre-commit-config.yaml`)
2. GitHub Actions (PR-time CI, mirroring the local hook)
3. Claude Code on the web / cloud — a SessionStart hook that installs and wires up prek so cloud commits run the same checks
The two size scripts are shared verbatim between the prek hook and the CI workflow — do not fork their logic.
Configure the source-extension set FIRST
At the top of both shell scripts there is a `SOURCE_EXTS` list. Set it to the extensions that count as "source" in THIS repo. Default below covers the common ones — trim or extend to match the actual languages present (run a quick file-extension census of the repo and pick accordingly). Everything else (thresholds, exclusions, exit codes, output) stays identical regardless of language.
1 + 2. Folder-size check & Large-file check
Create `scripts/check_large_files.sh` and `scripts/check_folder_sizes.sh` (`chmod +x` both).
`scripts/check_large_files.sh` — line-count limit per source file

```bash
#!/usr/bin/env bash
#
# Enforce a line-count limit on source files. Shared by
# .github/workflows/large-files.yaml and prek.toml.
#
# Usage:
#   check_large_files.sh [file ...]   # check the given files
#   check_large_files.sh --all        # scan the whole tree
#
# Thresholds: warn at WARN lines, error at ERROR lines. Override via
# LARGE_FILE_WARN_THRESHOLD / LARGE_FILE_ERROR_THRESHOLD env vars.
# Exit 1 on errors, 0 on warnings-only or clean.
# If $GITHUB_STEP_SUMMARY is set, a markdown summary is appended to it.

set -euo pipefail

WARN_THRESHOLD="${LARGE_FILE_WARN_THRESHOLD:-500}"
ERROR_THRESHOLD="${LARGE_FILE_ERROR_THRESHOLD:-800}"

# --- Configure for this repo's languages (extensions WITHOUT the dot) ---
SOURCE_EXTS=(py js jsx ts tsx go rs java kt rb php c cc cpp h hpp cs swift scala m mm)

# Build a find-friendly predicate and a fast lookup set from SOURCE_EXTS.
declare -A _EXT_SET=()
for e in "${SOURCE_EXTS[@]}"; do _EXT_SET[".$e"]=1; done

EXCLUDE_PATH_RE='(^|/)(node_modules|__pycache__|\.venv|venv|vendor|visual-tests|e2e|tests|test|__tests__|\.git|dist|build|target)(/|$)'
# Generated/migration dirs that shouldn't count against authors:
GENERATED_RE='(^|/)(alembic[^/]*/versions|migrations)(/|$)'
# Per-file name exclusions (test files, generated stubs, etc.). Extend as needed.
EXCLUDE_NAME_RE='(^test_.+|.+_test|.+\.test|.+\.spec|conftest\.py|vulture_whitelist\.py)\.[A-Za-z]+$'

is_source_file() {
  local ext=".${1##*.}"
  [ -n "${_EXT_SET[$ext]:-}" ]
}

is_excluded() {
  local f="$1" base
  echo "$f" | grep -qE "$EXCLUDE_PATH_RE" && return 0
  echo "$f" | grep -qE "$GENERATED_RE" && return 0
  base=$(basename "$f")
  echo "$base" | grep -qE "$EXCLUDE_NAME_RE" && return 0
  return 1
}

collect_all() {
  local find_args=() first=1
  for e in "${SOURCE_EXTS[@]}"; do
    if [ "$first" = 1 ]; then find_args+=( -name "*.$e" ); first=0
    else find_args+=( -o -name "*.$e" ); fi
  done
  find . -type f \( "${find_args[@]}" \) \
    -not -path './.git/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/.venv/*' \
    -not -path '*/venv/*' \
    -not -path '*/node_modules/*' \
    | sed 's|^\./||'
}

files=()
if [ "${1:-}" = "--all" ]; then
  mapfile -t files < <(collect_all)
else
  files=("$@")
fi

warnings=0
errors=0
warn_list=""
error_list=""

for file in "${files[@]}"; do
  [ -z "$file" ] && continue
  [ ! -f "$file" ] && continue
  is_source_file "$file" || continue
  is_excluded "$file" && continue

  lines=$(wc -l < "$file")
  if [ "$lines" -gt "$ERROR_THRESHOLD" ]; then
    errors=$((errors + 1))
    error_list="${error_list}| \`${file}\` | ${lines} | :x: exceeds ${ERROR_THRESHOLD} |\n"
  elif [ "$lines" -gt "$WARN_THRESHOLD" ]; then
    warnings=$((warnings + 1))
    warn_list="${warn_list}| \`${file}\` | ${lines} | :warning: exceeds ${WARN_THRESHOLD} |\n"
  fi
done

if [ -n "${GITHUB_STEP_SUMMARY:-}" ] && { [ "$errors" -gt 0 ] || [ "$warnings" -gt 0 ]; }; then
  {
    echo "## Large File Report"
    echo ""
    echo "| File | Lines | Status |"
    echo "|------|-------|--------|"
    [ "$errors" -gt 0 ] && printf '%b' "$error_list"
    [ "$warnings" -gt 0 ] && printf '%b' "$warn_list"
    echo ""
    echo "**Thresholds:** warn at ${WARN_THRESHOLD} lines, error at ${ERROR_THRESHOLD} lines"
  } >> "$GITHUB_STEP_SUMMARY"
fi

format_list() {
  if command -v column >/dev/null 2>&1; then
    printf '%b' "$1" | column -t -s '|'
  else
    printf '%b' "$1"
  fi
}

if [ "$errors" -gt 0 ]; then
  echo "::error::${errors} file(s) exceed the ${ERROR_THRESHOLD}-line error threshold" >&2
  format_list "$error_list" >&2
fi
if [ "$warnings" -gt 0 ]; then
  echo "::warning::${warnings} file(s) exceed the ${WARN_THRESHOLD}-line warning threshold" >&2
  format_list "$warn_list" >&2
fi
if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
  echo "All source files are within the ${WARN_THRESHOLD}-line limit."
fi

[ "$errors" -gt 0 ] && exit 1
exit 0

```

`scripts/check_folder_sizes.sh` — file-count limit per folder (non-recursive)

```bash
#!/usr/bin/env bash
#
# Enforce a file-count limit on source folders (non-recursive). Shared by
# .github/workflows/folder-size.yaml and prek.toml.
#
# Usage:
#   check_folder_sizes.sh [file ...]   # check folders containing the given files
#   check_folder_sizes.sh --all        # scan every folder in the tree
#
# Thresholds: warn at WARN files-per-folder, error at ERROR. Override via
# FOLDER_WARN_THRESHOLD / FOLDER_ERROR_THRESHOLD env vars.
# Exit 1 on non-grandfathered errors, 0 on warnings-only or clean.
# If $GITHUB_STEP_SUMMARY is set, a markdown summary is appended to it.

set -euo pipefail

WARN_THRESHOLD="${FOLDER_WARN_THRESHOLD:-20}"
ERROR_THRESHOLD="${FOLDER_ERROR_THRESHOLD:-35}"

# --- Configure for this repo's languages (extensions WITHOUT the dot) ---
SOURCE_EXTS=(py js jsx ts tsx go rs java kt rb php c cc cpp h hpp cs swift scala m mm)

# Folders explicitly allowed to exceed the limit (warn instead of error).
GRANDFATHERED=()

EXCLUDE_PATH_RE='(^|/)(node_modules|__pycache__|\.venv|venv|vendor|visual-tests|e2e|tests|test|__tests__|\.git|dist|build|target)(/|$)'
GENERATED_RE='(^|/)(alembic[^/]*/versions|migrations)(/|$)'

is_grandfathered() {
  local target="$1"
  for g in "${GRANDFATHERED[@]}"; do
    [ "$target" = "$g" ] && return 0
  done
  return 1
}

should_skip() {
  local f="$1"
  [ -z "$f" ] && return 0
  [ "$f" = "." ] && return 0
  echo "$f" | grep -qE "$EXCLUDE_PATH_RE" && return 0
  echo "$f" | grep -qE "$GENERATED_RE" && return 0
  return 1
}

count_folder() {
  local find_args=() first=1
  for e in "${SOURCE_EXTS[@]}"; do
    if [ "$first" = 1 ]; then find_args+=( -name "*.$e" ); first=0
    else find_args+=( -o -name "*.$e" ); fi
  done
  # Count immediate source children only; skip obvious test/generated stubs.
  find "$1" -mindepth 1 -maxdepth 1 -type f \( "${find_args[@]}" \) \
    -not -name 'test_*' \
    -not -name '*_test.*' \
    -not -name '*.test.*' \
    -not -name '*.spec.*' \
    -not -name 'conftest.py' \
    -not -name 'vulture_whitelist.py' \
    | wc -l
}

collect_all_folders() {
  find . -type d \
    -not -path './.git/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/.venv/*' \
    -not -path '*/venv/*' \
    -not -path '*/node_modules/*' \
    | sed 's|^\./||'
}

folder_list=$(mktemp)
trap 'rm -f "$folder_list"' EXIT

if [ "${1:-}" = "--all" ]; then
  collect_all_folders > "$folder_list"
else
  for f in "$@"; do
    [ -z "$f" ] && continue
    dirname "$f"
  done | sort -u > "$folder_list"
fi

warnings=0
errors=0
warn_list=""
error_list=""

while IFS= read -r folder; do
  folder="${folder#./}"
  should_skip "$folder" && continue
  [ ! -d "$folder" ] && continue

  count=$(count_folder "$folder")

  if [ "$count" -gt "$ERROR_THRESHOLD" ]; then
    if is_grandfathered "$folder"; then
      warnings=$((warnings + 1))
      warn_list="${warn_list}| \`${folder}/\` | ${count} | :warning: exceeds ${ERROR_THRESHOLD} (grandfathered) |\n"
    else
      errors=$((errors + 1))
      error_list="${error_list}| \`${folder}/\` | ${count} | :x: exceeds ${ERROR_THRESHOLD} |\n"
    fi
  elif [ "$count" -gt "$WARN_THRESHOLD" ]; then
    warnings=$((warnings + 1))
    warn_list="${warn_list}| \`${folder}/\` | ${count} | :warning: exceeds ${WARN_THRESHOLD} |\n"
  fi
done < "$folder_list"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ] && { [ "$errors" -gt 0 ] || [ "$warnings" -gt 0 ]; }; then
  {
    echo "## Folder Size Report"
    echo ""
    echo "| Folder | Files | Status |"
    echo "|--------|-------|--------|"
    [ "$errors" -gt 0 ] && printf '%b' "$error_list"
    [ "$warnings" -gt 0 ] && printf '%b' "$warn_list"
    echo ""
    echo "**Thresholds:** warn at ${WARN_THRESHOLD} files, error at ${ERROR_THRESHOLD} files. Counts immediate source children only - subfolders are the fix, not the problem."
  } >> "$GITHUB_STEP_SUMMARY"
fi

format_list() {
  if command -v column >/dev/null 2>&1; then
    printf '%b' "$1" | column -t -s '|'
  else
    printf '%b' "$1"
  fi
}

if [ "$errors" -gt 0 ]; then
  echo "::error::${errors} folder(s) exceed the ${ERROR_THRESHOLD}-file error threshold" >&2
  format_list "$error_list" >&2
fi
if [ "$warnings" -gt 0 ]; then
  echo "::warning::${warnings} folder(s) exceed the ${WARN_THRESHOLD}-file warning threshold" >&2
  format_list "$warn_list" >&2
fi
if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
  echo "All folders are within the ${WARN_THRESHOLD}-file limit."
fi

[ "$errors" -gt 0 ] && exit 1
exit 0

```

Matching GitHub Actions workflows
Trigger on changes to any source file. Replace the `paths:` glob list and the `git diff` pathspecs with the same extensions you put in `SOURCE_EXTS`.
`.github/workflows/large-files.yaml`:

```yaml
name: Large File Check
on:
  workflow_dispatch:
  pull_request:
    paths:
      # Mirror SOURCE_EXTS from the script:
      - '**.py'
      - '**.js'
      - '**.ts'
      - '**.tsx'
      - '**.go'
      - '**.rs'
      # ...add the rest of your SOURCE_EXTS here
jobs:
  check-file-sizes:
    name: Source File Line Limit
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - name: Check for large source files
        run: |
          if [ -n "${{ github.event.pull_request.base.sha }}" ]; then
            mapfile -t files < <(git diff --name-only --diff-filter=d "${{ github.event.pull_request.base.sha }}...HEAD")
            if [ "${#files[@]}" -eq 0 ]; then
              echo "No files changed."
              exit 0
            fi
            # Script self-filters non-source files via SOURCE_EXTS, so pass them all.
            scripts/check_large_files.sh "${files[@]}"
          else
            scripts/check_large_files.sh --all
          fi

```

`.github/workflows/folder-size.yaml`: identical structure, but `name: Folder Size Check`, job name `Folder File Count Limit`, and call `scripts/check_folder_sizes.sh`.
Note: passing all changed files to the scripts is safe because `is_source_file`/`count_folder` already filter by `SOURCE_EXTS`. That keeps CI from needing a per-language `git diff` pathspec.
3 + 4. Em-dash checker + Contrastive-parallelism checker ("AI writing check")
This one is already language-agnostic — it scans every text file in the repo (skipping binaries and vendored dirs), so it needs no per-language config. Create `scripts/check_ai_writing.py`. It FAILS (exit 1) on either AI-writing tell: em dashes or contrastive-parallelism constructions ("not just X, but Y"). Report each violation as `path:lineno: snippet`.

```python
from __future__ import annotations

import pathlib
import re
from collections.abc import Iterable, Sequence

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
EM_DASH = chr(0x2014)
SELF = pathlib.Path(__file__).resolve()  # don't flag this script's own patterns

ROOT_SKIP_DIRS = {
    ".git", ".venv", ".uv_cache", ".uv-cache", ".cache", "node_modules",
    ".next", "vendor", "dist", "build", "target",
}
RECURSIVE_SKIP_DIRS = {"__pycache__", ".pytest_cache", "node_modules", "dist", "target"}
SKIP_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".svg", ".mp4", ".mov",
    ".mp3", ".woff", ".woff2", ".ttf", ".otf", ".eot", ".pdf", ".zip", ".tar",
    ".gz", ".bz2", ".7z", ".ckpt", ".bin", ".pyc", ".pyo", ".class", ".o",
    ".so", ".dylib", ".db", ".lock",
}


def iter_text_files(root: pathlib.Path) -> Iterable[pathlib.Path]:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.resolve() == SELF:
            continue
        rel_parts = path.relative_to(root).parts
        if rel_parts and rel_parts[0] in ROOT_SKIP_DIRS:
            continue
        if any(part in RECURSIVE_SKIP_DIRS for part in rel_parts[:-1]):
            continue
        if path.suffix.lower() in SKIP_SUFFIXES:
            continue
        yield path


# --- Detector 1: em dash ---
def find_em_dashes(text: str) -> Sequence[tuple[int, str]]:
    return [(n, line) for n, line in enumerate(text.splitlines(), 1) if EM_DASH in line]


# --- Detector 2: contrastive parallelism ("not just X, but Y" AI tell) ---
# Keep conservative to avoid false positives on ordinary prose.
CONTRASTIVE_PATTERNS = [
    r"\bnot just\b[^.?!\n]*?\bbut\b",
    r"\bnot only\b[^.?!\n]*?\bbut\b",
    r"\bnot merely\b[^.?!\n]*?\bbut\b",
    r"\b(?:isn't|aren't|wasn't) (?:just|only|merely)\b",
    r"\bit's not (?:just|only|about)\b[^.?!\n]*?\bit's\b",
    r"\bmore than just\b",
]
CONTRASTIVE_RE = re.compile("|".join(CONTRASTIVE_PATTERNS), re.IGNORECASE)


def find_contrastive(text: str) -> Sequence[tuple[int, str]]:
    return [(n, line) for n, line in enumerate(text.splitlines(), 1) if CONTRASTIVE_RE.search(line)]


def main() -> int:
    em: list[tuple[pathlib.Path, int, str]] = []
    contrastive: list[tuple[pathlib.Path, int, str]] = []
    for path in iter_text_files(REPO_ROOT):
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        rel = path.relative_to(REPO_ROOT)
        for n, line in find_em_dashes(text):
            em.append((rel, n, line.strip()))
        for n, line in find_contrastive(text):
            contrastive.append((rel, n, line.strip()))

    if em or contrastive:
        if em:
            print(f"AI writing check failed: {EM_DASH!r} (em dash) detected")
            for rel, n, snip in em:
                print(f"{rel}:{n}: {snip}")
        if contrastive:
            print("AI writing check failed: contrastive parallelism ('not just X, but Y') detected")
            for rel, n, snip in contrastive:
                print(f"{rel}:{n}: {snip}")
        print("Remove the flagged construction or explain why it is acceptable.")
        return 1

    print("AI writing check passed (no em dash or contrastive parallelism found).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

```

Notes:

* The script excludes itself (`SELF`) so its own regex strings don't trip it.
* If the target repo has no Python toolchain at all, port this to the repo's scripting language (Node, etc.) — the logic is trivial. Otherwise plain `python3` is fine; it uses only the stdlib.
* Tune `CONTRASTIVE_PATTERNS` against the existing prose so the first run isn't drowned in false positives. If the repo already has many legitimate matches, fix them or start with only the two narrowest patterns.
Add a CI step that runs it (in the repo's existing lint workflow, or a tiny standalone one):

```yaml
      - name: Run AI writing check
        run: python3 scripts/check_ai_writing.py

```

prek wiring (`prek.toml` at repo root)
The size checks are `files`-triggered on source extensions; build the regex from the same `SOURCE_EXTS`. The AI-writing check is `always_run` and scans the whole tree (`pass_filenames = false`). Also pull in upstream `check-added-large-files` for raw byte-size guarding:

```toml
[[repos]]
repo = "https://github.com/pre-commit/pre-commit-hooks"
rev = "v4.6.0"
hooks = [
    { id = "check-added-large-files" },
]

[[repos]]
repo = "local"
hooks = [
    { id = "ai-writing-check", name = "AI writing check", entry = "python3 scripts/check_ai_writing.py", language = "system", pass_filenames = false, always_run = true },
]

# ── Source-size guardrails (mirror GitHub Actions) ────────────────
[[repos]]
repo = "local"

[[repos.hooks]]
id = "check-large-files"
name = "fail if any source file exceeds the line-count error threshold"
language = "system"
entry = "scripts/check_large_files.sh"
# Mirror SOURCE_EXTS — alternation of extensions:
files = "\\.(py|js|jsx|ts|tsx|go|rs|java|kt|rb|php|c|cc|cpp|h|hpp|cs|swift|scala|m|mm)$"

[[repos.hooks]]
id = "check-folder-sizes"
name = "fail if any source folder exceeds the file-count error threshold"
language = "system"
entry = "scripts/check_folder_sizes.sh"
files = "\\.(py|js|jsx|ts|tsx|go|rs|java|kt|rb|php|c|cc|cpp|h|hpp|cs|swift|scala|m|mm)$"

```

Keep the `files = ...` alternation, the CI `paths:`, and `SOURCE_EXTS` in the scripts as the same set of extensions — that's the one thing to keep in sync across the three layers.
Claude Code on the web / cloud wiring (IMPORTANT — don't skip)
So commits made in Claude Code cloud/web sessions run these same prek hooks, add a SessionStart hook. This part is language-independent.
`.claude/settings.json` (merge if it exists):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh" }
        ]
      }
    ]
  }
}

```

`.claude/hooks/session-start.sh` (`chmod +x`):

```bash
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

# Install project dependencies here for whatever stack this repo uses, e.g.:
#   uv sync        (Python/uv)
#   npm ci         (Node)
#   go mod download / cargo fetch / bundle install ...

# Install prek if missing, then wire up the git hooks so cloud commits run them.
# prek is a standalone binary; install via your preferred method:
if ! command -v prek >/dev/null 2>&1; then
  # e.g. `uv tool install prek`, or `pipx install prek`,
  # or the official installer: curl -LsSf https://prek.j178.dev/install.sh | sh
  curl -LsSf https://prek.j178.dev/install.sh | sh
fi
prek install

exit 0

```

Key points:

* The `CLAUDE_CODE_REMOTE == "true"` guard scopes this to web/cloud sessions (locally, contributors run `prek install` themselves).
* `prek install` writes `.git/hooks/pre-commit`, so any commit in the cloud session triggers all the hooks above.
* Persist PATH/tool setup to `$CLAUDE_ENV_FILE`, guarding against duplicate appends since SessionStart fires on every resume.
Verification before you finish

```bash
chmod +x scripts/check_large_files.sh scripts/check_folder_sizes.sh .claude/hooks/session-start.sh
scripts/check_large_files.sh --all      # exits 0 on a clean tree
scripts/check_folder_sizes.sh --all     # exits 0 on a clean tree
python3 scripts/check_ai_writing.py      # exits 0; must not flag its own source
prek run --all-files                     # all hooks discovered and passing

```

Deliverables: `scripts/check_large_files.sh`, `scripts/check_folder_sizes.sh`, `scripts/check_ai_writing.py` (em-dash + contrastive), `prek.toml` hooks, `.github/workflows/large-files.yaml`, `.github/workflows/folder-size.yaml`, AI-writing CI step, `.claude/settings.json` + `.claude/hooks/session-start.sh`. Keep `SOURCE_EXTS` (scripts) ≡ `files=` regex (prek) ≡ `paths:` (CI). Keep the two shell scripts byte-identical between prek and CI — no forked logic.
