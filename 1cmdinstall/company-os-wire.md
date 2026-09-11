You are wiring up the MACHINERY for a "Company Operating System" mono-repo that a
previous session already scaffolded (CLAUDE.md at root, customer/ product/ websites/
gtm/ decks/ cronjob/ context/ and .claude/ dirs). Run in the repo root. Everything
you do MUST be idempotent - safe to re-run, never duplicating a hook, target, or
symlink. Read the existing CLAUDE.md and dir tree first; do not undo prior work.

STEP 1 - ASK ME (one at a time, "not decided yet" -> leave a `# TODO:`, never invent):
- For each stubbed submodule (product/, websites/, any other), the git repo URL.
- Do my product/website submodules need a private-access token in cloud/CI? (y/n)
- Which CI host: GitHub Actions (default), or other?
- Any hard house rules to enforce mechanically (max file length, banned chars in
  CLAUDE.md, "secrets only in .env", context/ write discipline)?

STEP 2 - SUBMODULES. For every URL I gave, replace the stub dir with a real submodule
(`git submodule add <url> <path>`). Leave stubs with an unresolved `# TODO: repo URL`
untouched. If any submodule needs a token, write scripts/setup_cloud_env.sh that
injects it from an env var before `git submodule update --init --recursive`, and
document the failure mode (missing token -> auth error) in root CLAUDE.md.

STEP 3 - DUAL-TOOL MIRROR. So non-Claude agents (e.g. Codex) read the same context,
write scripts/sync.(sh|py) that idempotently creates a sibling `AGENTS.md` symlink ->
CLAUDE.md next to EVERY non-submodule CLAUDE.md, and prunes dangling ones. CLAUDE.md
stays the single source of truth; never hand-edit an AGENTS.md.

STEP 4 - MAKEFILE. Add (or extend) a Makefile with:
- `make sync`  -> runs the sync script.
- `make ci`    -> runs sync in check-mode (fail if it would change anything) + all
                  Step-1 house-rule validators. Write each validator as a small script
                  in scripts/ (or utils/); a rule I marked `# TODO:` becomes a stub
                  validator that no-ops with a `# TODO:` note.

STEP 5 - HOOKS + CI.
- Pre-commit: add a config (pre-commit or prek) that runs `make ci`. Register it in
  the repo; document the one-time install command in root CLAUDE.md.
- CI: if GitHub Actions, add .github/workflows/ci.yml running `make ci` on push/PR.
- Session-start: add a .claude/ hook that runs `git submodule update --init --recursive`
  (and setup_cloud_env.sh if present) so a fresh session/clone is ready.

STEP 6 - FOLD INTO CLAUDE.md. Add a short "## Build & sync" section to root CLAUDE.md:
the submodule rule, `make sync` after editing shared context, `make ci` before commit,
and the one-time hook-install command. Keep it dense.

RULES:
- Idempotent everywhere; re-running changes nothing on a clean repo.
- Don't fabricate URLs, tokens, or rules I didn't give - those stay `# TODO:`.
- Validate by running `make ci` yourself at the end; report pass/fail.
- End by listing every `# TODO:` and every one-time command I must run manually.
