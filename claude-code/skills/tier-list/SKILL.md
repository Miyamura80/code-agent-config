---
name: tier-list
description: Answer in tier list format, ranking things into S/A/B/C/D/F tiers with coloured circle emoji. Use whenever the user says "/tier-list", asks to tier, rank, or grade a set of things, asks "which of these is best", or gives a list and wants it sorted by quality. Also use proactively when an answer is naturally a ranked comparison of 4 or more items (tools, frameworks, restaurants, options, candidates, features), even if the user never says "tier list".
---

# Tier List

Rank the items into tiers. Nothing else.

## Format

```
🔴 **S** — <one-line reason this tier exists>
- **Item** — why it's here

🟠 **A**
- **Item** — why

🟡 **B**
- **Item** — why

🟢 **C**
- **Item** — why

🔵 **D**
- **Item** — why

🟣 **F**
- **Item** — why
```

Note: the dashes above are placeholders for the format. Never use em dashes in the actual output; use a colon or a comma.

## Rules

- One line per item. A short clause of justification, not a paragraph.
- Skip tiers with nothing in them. Don't pad F just to fill it.
- S is scarce. If everything lands in S the ranking says nothing. Two items max in S unless the set is huge.
- Have an opinion. A tier list that hedges is worthless. If two items are genuinely close, split them anyway and say it was close.
- State the axis you're ranking on in one line before the list (speed? value? taste? beginner-friendliness?). If the user didn't say, pick the obvious one and name it.
- No preamble, no summary paragraph after. The list is the answer.
- If the user asks for fewer tiers or different labels, follow them.
- Add one line at the end only if there's a genuine caveat, like a top pick that flips depending on a condition.

## Ground it in real data first

Never rank from memory when the answer depends on something you can go and check. Before writing the list, pull whatever source is actually relevant to what was invoked:

- Deals, contacts, replies, anything waiting on someone: Gmail / inbox tools
- Team chatter, decisions, who is blocked: Slack
- What was actually said in a call: Granola
- Repos, PRs, files, config: read the code, don't guess
- Meetings, availability, what is coming up: Calendar
- Anything public or version-dependent (tools, models, pricing, releases): web search

Use edison-gateway MCPs first where they cover the source.

Rules for this:
- Pick only the sources that matter for this specific list. One or two is normal. Don't sweep every connector.
- If a source contradicts your prior, the source wins.
- If you couldn't check something that would move an item's tier, say so in one line at the end and name the item.
- Ranking public tools, models, or products from memory is a common failure. Those move fast, so search.

## When the set is unrankable

If the items aren't comparable on any single axis, say so in one line, then rank them anyway on the most useful axis available.
