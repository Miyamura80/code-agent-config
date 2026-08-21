---
name: visual-explanation
description: "Answer with inline SVG diagrams instead of walls of text, and render each figure cleanly — the picture carries the answer, the prose is only the caption. Use whenever the user says '/visual-explanation', asks how something works, asks you to explain a concept, system, process, architecture, algorithm, tradeoff or comparison, asks to be shown or walked through something, OR asks you to draw, diagram, visualize, map, or produce a figure/graphic/SVG. Also use proactively any time an explanation would otherwise run to several paragraphs and has structure worth seeing — steps, flows, layers, parts, before and after, options being weighed. Every response must pass the litmus test that a reader who sees only the diagrams and reads none of the text still gets at least 80% of the answer. Do not use for code and debugging, single-fact lookups, drafting prose, or personal conversations."
---

# Visual Explanation

A picture is worth a thousand words, so stop writing the thousand words. **The diagram is the answer, the prose is the caption.** Your instinct is to explain in paragraphs and offer a figure as a bonus. Invert it.

This skill covers both halves of visual work: **deciding the answer should be visual** (and cutting the prose to match), and **rendering each figure cleanly** so it actually lands. Same discipline, two altitudes.

## Read this first: your defaults are miscalibrated for visuals

You are tuned for prose and analysis. There your instincts are virtues: be thorough, preserve information, hedge where uncertain, cover the edge cases. **In visual work every one of those instincts becomes a defect.** A diagram has the opposite objective function from an essay. An essay is judged by what it contains; a diagram is judged by how fast one idea becomes obvious, and every additional true mark on the page competes with that idea for the reader's attention.

So the most important thing this skill does is flip your objective function the moment the task is visual. You are not trying to represent the system. You are trying to make one point land. Most of what you know about the system is, for this purpose, noise. Adopt this before the first shape is drawn — if you draw everything you know and plan to trim later, you have already lost. Start stripped.

### The biases to actively unlearn

Name these to yourself when you start. They are yours, they are strong, and they fire silently.

- **"I know it, so I should show it."** Availability is not relevance. Table names, version numbers, internal paths, exact counts, and "verify against X" caveats are things you happen to know, not things the message needs.
- **Completeness reflex.** Prose rewards covering everything; diagrams punish it. A diagram that shows 60% of the truth clearly beats one that shows 100% illegibly.
- **Additive, local reasoning.** You justify each element on its own merits and never budget the whole composition. Reason about total mark count and global structure, not element by element.
- **Redundant encoding mistaken for clarity.** A box *and* a colour *and* an accent bar *and* a label all saying the same thing is weight, not clarity. One channel per concept.
- **Loss aversion about cutting.** Adding feels safe, removing feels risky — so reverse the default. Removal is the default move; make the case for keeping, not for cutting.

If you notice yourself reframing a request to make more stuff fit, that is the signal to cut, not to cram.

## The litmus test

> Cover the text. If a reader who sees **only** the diagrams cannot reconstruct 80% of the answer, the response failed.

Run it for real before sending: read your own labels, pretend the prose does not exist, and see whether the question and the answer both survive. To pass, the title must state the takeaway as a claim ("Retries triple tail latency", not "Retry behaviour"), every node and edge must be labelled in plain words with nothing keyed to the text below, and the structure itself must carry the point.

### But do not put the wall of text inside the SVG

A dense figure reads as slowly as prose. **Hard cap: eight words per label.** If you cannot hit 80% without paragraphs on the canvas, then either you picked the wrong form, or one figure is carrying two ideas and should be split, or the thing is not visual and should be answered in prose.

## The process — do these in order

Your natural order (content first, structure last, cut never) is what causes the mess. Front-load the discipline.

1. **State the one takeaway, in one sentence.** Before drawing anything, write the single thing a viewer should understand after three seconds. Everything downstream is judged against it; if an element doesn't serve it, it's a candidate for deletion by default.
2. **Build the structural scaffold before any content.** Decide the skeleton first — lanes, columns, rows, grid, or flow axis — with a consistent rhythm (equal spacing, one pitch between steps). Only then place content, and require every piece to snap to the scaffold. *Corollary:* the odd element that doesn't fit the grid gets its own contained sub-area — never let it sprawl across lanes or route its connectors through another element's space.
3. **Place the minimum content, one channel per concept.** Add only what the takeaway needs. For each concept pick exactly one visual channel (colour OR label OR shape OR position — not all four). Run every label through the classifier below first.
4. **Two final checks.** *Legibility at final size:* will the thinnest stroke and smallest label survive at the size this is actually viewed? *Whitespace is acceptable:* empty space separates, calms, and directs the eye — when a cut opens space, leave it or tighten the canvas to it; do not repopulate it.

### Message vs. implementation detail — the classifier

For every piece of text or data, ask: does the *takeaway* need this, or do I just happen to know it? These almost always fail and should be cut by default:

- Internal identifiers: table, function, script, actor, variable names
- Version strings and build/model numbers
- Paths, URLs, cron expressions, config keys
- Provenance and hedging: "reconstructed from…", "verify against…", "approximate", "as of…"
- Exact counts where "several" or the *shape* of the data is the point
- Operation labels the flow already implies (an arrow into a store already says "write")

Keep a term only if removing it makes the takeaway ambiguous or wrong. When unsure, cut it — it is trivial to restore.

## Picking the form

Process → numbered flow. System → boxes, arrows, lanes. Tradeoff → 2×2 or paired bars. Quantity → chart. Hierarchy → tree. Dependencies → graph. Cause/effect or before/after → two panels. Actors over time → sequence or swimlane. Parts of one thing → labelled anatomy with callouts. One axis → spectrum with things placed on it.

If nothing fits, treat that as evidence the answer is not visual.

## Icons and logos: use real SVGs, and stop if you can't find one

A hard rule, not a preference. **Recognition lives in the real mark.** A hand-drawn approximation of a logo, or an emoji standing in for a product, destroys instant recognition and looks amateur.

1. **Search for a real SVG first.** Check `https://eito.me/icons` first, then `https://svgl.app` (its search, or the API at `https://svgl.app/api/svgs`). Prefer these over drawing anything.
2. **Embed the real SVG** — as `<symbol>`/`<use>` or a nested `<svg>` — recolouring to fit the palette but never distorting the mark.
3. **If neither has it, STOP and alarm the user.** Don't silently substitute a hand-drawn shape or emoji. Say: "I couldn't find an SVG for **X** on eito.me/icons or svgl.app — can you provide one, or should I use a labelled placeholder box?" A missing icon is a blocker to surface, not a gap to paper over.

Draw by hand only generic primitives with no brand identity: arrows, plain funnels/filters, document glyphs, simple geometric nodes.

## Build it as a parametric generator, not hand-placed coordinates

If the graphic is non-trivial or will be iterated (it almost always will), generate the SVG from code where layout intent lives in named variables: a base position, a pitch between repeated elements, lane x-coordinates, a per-item render function. This is what makes twenty rounds of "remove this / align that / move it closer" safe — deletions reflow automatically and alignment is enforced by construction. Keep colours, fonts, and spacing as named constants at the top so a palette or scale change is one edit.

## Composing the response

Render real inline SVG through whatever inline path the surface offers. Never describe a diagram you did not draw, never fall back to ASCII art, never write "imagine a diagram where".

Setup line (optional) → diagram → one to three sentences carrying only what the picture cannot (the caveat, the exact number, the recommendation) → next diagram only if there is a genuinely separate second idea. Always interleave; never save the visual for the end.

**Text budget: about a third of what you would otherwise write.** If the prose still works as a complete answer with the diagrams deleted, you decorated instead of distilling. Two or three figures for a layered question; five means you are illustrating sentences rather than finding ideas.

## Default aesthetic

Unless the user specifies otherwise: flat (no gradients/shadows), high contrast, generous whitespace, a tight palette (one or two accent colours plus neutrals) where colour *means* something, one type family, everything on a grid with even spacing. Let structure and alignment carry the design — restraint reads as intentional, ornament reads as noise.

## Iterating with the user

Expect a subtraction-heavy back-and-forth, and get ahead of it. After a first pass, proactively name what you think could still go ("the operation labels and the provenance note both read as implementation detail — want them gone?") rather than waiting to be asked. When you cut something with a side effect (a removed label orphaned an arrow; a removed element opened a gap), say so in one line and offer the fix. Never re-add weight to fill space the user just cleared.

## When not to

Diagram-first, not diagram-always. Plain text wins for code and debugging, single-fact answers, drafting or editing prose, personal conversations, anything explicitly asked for as prose, and judgement calls with no structure to show. Forcing a figure onto these is worse than not drawing.

## Before sending

Diagrams only: did I get 80%? Any label over eight words? Would deleting half the prose make the answer worse? Will the smallest mark survive at final size? If any answer is wrong, fix it before sending.
