---
name: babysit
description: Monitor a PR on a loop — review AI/human comments, address feedback, and keep the PR clean until it's ready to merge.
user_invocable: true
triggers:
  - /babysit
---

# Babysit PR Skill

Continuously monitors the current PR on a 7-minute loop. Each iteration reviews incoming comments (human and AI), replies with valid/invalid assessments, fixes valid issues, and checks CI — iterating until all comments are addressed and CI passes.

## Prerequisites

- Must be on a branch with an open PR.
- The `/review-comments` skill must be available.
- The `/loop` skill must be available.

## What This Skill Does

Invoke the `/loop` skill with a 7-minute interval that executes the following on each tick:

### Per-Tick Workflow

#### 1. Run `/review-comments`

Execute the `/review-comments` skill against the current PR. This will:
- Fetch all unresolved review comments (human and AI reviewers)
- Read referenced code and assess each comment as valid/invalid
- Fix valid issues inline and commit+push
- Reply to every comment with a validity assessment and resolution status

**Zero tolerance for unresolved comments without a reply.** Every unresolved comment thread must have a reply from us containing:
- **Valid/Invalid** determination
- **Addressed/Planned/Deferred** resolution status (if valid)

If `/review-comments` leaves any comment without a reply, go back and reply to it manually.

#### 2. Check CI Status

After handling review comments, check CI status:

```bash
gh pr checks {PR_NUMBER}
```

If CI is failing, investigate the failures, fix them, commit, and push.

#### 3. Assess Loop Continuation

At the end of each tick, evaluate whether to continue:

- **Continue** if:
  - There are unresolved comments without replies
  - Fixes were just pushed and we're waiting for updated reviews
  - CI is failing and needs fixes
- **Stop** if:
  - All review comments have been replied to
  - AND CI is green

When stopping, send a final summary to the user.

## Loop Configuration

Use the `/loop` skill with a **7-minute interval**:

```
/loop 7m <the per-tick workflow above>
```

## Final Summary (on stop)

Report:
- **Comments**: total processed, valid+fixed, valid+deferred, invalid
- **Commits pushed**: list of commit hashes and messages
- **CI status**: passing/failing
- **PR URL**

## Important Notes

- **Never resolve review threads** — only reply with assessments.
- **Be respectful** in all replies, even when marking comments invalid.
- **Don't over-iterate** — if all comments are addressed and CI is green, stop.
- **Commit discipline** — batch fixes into logical commits, don't create a commit per line change.
