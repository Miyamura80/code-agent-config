---
name: scrutinizer
description: Review prose the way one specific human persona reads it - sentence by sentence, each reaction from a fresh-context subagent so no single reader smooths over weak writing with hindsight. Every reader is also persona-invariantly allergic to AI smell (LLM-generated phrasing). Requires a persona.
argument-hint: <persona idea> - then paste or point at the text to review
---

# Scrutinizer

Review prose by simulating how one specific human reads it - **one sentence at a time**, with each in-the-moment reaction produced by a **fresh subagent** that has only seen the text up to that point. A single reader who sees the whole piece unconsciously forgives early confusion because it knows where things are going. Fresh per-sentence readers can't cheat: they react only to what a real reader knows so far. That trace is what makes writing tighter.

Arguments passed on invocation: `$ARGUMENTS`

## Hard requirement: persona is mandatory

**You cannot run Scrutinizer without a persona.** The reaction of "a skeptical CISO scanning on their phone" is nothing like "a curious ML researcher." The whole method is persona-relative.

If the user did not supply even a rough persona idea, **stop and ask for one** before doing anything else. Do not invent a persona unprompted and do not proceed.

### Persona elaboration (do this before the algorithm)

The algorithm is deliberately token-hungry (see *Cost* below), so it is worth getting the reader right before spending on it.

1. Take the user's rough idea (e.g. "a CISO who's seen 50 vendor pitches").
2. Expand it into a concrete reader prompt: their role, what they already know, what they're skeptical of, why they're reading, how much patience they have, what would make them stop reading.
3. **Show the expanded persona to the user and confirm it's accurate** before spawning any subagents. Adjust until they approve. Only then start.

## Inputs

- `text` - the prose to review. Prefer a bounded passage (a paragraph, a section, an email) over a whole document.
- `persona` (p) - the confirmed reader prompt from the step above.

## The algorithm

Let the text be sentences `s1, s2, ..., sk`. Compute reactions `f1, ..., fk` **sequentially** - each reaction depends on the ones before it, so this cannot be parallelized:

```
segment text -> [s1, s2, ..., sk]
feedbacks = []
for i in 1..k:
    prefix_i = s1 || s2 || ... || si         # cumulative text through sentence i
    fi = subagent(
        persona      = p,
        story_so_far = prefix_i,             # everything read up to and including si
        new_sentence = si,                   # the sentence to react to now
        prior_reactions = feedbacks,         # f1 ... f_(i-1): the reader's running trail
    )
    feedbacks.append(fi)
```

```
   s1 ------------> [fresh reader p]            --> f1
   s1 s2 ---------> [fresh reader p | f1]       --> f2
   s1 s2 s3 ------> [fresh reader p | f1 f2]    --> f3
   ...
   s1 ... sk -----> [fresh reader p | f1..f(k-1)] --> fk
```

Each `subagent(...)` is a **new Task subagent with fresh context** (use the `Task` tool, `general-purpose` type; the reader only reasons and returns text - it needs no other tools). It must react **only** as someone who has read up to `si` and knows nothing about what comes next - no anticipating or excusing later sentences. Passing `prior_reactions` gives continuity (the reader's mounting confusion, interest, or boredom) without any single context ever seeing the whole piece.

### What each reader reacts to

Prompt the subagent to answer, in the persona's voice, for the newest sentence:

- **Am I still following, or did this lose me?** Would this persona actually track the sentence, or be confused?
- **Do I care about this?** Or is it irrelevant, or too much information / detail? Strong tells:
  - unnecessary numbers, dates, or precision the reader doesn't need
  - detail that serves the writer, not the reader
- **Have I read this already?** Redundant with an earlier sentence.
- **Do I understand the words?** Jargon this persona wouldn't know.
- **Is this claim earning my trust,** or is it hype / a claim with nothing behind it?
- **Did this raise a question** I now expect answered soon?
- **Does this smell like AI?** *(persona-invariant - applies no matter who the reader is; see below)*
- **Am I about to stop reading?** The bounce point matters most.

### AI-smell allergy (applies to every persona)

Overlay this on **every** reader, whatever their role: they have spent the last year drowning in LLM output and now flinch at machine phrasing. AI smell is a **trust hit, not a comprehension problem** - a sentence can be perfectly clear and still make the reader trust the writer less because it reads generated. So when a reader spots a tell: flag `ai-smell`, cap `{status}` at ⚠️ for that sentence (a smelly sentence is never a clean ✅), and let repeated hits push `{heat}` toward a bounce.

The tells (one-liners; full catalogue with before/after fixes lives in the `ai-smell` skill). **The orchestrator MUST paste this list into every reader subagent prompt** so the fresh context knows what to sniff for:

1. **Contrastive parallelism** - the antithesis reflex: assert a claim by pairing it against its negation across two clauses hinged on a negation word (`isn't` / `rather than` / `instead of`), plus the inverted and "less/more" variants. The single most reliable tell. (Full literal patterns in the `ai-smell` skill.)
2. **Hollow emphasis** - an authoritative-sounding sentence that says nothing; delete it and the meaning survives.
3. **Self-labeled virtue** - "honest", "transparent", "genuinely", "to be clear": announcing a tone instead of just having it.
4. **Casual gloss for a precise term** - a plain-language paraphrase in parens where a real technical word exists.
5. **Robotic caveat-list** - flat, semicolon-chained disclaimers stacked in one breath.
6. **Stiff reframe** - starched phrasing where a person would say the same thing casually.
7. **Adjective doublets** - paired synonyms doing one word's job ("real, shipping products").
8. **Superlative marketing** - unearned "most / best / leading / seamless / powerful".
9. **Needless appositive comma** before a tacked-on trailing modifier.
10. **Demonstrative cleft kicker** - "That's the ___ that ___" (and "This is / It's the ___ that ___", "That's what ___ does"): a demonstrative fronting a hollow one-line mic-drop. State the buried claim plainly or cut. (Full patterns in the `ai-smell` skill.)
11. **Personal-discovery superlative** - "the best / clearest / sharpest ___ I've seen / found (on here / in a while)": flattery dressed as spontaneous personal discovery, endemic to AI outreach and comment openers. The superlative is unearned and reads as a template compliment. Cut the ranking; make any real compliment specific. (Full patterns in the `ai-smell` skill.)
12. **Possessive callback** - "that line of yours" (and "that post / take / point of yours"): the stilted `that ___ of yours` frame for something the reader said, fake-familiar and faintly condescending. Say "your X" or quote it directly. (Full patterns in the `ai-smell` skill.)

### Structural AI-shape (discourse-level; survives style edits)

The nine tells above are lexical - and lexical tells are fleeting (fine-tuning to mimic human style drops AI detection 97%->3%). A second, more durable layer lives in *how the piece is built*. StoryScope (COLM 2026) shows these discourse choices separate AI from human writing at ~93% F1 **even after all surface style is edited out**. Overlay them too; like AI smell, they are a trust hit, not a comprehension one. Adapted here for general prose (the paper studies fiction).

**Sentence-visible - paste into every reader; flag `over-explained` (and `ai-smell` when it also reads generated):**

1. **Spelled-out point** - states the moral / lesson / takeaway instead of trusting the reader to infer it (AI explains the theme 77% of the time vs 52% human). The strongest structural tell: over-determination.
2. **Sensation over-writing** - renders a feeling as bodily or sensory symptoms instead of naming it ("a tightening chest" for "afraid"); AI does this 81% vs 38%, and names the feeling plainly only 8% vs 29%.
3. **Vague allusion, never the specific** - gestures at other work / places / sources without naming a real one; AI cites concrete named references half as often (24% vs 47%) and shies from real brands and places.
4. **Debate-club dialogue** - talk that trades abstract positions rather than moving anything (AI 59% vs 34%).

**Whole-text - check in synthesis, not per sentence:**

5. **Too tidy** - single track, every thread resolved, no loose ends, resolution driven by one neat choice (69% vs 46%); human writing is messier and non-linear.
6. **No ambiguity** - clean resolution landing on understanding / acceptance (47% vs 27%); humans leave things unresolved and stances morally mixed (59% vs 38%).
7. **Narrow defaults / low rarity** - the whole piece sits in the safe center: predictable structure, default moves, nothing rare. Rarity is the proxy for originality; AI clusters tightly, humans scatter (mean rarity 0.71 vs 0.49).

### Feedback format (length-bound, consistent)

Every `fi` must use exactly this shape so the trace stays scannable. Lead every line with an **interest-heat emoji** so the whole trace reads as a colour strip and the eye jumps straight to where attention falls off:

```
S{i} | {heat} | follow: {status} yes / shaky / lost | interest: high / ok / low | flags: [confusing | TMI | dead-detail | redundant | jargon | unearned-claim | question-raised | ai-smell | over-explained | none]
thought: "<=20-word first-person reaction as the persona>"
```

For a title / front-page line, swap `follow:` for `click:` (`yes / maybe / no`) - the reader is deciding whether to open it, not whether to keep reading.

`{heat}` is exactly one emoji encoding how engaged the reader is *at this sentence*:

- 🟢 gripped - high interest, leaning in
- 🟡 following - mild / ok interest, still with you
- 🟠 drifting - low interest, attention slipping (the warning sign before a bounce)
- 🔴 bounced - lost, checked out, closing the tab

`{status}` is exactly one emoji encoding whether the reader is still with the text (the follow / click axis, distinct from interest - a reader can still be following yet bored, or gripped yet confused):

- ✅ still in - follow: yes / click: yes
- ⚠️ wavering - follow: shaky / click: maybe
- ❌ dropped - follow: lost / click: no

Always render both emoji - they are the most-read part of the trace. Pick `{heat}` from the reader's engagement and `{status}` from whether they keep going, not from the flags (a sentence can be flagged `redundant` yet still 🟢 ✅). Keep `thought` to one line. Flags may combine (e.g. `[TMI, dead-detail]`); when a sentence trips no flags, render `✅` in the flags column instead of the word `none`.

## Cost control

This is `k` sequential subagent calls with growing context - expensive by design. Before running:

- If the text is longer than ~40 sentences, tell the user the rough cost and confirm scope, or offer to run on the key passage only.
- Never silently truncate. If you review only part, say which part.

## Synthesizing the result

After collecting `f1 ... fk`, hand the user:

1. **The trace** - the per-sentence lines above, in order, as a scannable list or table, with the interest-heat emoji and the follow/click status emoji as the leading columns so the colour strip shows at a glance where interest climbs, where it drops, and where the reader wavers or drops out. Column headers must be descriptive words (e.g. "Interest", "Follow"), never emoji alone - the emoji live in the cells, the headers name what the column means. Show the full sentence `si` in the trace, not a truncated label or paraphrase, so the reader sees exactly what each reaction is reacting to.
2. **Diagnosis** - where the persona got confused, bored, or bounced; which sentences were dead weight; which claims went unearned.
3. **AI-smell report** - every sentence flagged `ai-smell`, with the named tell (e.g. "contrastive parallelism") and a cut or rewrite, in the style of the `ai-smell` skill. Default to cutting. This section appears for every run regardless of persona; if nothing smelled, say so explicitly.
4. **AI-shape report** - the structural tells above, judged over the whole piece: does it over-explain its point, over-write sensation, dodge specifics, resolve too tidily, avoid ambiguity, or sit in safe defaults? These survive style edits, so call them even when the surface prose is clean. If none apply, say so.
5. **Concrete edits** - specific cuts, clarifications, and reorderings tied to sentence numbers. Bias toward *cutting and tightening*: the point of the exercise is writing that respects this reader's attention.
