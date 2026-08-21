---
name: pros-and-cons
description: Weigh design decisions as a compact pros/cons table and end with one committed recommendation. Use whenever the user says "/pros-and-cons", asks to weigh options, compare approaches, evaluate tradeoffs, or asks "should I do X or Y". Also use proactively whenever the answer is a choice between 2 to 5 designs, architectures, schemas, tools, libraries, vendors, or plans, even if the user never says "pros and cons". Do not use for single-option questions, pure factual lookups, or ranking many items by quality.
---

# Pros and Cons

One table. One recommendation. No preamble, no summary after.

Header lines first: `Decision:` then `Axis:`. Columns in order: Option, Pros, Cons, Best when. Recommendation last, bolded, option name as first word.

## Example

**Decision:** session storage for the gateway
**Axis:** ops burden at current team size

| Option | Pros | Cons | Best when |
|---|---|---|---|
| **Postgres table** | already deployed; transactional; trivial to debug | row churn; vacuum tuning; ~8ms reads | traffic flat, team small |
| **Redis** | ~0.4ms reads; TTL built in | new dependency; persistence config; loss on failover | read-heavy, sessions disposable |
| **Signed cookie** | zero infra; scales free | 4KB cap; no revocation | sessions tiny, revocation unneeded |

**Recommend: Postgres table.** Ops burden dominates at 3 engineers, and Redis buys 7ms nobody asked for. Flip to Redis past ~5k reads/s.

Note: dashes are format placeholders. Never em dashes in output. Semicolon or comma.

## Rules

- 2 to 5 options. 2 to 4 pros, 2 to 4 cons each
- Cells: fragments, not sentences
- Every option gets real cons. Zero cons = strawman
- Symmetric axes: cite latency for A, cite latency for B. Different axis per row fakes balance
- Name axis before table. User never said, pick obvious one, name it
- Numbers exact, unit attached. Never round for snappiness
- Latency, price, headcount, token cost: inline canvas
- Kill generic virtues: scalable, flexible, modern
- Kill hedges: arguably, generally, broadly

## Recommendation

- Reason ties to stated axis, not generic virtue
- Reversibility counts: cheap-to-undo beats better-but-locked-in
- Hard constraint decides it, name constraint
- Close call: say close, name the flip condition
- "Depends" not an answer. Pick, then state the dependency
- User already leaning: still say what you think

## Ground it first

- Read the source, never recall it: repo, config, versions, pricing, prior decisions
- edison-gateway MCPs first
- Unverified thing that would move a row: one line at end, name it

## Not this skill

- 4+ items ranked by quality: tier-list
- Prose going to another human: write it normally
