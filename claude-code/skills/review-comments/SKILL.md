---
name: review-comments
description: Review unresolved PR comments, reply with valid/invalid assessment, and check CI status
user_invocable: true
triggers:
  - /review-comments
---

# Review PR Comments Skill

Reviews all unresolved review comments on a GitHub PR, reads the relevant code, and replies to each comment explaining whether the feedback is valid or invalid.

## Helper Script

All GitHub API calls MUST go through the helper script at `~/.claude/scripts/review-comments.sh`. This script is pre-approved in the permissions allowlist, so it won't trigger approval prompts.

**CRITICAL rules for calling the script (violating these triggers approval prompts):**
- **Always invoke EXACTLY as shown**: `bash /Users/eito/.claude/scripts/review-comments.sh <subcommand> [args]`
- **Do NOT use `$HOME` or `~`** - use the literal absolute path `/Users/eito/.claude/scripts/review-comments.sh`
- **Do NOT wrap the path in quotes** - the path has no spaces, quotes will break allowlist matching
- **Do NOT call `gh` directly** - always use the script
- **Do NOT pipe the script output** - no `| python`, `| jq`, `| grep`, etc. Piping changes the command and breaks allowlist matching
- **Do NOT append `2>&1` or other redirections** - same reason
- The script's subcommands handle filtering and formatting internally. Parse the JSON output in your reasoning, not via shell pipes
- **The `reply` subcommand reads the body from stdin** - use a heredoc or `echo | bash ...` to pass the body. Do NOT pass the body as a positional argument (it triggers security prompts when the text contains shell-special characters like quotes, `$()`, backticks, etc.)

## Workflow

Execute these steps in order:

### 1. Determine the PR

If an argument was provided (e.g. `/review-comments 284` or `/review-comments https://github.com/org/repo/pull/284`), use that PR number/URL.

Otherwise, detect the PR from the current branch:

```bash
bash /Users/eito/.claude/scripts/review-comments.sh detect-pr
```

If no PR is found, stop and report: "No PR found for the current branch. Pass a PR number as an argument."

Store the PR number as `PR_NUMBER`. Parse the owner and repo from the URL or by running:

```bash
bash /Users/eito/.claude/scripts/review-comments.sh detect-pr
```

Extract `owner` and `repo` from the URL field in the JSON response.

### 2. Get your GitHub login

```bash
bash /Users/eito/.claude/scripts/review-comments.sh detect-pr
```

Parse the current user's login from the PR data, or use `gh api user --jq .login` via the script.

### 3. Fetch and filter unresolved comments

Use the `list-unresolved` subcommand which fetches threads, filters out resolved ones, removes your own comments and noise-bot comments (github-actions, codecov, dependabot), and returns clean JSON. Code-review bots (Sentry, Devin, Qodo, Recurse, Greptile) are kept - their comments are substantive reviews, not noise.

```bash
bash /Users/eito/.claude/scripts/review-comments.sh list-unresolved {owner} {repo} {PR_NUMBER} {your_login}
```

This returns a JSON array where each element has:
- `databaseId` - the comment ID (for replying)
- `path` - the file path
- `line` / `startLine` - line number(s)
- `author` - who wrote the comment
- `body` - the comment text
- `createdAt` - when it was posted
- `threadComments` - full conversation thread for context

Parse this JSON output directly. **Do NOT pipe it through another command.**

### 4. Read relevant code for each comment

For each unresolved comment, read the referenced file and lines to understand the code context. Use the `Read` tool to inspect the file at the path indicated by the comment.

Read enough surrounding context (at least 20 lines around the referenced line) to understand what the reviewer is referring to.

### 5. Check if the issue has been addressed

Before assessing each comment, check the **current state of the code on the branch** (not the diff snapshot from the comment). Compare the code the reviewer commented on against what's in the working tree now:

- Use the `Read` tool to read the current file at the path and lines referenced
- Check for commits after the comment was posted:

```bash
bash /Users/eito/.claude/scripts/review-comments.sh log-since {comment_createdAt}
```

- Look for whether the specific concern has already been resolved in a subsequent commit

Classify each comment's resolution status:
- **Addressed** - the issue raised has already been fixed in a subsequent commit on this branch
- **Not yet addressed** - the issue still exists in the current code
- **Planned** - you can see from context (e.g. TODO comments, related code patterns) that there's an intent to address it but it hasn't been done yet

### 6. Assess each comment

For each unresolved comment, evaluate:

1. **Read the reviewer's feedback carefully** - understand exactly what they're asking for or pointing out
2. **Examine the current code** - look at the referenced lines and surrounding context as they exist now
3. **Determine validity**:
   - **Valid** - the reviewer identified a real issue (bug, style violation, missing edge case, unclear code, performance concern, security issue, etc.)
   - **Invalid** - the reviewer's concern is based on a misunderstanding, is already handled elsewhere, or doesn't apply to this context

### 7. Address valid issues

**If a comment is valid and not yet addressed, fix it immediately.** Do not just reply - actually make the code change.

For each valid + not-yet-addressed comment:

1. **Estimate the scope** of the fix:
   - **Small/medium** (touches existing files, or creates at most 1-2 new files) → **fix it now**. Edit the code, then reply referencing what you changed.
   - **Large** (would require creating 3-4+ new files AND modifying multiple other files) → **defer it**. Append a task entry to `next_task.md` in the repo root describing the issue, the reviewer's comment, the file/line, and what needs to be done. Reply to the comment noting it's been documented for follow-up.

2. After making fixes, **do NOT commit yet** - collect all fixes first, then create a single commit at the end of step 7 (after all comments are processed). Use a commit message like `🐛 Address PR review feedback` that briefly lists what was fixed.

3. After committing, **push to the PR branch automatically** (`git push`). This ensures the reviewer sees the fixes immediately.

4. If you deferred any items to `next_task.md`, mention this in the summary.

### 8. Reply to each comment

For each unresolved comment, post a reply by piping the body via stdin using a heredoc:

```bash
bash /Users/eito/.claude/scripts/review-comments.sh reply {owner} {repo} {PR_NUMBER} {comment_id} <<'REPLY_EOF'
{reply_body}
REPLY_EOF
```

**Why stdin?** Reply bodies often contain backticks, `$(...)`, consecutive quotes, and other shell-special characters (e.g. when discussing awk/sed). Passing these as a positional argument triggers Claude Code's command obfuscation security check. Using a heredoc with single-quoted delimiter (`<<'REPLY_EOF'`) prevents all shell interpretation of the body.

The reply format should include the validity assessment **and** the resolution status:

For **valid + addressed** comments (including ones you just fixed):
```
**Valid** - [concise explanation of why the feedback is correct]

**Status: Addressed** - [reference the fix, e.g. "Fixed in commit abc1234" or "Updated X at line N to handle Y"]
```

For **valid + deferred** comments (too large to fix inline):
```
**Valid** - [concise explanation of why the feedback is correct]

**Status: Deferred** - This requires a larger change. Documented in `next_task.md` for follow-up.
```

For **invalid** comments:
```
**Invalid** - [concise explanation of why this concern doesn't apply, referencing the specific code/context that addresses it]
```

Keep replies concise (2-4 sentences per section). Reference specific line numbers, code, or commit hashes when explaining.

### 9. Check CI / GitHub Actions status

After processing comments, check the CI status for the PR:

```bash
bash /Users/eito/.claude/scripts/review-comments.sh check-ci {owner} {repo} {PR_NUMBER}
```

This returns JSON with all check runs. For each check run, note:
- `status`: `queued`, `in_progress`, or `completed`
- `conclusion`: `success`, `failure`, `cancelled`, `skipped`, `timed_out`, etc. (only present when `status` is `completed`)

Report on CI:
- If all checks pass, report "CI: All checks passing"
- If any checks are failing, report each failing check with its name and link (`html_url`). Read the failure logs if possible to diagnose the issue
- If checks are still in progress, report "CI: N checks in progress"

### 10. Summary

After processing all comments and CI, report:
- **CI status** - passing, failing (with names), or in progress
- Total unresolved comments found
- How many were assessed as valid vs invalid
- How many were fixed in this run, previously addressed, or deferred
- If any items were deferred to `next_task.md`, call that out explicitly
- A brief list of each comment with the file, line, verdict, and resolution status

## Important Notes

- **Never resolve threads** - only reply with the assessment. Let the reviewer or author resolve.
- **Be respectful** - even when marking a comment as invalid, be constructive and explain clearly.
- **When uncertain**, lean toward "Valid" and suggest the author double-check.
- **Skip noise-bot comments** - ignore CI/automation bots (e.g. github-actions, codecov, dependabot). **Do NOT skip code-review bots** like Sentry, Devin, Qodo, Recurse, or Greptile - treat their comments like any human reviewer's.
- If there are no unresolved comments, report "No unresolved review comments found" and stop.
