Task: Implement cross-compatible Claude Code + Codex agent configuration synchronization in THIS repository — TECHNOLOGY-STACK AGNOSTIC

Re-implement the synchronization mechanism described below. First inspect the repository, its agent instructions, scripting conventions, package managers, task runners, CI, and pre-commit configuration. Adapt invocation commands to the repository while preserving the required behavior and sources of truth.

Do not blindly overwrite existing configuration. Merge existing files, preserve unrelated hooks and settings, and follow all applicable AGENTS.md, CLAUDE.md, contribution, formatting, testing, commit, and pull-request instructions.

GOAL

Maintain one authoritative copy of each portable agent configuration while supporting the different discovery locations and formats used by Claude Code and Codex:

Shared skills:

.agents/skills/<name>/SKILL.md

becomes:

.claude/skills/<name> -> ../../.agents/skills/<name>

Claude-only skills:

.claude/skills/<name>/SKILL.md

These remain real directories and are not synchronized into .agents/skills.

Path-scoped rules:

.claude/rules/<name>.md

becomes:

.agents/rules/<name>.md -> ../../.claude/rules/<name>.md

Subagents:

.claude/agents/<name>.md

becomes generated:

.codex/agents/<name>.toml

Repository instructions, recursively:

<any in-scope directory>/CLAUDE.md

becomes:

<same directory>/AGENTS.md -> CLAUDE.md

Enforcement:

Provide an idempotent manual sync command.

Add an always-running prek hook that repairs drift and then fails the commit when repairs were needed.

Add Claude Code SessionStart wiring that installs and enables prek in remote web/cloud sessions.

Use one synchronization utility for the manual command and prek hook. Do not duplicate or fork the synchronization logic.

BEFORE IMPLEMENTING

Read all applicable AGENTS.md and CLAUDE.md files.

Inspect:

.agents/

.claude/

.codex/

existing scripts or tooling directories

prek.toml

.pre-commit-config.yaml, if present

.claude/settings.json, if present

existing Claude SessionStart hooks

Makefile, Justfile, Taskfile, package scripts, or equivalent

CI workflows

Determine the repository’s preferred scripting language:

Prefer a language already required by the repository.

Prefer standard-library or lightweight dependencies.

If no suitable runtime is already present, use a portable implementation that fits the development environment.

Inspect current symlinks and real directories before modifying them.

Preserve unrelated configuration.

If a partial sync mechanism already exists, extend or reconcile it rather than installing a competing mechanism.

CANONICAL LAYOUT AND SOURCES OF TRUTH

Use these ownership rules exactly:

.agents/skills/<name>/SKILL.md is the source of truth for shared skills.

.claude/skills/<name> is a symlink to ../../.agents/skills/<name>.

.claude/skills/<name>/SKILL.md is a real directory for Claude-only skills and is never mirrored into .agents/skills.

.claude/rules/<name>.md is the source of truth for path-scoped rules.

.agents/rules/<name>.md is a symlink to ../../.claude/rules/<name>.md.

.claude/agents/<name>.md is the source of truth for subagents.

.codex/agents/<name>.toml is generated and must never be hand-edited.

<dir>/CLAUDE.md is the source of truth for directory instructions.
<dir>/AGENTS.md is a sibling symlink whose target is CLAUDE.md.
SHARED SKILLS: .agents/skills TO .claude/skills

For every real directory under .agents/skills/<name>:

Require .agents/skills/<name>/SKILL.md.

Validate its YAML frontmatter.

Create this relative symlink:

.claude/skills/<name> -> ../../.agents/skills/<name>

If the correct symlink exists, do nothing.

If a managed symlink has the wrong target, repair it.

If .claude/skills/<name> is a real file or directory, fail with a clear collision error. It may be an intentional Claude-only skill and must not be overwritten.

Remove stale managed .claude/skills/<name> symlinks when the corresponding .agents/skills/<name> source is removed.

Preserve unrelated or user-managed symlinks pointing elsewhere.

If .agents/skills was entirely absent and the sync creates it as an empty directory, do not immediately prune every existing Claude skill symlink. Handle this conservatively.

SHARED-SKILL COMPATIBILITY VALIDATION

A skill under .agents/skills must be portable between Claude and Codex.

Require:

name

description

a plain Markdown body

Validate:

name is nonempty, lowercase-hyphenated where possible, and no more than 64 characters.

description is nonempty and no more than 250 characters.

SKILL.md has valid YAML frontmatter.

Frontmatter is a mapping/object.

Reject Claude-only frontmatter keys in shared skills, including:

allowed-tools

disable-model-invocation

user-invocable

context

agent

model

effort

hooks

paths

shell

argument-hint

Reject active Claude-only body syntax, including:

$ARGUMENTS

positional substitutions such as $1 and $2

${CLAUDE_*} runtime interpolation

backtick-bang shell preprocessing

fenced shell-preprocessing blocks

Avoid false positives when these strings merely appear in ordinary explanatory inline-code or fenced-code examples, except when the fenced syntax itself is the prohibited feature.

If a skill requires Claude-only features, keep it as a real directory at .claude/skills/<name> and do not create the same name under .agents/skills.

RULES: .claude/rules TO .agents/rules

For every non-symlink Markdown file under .claude/rules/<name>.md:

Treat .claude/rules/<name>.md as authoritative.

Create:

.agents/rules/<name>.md -> ../../.claude/rules/<name>.md

If the correct symlink exists, do nothing.

If a managed symlink has the wrong target, repair it.

If .agents/rules/<name>.md is a real file, fail with a clear collision error. Do not silently delete it.

Remove stale .agents/rules/*.md symlinks whose .claude/rules sources were deleted.

Ignore non-Markdown files and source-side symlinks.

Use globs: frontmatter for path scoping unless the installed Claude Code rule format explicitly requires something else.

SUBAGENTS: .claude/agents/.md TO .codex/agents/.toml

Claude and Codex use different subagent formats, so convert rather than symlink.

A Claude source contains YAML frontmatter with fields such as:

name

description

tools

model

color

The Markdown body after the frontmatter is the agent instruction prompt.

Generate a Codex TOML file containing:

name = the Claude frontmatter name

description = the Claude frontmatter description

developer_instructions = the complete Markdown body

Requirements:

.claude/agents/*.md is authoritative.

Parse and validate YAML frontmatter.

Require a nonempty name.

Map:

name to TOML name

description to TOML description

Markdown body to TOML developer_instructions

Serialize valid TOML safely. Do not build unsafe TOML through naive string concatenation.

Preserve Claude-only metadata such as tools, model, and color as generated TOML comments for human reference. State clearly that Codex does not use them.

If tool restrictions or runtime expectations must affect both tools, require them to be described in the Markdown body.

Rewrite a generated TOML only when the desired content differs.

Delete orphaned .codex/agents/.toml files when no corresponding .claude/agents/.md source remains.

Never treat .codex/agents/*.toml as editable source files.

Escape multiline Markdown and quote sequences correctly.

RECURSIVE CLAUDE.md TO AGENTS.md MIRRORING

Recursively discover every in-scope CLAUDE.md in the repository, at the root and in nested directories.

For each directory containing an in-scope real CLAUDE.md:

Create a sibling symlink:

AGENTS.md -> CLAUDE.md

The target must be the simple sibling-relative path CLAUDE.md.

If AGENTS.md is missing, create the symlink.

If AGENTS.md is a real file, treat it as a drifted duplicate and replace it with the symlink so Claude and Codex cannot receive conflicting instructions.

Before replacing a differing real AGENTS.md, preserve any unique user-authored content by merging it into the authoritative CLAUDE.md or otherwise reconciling it safely.

If AGENTS.md is already any symlink, leave it untouched. This includes both the expected managed symlink and a user-managed symlink pointing elsewhere.

If a managed AGENTS.md -> CLAUDE.md symlink exists but the sibling CLAUDE.md was removed, prune the dangling managed symlink.

Do not prune unrelated real AGENTS.md files in directories without CLAUDE.md.

Do not prune custom AGENTS.md symlinks pointing somewhere other than CLAUDE.md.

Handle staged deletions safely.

DISCOVERY SCOPE

Inside a Git worktree, determine recursive instruction candidates using Git’s repository scope, equivalent to this command:

git ls-files -z --cached --others --exclude-standard

This includes tracked files and non-ignored untracked files while excluding:

gitignored content

submodule internals

If Git is unavailable or the directory is not a Git worktree, use a recursive filesystem walk.

During fallback traversal, skip:

hidden directories

.git

node_modules

virtual environments such as .venv and venv

pycache

build outputs such as dist, build, and target

other obvious generated or vendored directories used by the repository

Avoid following skill or rule symlinks in a way that causes traversal loops.

SYNC PROGRAM BEHAVIOR

Create one synchronization utility under the repository’s existing scripts or tooling directory. Do not add a root-level file unless the repository requires it.

The utility must:

Run all four operations:

shared-skill validation and symlink synchronization

rule symlink synchronization

subagent Markdown-to-TOML generation

recursive CLAUDE.md and AGENTS.md synchronization

Be deterministic.

Be idempotent.

Be silent on a clean run, unless repository conventions require a concise success message.

Print one concise line for every created, repaired, regenerated, or pruned path.

Fail clearly on invalid frontmatter, invalid shared skills, unsafe collisions, or serialization errors.

Support a --check option.

The --check option must use pre-commit fixer semantics:

Perform synchronization.

Write required repairs.

Exit nonzero if it made changes.

Print:

sync-agent-config introduced changes; stage them and commit again.

Exit zero when no drift exists.

Do not make --check read-only unless unavoidable repository conventions explicitly require it. Its purpose is to repair drift and block the current commit so the repaired artifacts can be staged.

MANUAL TASK-RUNNER COMMAND

Add an idiomatic manual command using the repository’s existing task runner.

Preferred name:

make sync-agent-config

If the repository does not use Make, add the closest conventional equivalent, such as:

just sync-agent-config

task sync-agent-config

npm run sync-agent-config

bun run sync-agent-config

The task must invoke the same synchronization utility used by prek. Do not duplicate synchronization logic in the task-runner configuration.

PREK CONFIGURATION

Use prek.toml at the repository root. If .pre-commit-config.yaml also exists, establish and document that prek.toml is authoritative instead of maintaining divergent configurations.

Merge an always-running local hook with these values:

id: sync-agent-config

name: sync Claude <-> Codex skills, rules, subagents, and instruction mirrors; fail if drift was fixed

entry: the repository-appropriate command followed by the sync utility and --check

language: system

pass_filenames: false

always_run: true

Possible entries include:

python3 scripts/sync_agent_config.py --check

uv run scripts/sync_agent_config.py --check

node scripts/sync-agent-config.mjs --check

bun scripts/sync-agent-config.ts --check

Choose a runtime already guaranteed by the repository.

Do not remove or replace unrelated prek hooks.

CLAUDE CODE WEB/CLOUD SESSIONSTART WIRING

Ensure commits made in Claude Code web/cloud sessions run prek.

Merge a SessionStart hook into .claude/settings.json without overwriting unrelated settings.

The resulting configuration must register:

Hook event: SessionStart

Matcher: startup|resume

Hook type: command

Command: $CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh

Create or update .claude/hooks/session-start.sh and make it executable.

It must perform this behavior:

Start with:

#!/bin/bash

Enable:

set -euo pipefail

Exit immediately unless:

CLAUDE_CODE_REMOTE == true

Change directory to:

${CLAUDE_PROJECT_DIR:-.}

Add $HOME/.local/bin to PATH.

If CLAUDE_ENV_FILE is set, append this line only when it is not already present:

export PATH="$HOME/.local/bin:$PATH"

Run the repository’s existing dependency or bootstrap command if remote sessions require it, for example:

uv sync

bun install --frozen-lockfile

npm ci

pnpm install --frozen-lockfile

go mod download

cargo fetch

bundle install

Do not introduce an unrelated package manager solely for this hook.

If prek is missing, install it through a trusted method already used by the repository.

Suitable options include:

uv tool install prek

pipx install prek

the official prek installer at https://prek.j178.dev/install.sh

Always run:

prek install

Preserve pre-existing SessionStart responsibilities.

Important SessionStart requirements:

Keep the CLAUDE_CODE_REMOTE == true guard unless the repository explicitly wants local execution too.

Use CLAUDE_PROJECT_DIR to enter the repository.

Persist PATH setup through CLAUDE_ENV_FILE.

Prevent duplicate PATH entries because SessionStart also runs on resume.

Install prek only if it is missing.

Always run prek install.

Do not assume the repository’s implementation language determines how prek must be installed. Prek is a standalone hook manager.

Do not download or execute an installer from an unofficial source.

DOCUMENTATION

Add concise documentation to an appropriate existing contributor or agent-configuration document. Do not create a redundant root document if a suitable document exists.

Document:

The canonical layout.

The authoritative side for each category.

Why skills and rules use symlinks while subagents use conversion.

Shared-skill portability restrictions.

The manual synchronization command.

That generated .codex/agents/*.toml files must not be edited manually.

Recursive CLAUDE.md to AGENTS.md behavior.

Gitignored and submodule exclusions.

Automatic pruning after rename or deletion.

The --check repair-then-fail behavior.

The need to stage generated files and symlinks.

That Claude-only skills remain real directories under .claude/skills.

If the repository has a root CLAUDE.md, add a short operational note explaining:

Run the sync command after changing .agents/skills, .claude/skills, .claude/rules, .claude/agents, .codex/agents, or any CLAUDE.md.

Edit sources of truth, never generated mirrors.

The prek hook enforces synchronization.

TESTS

Add automated tests using temporary directories or an injectable repository root. Tests must not mutate the actual checkout.

Cover at least the following.

Shared skills:

Creates a missing Claude skill symlink.

A clean rerun is idempotent.

Repairs a managed wrong-target skill symlink.

Rejects a collision with a real Claude-only skill directory.

Rejects missing or invalid frontmatter.

Rejects Claude-only keys and active substitutions.

Avoids obvious false positives in explanatory code samples.

Prunes stale managed skill symlinks.

Preserves unrelated user-managed symlinks.

Does not mass-prune if the shared-skills directory was unexpectedly absent.

Rules:

Creates a rule mirror symlink.

A clean rerun is idempotent.

Rejects collision with a real .agents/rules file.

Prunes stale rule symlinks.

Ignores source-side symlinks and non-Markdown files.

Subagents:

Converts YAML frontmatter and Markdown body to valid TOML.

Preserves Claude-only metadata as comments.

Handles multiline content and quoting safely.

Rewrites only when content differs.

Prunes orphaned generated TOML.

Rejects invalid or missing required metadata.

Recursive instructions:

Creates root AGENTS.md -> CLAUDE.md.

Creates nested mirrors.

Replaces a real drifted AGENTS.md after preserving unique content.

Leaves an existing custom symlink untouched.

Prunes only managed dangling AGENTS.md -> CLAUDE.md symlinks.

Preserves unrelated real AGENTS.md files.

Excludes gitignored paths and submodule contents.

Makes fallback traversal skip hidden, vendored, and generated directories.

Check mode:

Exits zero on a clean tree.

Writes repairs and exits nonzero when drift exists.

Exits zero on the next run after repairs.

If the repository has no utility-script testing framework, use the selected runtime’s standard library instead of introducing a large dependency solely for these tests.

OPTIONAL COMPATIBILITY FIXES

Inspect existing agent files for conflicts with the new ownership rules.

Safely reconcile:

Duplicated real AGENTS.md files beside CLAUDE.md.

Hand-edited .codex/agents/*.toml files that differ from Claude sources.

Shared skills containing Claude-only syntax.

Same-name collisions between portable and Claude-only skills.

Stale symlinks.

Orphaned generated files.

Do not silently discard unique user-authored content. Report all reconciliation in the final summary.

DO NOT SYNCHRONIZE UNRELATED SYSTEMS

Unless the repository explicitly documents otherwise, do not mirror:

.codex/rules/*.rules, which may be a separate permission-policy DSL

.claude/commands/*.md

Claude settings into Codex configuration

Tool-specific permission policies with no equivalent semantics

VERIFICATION BEFORE FINISHING

Run the repository-equivalent forms of:

Normal sync:

make sync-agent-config

A second normal sync to prove idempotence:

make sync-agent-config

Clean check mode:

<runtime command> <sync utility> --check

Install Git hooks:

prek install

Run all hooks:

prek run --all-files

Run focused sync tests:

<repository test command for the new tests>
Run the repository’s complete required CI, lint, and test command:

<repository CI command>
Programmatically verify:

Every .agents/skills/<name> has the correct .claude/skills/<name> symlink unless an intentional collision was reported.

Every real .claude/rules/.md has the correct .agents/rules/.md symlink.

Every .claude/agents/.md has a matching generated .codex/agents/.toml.

No orphaned generated .codex/agents/*.toml files remain.

Every Git-scoped CLAUDE.md has a sibling AGENTS.md symlink unless a custom existing symlink was intentionally preserved.

The second sync produces no changes.

git diff --check passes.

Directly executable shell scripts have executable permissions.

If network access prevents installing prek, do not report a false success. Complete all possible offline verification and report the exact environmental limitation.

DELIVERABLES

Provide repository-appropriate equivalents of:

One synchronization utility under the existing scripts/tooling directory.

Focused automated tests.

.agents/skills as the shared-skill source.

Generated .claude/skills symlinks.

.claude/rules as the rule source.

Generated .agents/rules symlinks.

.claude/agents Markdown sources.

Generated and committed .codex/agents TOML files.

Recursive AGENTS.md -> CLAUDE.md symlinks.

A sync-agent-config task-runner command.

An always-running prek drift-repair hook.

Merged .claude/settings.json SessionStart wiring.

Executable .claude/hooks/session-start.sh.

Concise contributor or agent documentation.

FINAL RESPONSE

Summarize:

Sources of truth.

Every file created or modified.

Existing configuration merged or preserved.

Any content reconciled before replacing duplicate instruction files.

Exact verification commands and whether each passed.

Network or environmental limitations.

Whether the final sync was idempotent.

Whether prek was installed and all hooks passed.

Do not claim completion until synchronization is idempotent, generated artifacts are current, tests pass, and all repository-required checks pass. If the repository requires commits, branches, or pull requests, follow its local instructions.
