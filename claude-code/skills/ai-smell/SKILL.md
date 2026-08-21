---
name: ai-smell
description: Detect and cut "AI smell" - phrasing that reads as LLM-generated. Covers contrastive "X, not Y" antithesis, self-labeled honesty ("honest", "transparent", "to be clear"), hollow meaning-free emphasis, casual glosses where a precise term exists, robotic caveat-lists, adjective doublets, and superlative marketing. Use on /ai-smell, when reviewing or rewriting prose, or when asked to make text sound less like AI / a chatbot / ChatGPT.
---

# AI Smell

A concrete reference for the phrasing that betrays LLM authorship. When reviewing or rewriting, scan for these tells, quote the offending span, and give a cut or rewrite tied to the named tell. Bias hard toward cutting: most AI smell is deleted, not reworded.

Every before/after below is a real edit from the Sealgate HN launch post, where a human reviewer kept flagging text as "reads super LLM."

## The tells

### 1. Contrastive parallelism ("X, not Y")
The antithesis reflex: assert a thing by negating its opposite. Two parallel clauses hinged on `not` / `isn't` / `rather than` / `instead of`. The single most reliable AI tell.

- "it checks who is calling, **not** what is in the model's context" -> "it gates on caller identity, blind to the model's context"
- "Deterministic policy, **not** an LLM judging each call" -> cut entirely
- "**Not** theoretical, we keep landing it on real products" -> "We keep landing it on real products"

Also catches the inverted forms: "It's not about A, it's about B", "less A, more B", "we don't just X, we Y".

### 2. Hollow emphasis (sounds authoritative, says nothing)
A sentence that feels like a strong point but carries near-zero information.

- "Deterministic policy, not an LLM judging each call." -> delete

Test: delete the sentence. If the meaning survives, it was filler wearing a confident tone.

### 3. Self-labeled virtue ("honest", "transparent", "genuinely", "to be clear")
Announcing the tone instead of just having it. Humans rarely preface their own honesty; LLMs do constantly.

- "**Honest** scope:" -> "Scope:"
- "**Honest** feedback welcome" -> "Feedback welcome"

### 4. Casual gloss instead of the precise term
An explanatory paraphrase in parens where a real technical word exists. Reads as if the writer doesn't trust the reader (or doesn't know the word).

- "(monotonic, **can't be reset**)" -> "(immutable and monotonic)"

Prefer the load-bearing technical adjective over its plain-language explanation.

### 5. Robotic caveat-list
Flat, semicolon-chained disclaimers stacked in one breath. Technically complete, unmistakably machine.

- "Scope: MCP connector boundary only, raw CLI aren't covered; local servers run unsandboxed today; false positives still happen."
- -> "Today we're only securing the MCP connection layer. Sandboxing for shell-execution agents and local servers is on our roadmap. Our classification is configurable but conservative, and will produce false positives."

Turn the list into sentences a person would actually say.

### 6. Stiff reframe that a person would say casually
Same content, but the AI version is starched.

- "Not theoretical, we keep landing it on real, shipping products:" -> "Oh, and for reference, these are examples of attacks Sealgate would have prevented:"

### 7. Adjective doublets / paired synonyms
Two words doing one word's job. Keep the one that carries weight.

- "real, **shipping** products" -> "shipping products"
- "most **powerful & comprehensive**" -> pick one, or better, cut both (see 8)

### 8. Superlative marketing
Unearned "most / best / leading / seamless / powerful". Reads as a pitch deck, not a person.

- "the most powerful & comprehensive MCP gateway" -> name the specific capability instead

### 9. Needless appositive comma before a trailing modifier
A comma that sets off a tacked-on qualifier the sentence doesn't need.

- "It matches on the tool call and its parameters, finer than a coarse network egress allowlist." -> "It matches on the tool call and its parameters at a finer grain than a network egress allowlist."

## How to run it

1. Read the target text once, flagging spans that match a tell above.
2. For each: quote the span, name the tell (e.g. "contrastive parallelism"), give the concrete fix.
3. Default to cutting. Rewrite only when the point is load-bearing.
4. Re-scan after edits: fixing one tell often exposes another (a deleted "not X" can leave a dangling clause).
