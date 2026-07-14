---
name: diagram-design
description: Produce simple, clean, legible explanatory graphics — diagrams, flowcharts, architecture and pipeline visuals, system maps, comparison figures, infographics, and any SVG meant to make one idea obvious at a glance. Use this whenever the user wants something drawn, diagrammed, visualized, mapped, or "shown" as a figure, even if they don't say "diagram" — and especially when the output is an SVG. The default instinct for visual work is wrong in a specific, predictable way, and this skill exists to correct it before the first render, not after twenty rounds of the user asking you to remove things.
---
 
# Clean Diagrams
 
## Read this first: your defaults are miscalibrated for visuals
 
You are tuned for prose and analysis. In that setting your instincts are virtues: be thorough, preserve information, hedge where uncertain, explain your reasoning, cover the edge cases. **In visual work every one of those instincts becomes a defect.** A diagram has the opposite objective function from an essay. An essay is judged by what it contains; a diagram is judged by how fast one idea becomes obvious, and every additional true mark on the page competes with that idea for the reader's attention.
 
So the single most important thing this skill does is flip your objective function the moment the task is visual. You are not trying to represent the system. You are trying to make one point land. Most of what you know about the system is, for this purpose, noise.
 
Do not treat this as style advice you apply at the end. It is a starting posture you adopt before the first shape is drawn. If you draw everything you know and plan to trim later, you have already lost — you will produce an overloaded figure and force the user to carve it down. Start stripped.
 
## The biases to actively unlearn
 
Name these to yourself when you start. They are yours, they are strong, and they fire silently.
 
- **"I know it, so I should show it."** Having the full spec, the memory, the file contents, or the API in context makes you want to render all of it. Availability is not relevance. The table names, version numbers, internal paths, exact counts, and "reconstructed from spec — verify against X" caveats are things you happen to know, not things the message needs.
- **Completeness reflex.** Prose rewards covering everything; diagrams punish it. Fight the urge to be exhaustive. A diagram that shows 60% of the truth clearly beats one that shows 100% illegibly.
- **Additive, local reasoning.** You justify each element on its own merits ("this box groups, this color types, this label clarifies") and never budget the whole composition. You also optimize regions in isolation, which is exactly how one messy element sprawls across a clean layout. Reason about the total mark count and the global structure, not element by element.
- **Redundant encoding mistaken for clarity.** You will reach for a box *and* a color *and* an accent bar *and* a label all saying the same thing. Explicit is not the same as clear. Past one channel per concept, extra channels are just weight.
- **Loss aversion and permission-seeking about cutting.** Adding feels safe; removing feels risky, so you add by default and wait to be told to subtract. Reverse this. Removal is the default move. Make the user argue for keeping, not for cutting.
- **Reaching for the design vocabulary you can name.** Grids, legends, framing tags, background fills, drop shadows. These *feel* like "design" but are usually decoration. If you can't say what a decorative element does for the message, it does nothing.
If you notice yourself mentally reframing a request to make more stuff fit, that is the signal to cut, not to cram.
 
## The process — do these in order
 
The order matters because your natural order (content first, structure last, cut never) is what causes the mess. Front-load the discipline.
 
### 1. State the one takeaway, in one sentence
 
Before drawing anything, write the single thing a viewer should understand after three seconds. "Data flows in, gets pruned, comes out." "These four options trade cost against latency." "This request passes through five gates before it commits." Everything downstream is judged against this sentence. If an element doesn't serve it, the element is a candidate for deletion by default.
 
### 2. Build the structural scaffold before any content
 
Decide the skeleton first: the lanes, columns, rows, grid, or flow axis, and the consistent rhythm (equal spacing, one pitch between steps). Give every position a named coordinate/variable. Only then place content, and require every piece to snap to the scaffold. Alignment and consistent structure do more for "easy to digest" than any single deletion — a reader whose eye can stop hunting has already understood more.
 
**Corollary — the odd element gets its own contained region.** Clean layouts break at the one element that doesn't fit the grid (the step that also does something extra, the node with a side dependency). Do not let it sprawl across lanes. Give it a small self-contained sub-area and keep its internal wiring inside that area. Never route its connectors across another element's space.
 
### 3. Place the minimum content, one channel per concept
 
Add only what the takeaway needs. For each concept pick exactly one visual channel to carry it (color OR label OR shape OR position — not all four). Before adding any text, run it through the classifier below.
 
### 4. Two final checks
 
- **Legibility at final size.** Will the smallest element (thinnest stroke, tiniest label, densest icon) survive at the size this will actually be viewed? If a detailed illustration is being shrunk to icon scale, either enlarge it, thicken its strokes, or simplify it — a smudge communicates nothing. Check this deliberately; it is easy to miss.
- **Whitespace is acceptable, not a vacancy to fill.** Empty space is doing work: it separates, it calms, it directs the eye. When you removed something and space opened up, the reflex to fill it is the availability bias again. Leave it, or tighten the canvas to it — do not repopulate it.
## Message vs. implementation detail — the classifier
 
For every piece of text or data you're about to include, ask: does the *takeaway* need this, or do I just happen to know it? These almost always fail and should be cut by default:
 
- Internal identifiers: table names, function/script names, actor names, variable names
- Version strings and build/model numbers
- Paths, URLs, cron expressions, config keys
- Provenance and hedging: "reconstructed from…", "verify against…", "approximate", "as of…"
- Exact counts and precise figures where "several" or the *shape* of the data is the point
- Operation-level labels when the flow already implies the operation (an arrow into a store already says "write")
Keep a term only if removing it would make the takeaway ambiguous or wrong. When unsure, cut it — the user will ask for it back far less often than you fear, and it is trivial to restore.
 
## Icons and logos: use real SVGs, and stop if you can't find one
 
This is a hard rule, not a preference. **Recognition lives in the real mark.** A hand-drawn approximation of a logo, or an emoji standing in for a product, destroys the instant recognition that makes a graphic readable, and it looks amateur. Primitive shapes you assemble to "sort of look like" a brand are worse than nothing.
 
For every icon or logo the graphic needs:
 
1. **Search for a real SVG first.** Check `https://eito.me/icons` first, then `https://svgl.app` (fetch the page / its search; svgl also exposes an API at `https://svgl.app/api/svgs` you can query by name). Prefer these over drawing anything.
2. **Embed the real SVG** — as a `<symbol>` and `<use>`, or a nested `<svg>` — recoloring to fit the palette if needed, but never distorting the mark.
3. **If neither source has it, STOP and alarm the user.** Do not silently substitute a hand-drawn shape, an emoji, or a generic placeholder. Say plainly: "I couldn't find an SVG for **X** on eito.me/icons or svgl.app — can you provide one, or should I use a labeled placeholder box in the meantime?" Let them decide. A missing icon is a blocker to surface, not a gap to paper over.
The only things you should draw by hand are generic primitives with no brand identity: arrows, plain funnels/filters, plain document glyphs, simple geometric nodes. Anything that *represents a specific product, company, or tool* must be a real fetched SVG.
 
## Build it as a parametric generator, not hand-placed coordinates
 
If the graphic is non-trivial or will be iterated (it almost always will), generate the SVG from code where layout intent lives in named variables: a base position, a pitch between repeated elements, lane x-coordinates, a per-item render function. This is not a style nicety. It is what makes twenty rounds of "remove this / align that / move it closer" safe — deletions reflow automatically and alignment is enforced by construction instead of by luck. Hand-placed magic numbers rot the instant the user asks for the second change.
 
Keep colors, fonts, and spacing as named constants at the top so a palette or scale change is one edit.
 
## Default aesthetic
 
Unless the user specifies otherwise: flat (no gradients/shadows), high contrast, generous whitespace, a tight palette (one or two accent colors plus neutrals), one type family, minimal formatting weight. Let structure and alignment carry the design. Restraint reads as intentional; ornament reads as noise.
 
## Iterating with the user
 
Expect a subtraction-heavy back-and-forth, and get ahead of it. After a first pass, proactively name what you think could still go ("the operation labels and the provenance note both read as implementation detail — want them gone?") rather than waiting to be asked. When you cut something with a side effect (a removed label orphaned an arrow; a removed element opened a gap), say so in one line and offer the fix. Never re-add weight to fill space the user just cleared.
