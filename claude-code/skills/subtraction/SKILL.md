---
name: subtraction
description: "Present information as a layered visual artifact instead of a wall of text: icons and visual structure carry the surface, and the detail lives behind expandable sections and tooltips the reader opens only if they want it. Use whenever the user says '/subtraction', or asks to organise, structure, tidy, lay out, condense, or 'make sense of' a body of information, notes, research, options, status, findings or documentation. Also use proactively whenever an answer would otherwise be a long list, a dense table, many sections of prose, or a dump of everything you know when the reader needs only a small part of it right now. Do not use for code and debugging, single-fact answers, or prose the user will paste somewhere else such as emails, posts and documents."
---

# Subtraction

Most answers fail by addition. Everything the reader might want ends up on the page at once, so the thing they actually want is buried in the middle of it.

Subtraction is the fix, and it is not summarising. **Nothing is deleted, it is demoted.** The full detail is still there, one click away, in a layer the reader chooses to enter. What changes is only what is visible before they choose.

## The three layers

| Layer | Reader spends | Carries |
|---|---|---|
| **Glance** | 2 seconds | Icons, colour, counts, shape. What kind of thing this is and how much of it there is |
| **Scan** | 15 seconds | One short label per item, six words or fewer. Enough to pick the one that matters |
| **Dig** | as long as they want | The full text, the caveats, the workings, the sources. Hidden until opened |

Almost everything you were about to write belongs in Dig. The work of this skill is deciding the tiny amount that does not.

## The litmus test

> A reader who opens **nothing** should be able to say what this is, how many parts it has, and which part they need.

If they have to open things to find out what is worth opening, the surface failed. Run this for real before sending: look only at the collapsed state and try to make a decision from it.

## Icons carry meaning or they do not appear

An icon is a word you do not have to read, which is the whole point, so it has to actually replace a word.

- One vocabulary per artifact, one meaning per icon, held consistently top to bottom. The same mark cannot mean "done" in one section and "shipped" in another.
- If you cannot say in one word what an icon means, it is decoration. Cut it.
- Status, category, direction, risk and type are what icons are for. Prose is not.
- Never make an icon the only carrier of something load-bearing. Pair it with a label or an accessible title, since a reader who does not share your reading of the glyph should not be locked out.
- Emoji need no dependency and render everywhere, so they are the default. For serious material prefer the geometric and monochrome ones over the cartoon faces. Inline SVG when a specific mark is needed. Lucide only inside React.

Colour is a second silent channel, so use it the same way: meaningful, consistent, and never the only signal.

## What may be hidden, and what may never be

Hide: reasoning, evidence, quotes, methodology, full descriptions, alternatives considered, raw numbers behind a chart, anything the reader would want only after they already care.

Never hide: the answer, the recommendation, the deadline, the number they asked for, a warning, a cost, or anything that changes what they do next. Hiding those is not subtraction, it is a puzzle. If a section has exactly one thing in it and that thing is the point, leave it open.

Also leave it open when the whole item is shorter than its own summary line, or when there are fewer than three items. A stack of chevrons hiding one sentence each is more work to read than the sentences.

## Summaries must be honest

The collapsed label is a promise about what is inside, and it is the only thing the reader has to go on.

- "Read more", "Details", "Click to expand": failures. They tell the reader nothing.
- "Three blockers, all in the auth migration": correct. The reader can now decide not to open it.
- Put the payload in the summary and the workings inside. Number first where there is a number.

## Mechanism

Tap is primary, hover is a bonus. Half of readers are on a phone with no cursor, so anything reachable only by hover is invisible to them.

- `<details>` and `<summary>` are the default: native, keyboard accessible, no JavaScript, and they survive being saved or printed.
- Tooltips are for a single short fact, a definition or an exact number, never a paragraph. Build them so a tap opens them too, not only a hover.
- Nested disclosure two levels deep at most. Deeper and the reader loses the thread of where they are.
- Give expanding elements an obvious affordance, a chevron that rotates, a cursor change, a hover tint. A collapsible section nobody realises is collapsible has simply lost its content.
- Keep the open and closed states from jumping the layout around more than they must.

## Craft

Render a real interactive artifact through whatever inline path the surface offers, and load the relevant read_me module for the surface first so the CSS variables, sizing and constraints are right rather than guessed. Never describe an interface you did not build, and never fake collapsing with markdown headings.

Flat. One accent colour plus neutrals. One type family. Everything on a grid, since alignment does more for scannability than styling does. Whitespace stays open after the cut instead of being refilled. Where the content is numbers, prefer the shape first, a bar or a sparkline or a chart, with the exact figures in the layer underneath.

## Ground it in real data first

Never lay out information you have not checked when it is checkable. Pull the source that actually matters for what was asked: inbox tools for mail and threads, Slack for team decisions, Granola for what was said on a call, the repo for anything about the code, Calendar for what is coming up, web search for anything public or version dependent. Use edison-gateway MCPs first where they cover the source. One or two sources is normal, do not sweep every connector.

## When not to

Hidden text cannot be searched with ctrl-F, cannot be copied in one go, and does not survive being pasted elsewhere. So this is the wrong shape for: reference material people will search, prose the user will send or publish, code and debugging, a single fact, anything under a couple of paragraphs, and anything explicitly asked for as plain text. Forcing the layers onto those makes the answer worse, not tidier.

## Before sending

Collapsed only: can I make a decision? Is anything load-bearing hidden? Does every icon mean exactly one thing? Does any summary say "read more"? Can everything be reached by tapping? Would the reader have got here faster with a paragraph?
