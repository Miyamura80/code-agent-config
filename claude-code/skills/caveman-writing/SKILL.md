---
name: caveman-writing
description: Answer in brutally compressed bullets that keep only the highest-information words and drop every filler word, article, copula and hedge, until it barely reads as grammatical. Use whenever the user says "/caveman-writing", asks for caveman mode, telegram style, or "no fluff", or asks for an answer that is brutally short, maximally dense, stripped down, bullets only, or "just the facts". Also use proactively when the user is clearly skimming, asks for a rapid rundown, or has already told you twice to be shorter. Do not use for text the user will send to someone else, or for code.
---

# Caveman Writing

Answer in bullets. Keep only words that carry information. Delete everything else.

Test for every word: if deleting it leaves the meaning recoverable, delete it.

## Format

```
- <3 to 7 words, no articles, no copula>
- <next fact>
  - <sub-point, only when genuinely subordinate>
```

Bullets only. No intro line, no closing summary, no transition sentences. First bullet is the answer.

## What survives

Nouns. Numbers. Names. Units. Verbs that carry an action. Negations. Conditions.

## What dies

- Articles: a, an, the
- Copula and auxiliaries: is, are, was, has been, will be
- Existentials: there is, there are, it seems that
- Hedges with no truth content: I think, arguably, fairly, quite, somewhat
- Transitions: however, additionally, furthermore, that said, in order to
- Politeness and framing: happy to help, great question, as you mentioned
- Pronouns recoverable from context
- Prepositions where juxtaposition works
- Adverb intensifiers: very, really, extremely

## Examples

Input: The main problem is that the database connection pool is being exhausted during peak hours, which causes requests to queue up and eventually time out.
Output:
```
- Connection pool exhausted, peak hours
- Requests queue, then time out
```

Input: I would recommend that you consider moving to Postgres, although it's worth noting that the migration would probably take about two weeks of engineering time.
Output:
```
- Move to Postgres
- Cost: ~2 weeks eng time
```

Input: There are three vendors that could work here, but none of them have SOC 2, so procurement will likely push back.
Output:
```
- 3 vendors viable
- None SOC 2
- Procurement blocks
```

## Rules

- Target 3 to 7 words per bullet. Never a full sentence.
- Lowercase-ish is fine. Sentence-final periods optional. Drop them.
- One nesting level max. Two means restructure.
- Symbols beat words: `>`, `<`, `~`, `->`, `+`, `x`, `/`. "Costs more than X" becomes "> X cost".
- Numbers stay exact. Never round to feel snappier.
- Never use em dashes. Colon or comma instead.
- Cap 12 bullets. More means you are transcribing, not compressing.
- Delete any bullet the reader could have guessed.

## Never compress away meaning

Brevity that changes the claim is a bug, not a style.

- Negation stays. "Not compliant" never becomes "compliant".
- Real uncertainty stays as one token: `?`, `unconfirmed`, `est.`
- Conditions stay. "Works if X" never becomes "works".
- Scope stays. "3 of 50 users" never becomes "users".
- Attribution stays when the source decides the weight: `per SOC2 report`, `Slack, Ilia`.

Deleting a hedge is right. Deleting a caveat is wrong. If the hedge was load-bearing, keep it as one word.

## When not to use this

- Text going to another human: email, Slack, docs, posts. Compression reads as rudeness.
- Code, config, commands, exact strings.
- Legal, contractual, security-claim wording.
- The user is upset or working through something. Terse reads as cold.
- One-fact answers. Just say the fact.

If the request mixes both, caveman the analysis, write the deliverable normally.

## Grounding

Same rule as any answer: check the real source before compressing. Inbox, Slack, calendar, repo, web. Use edison-gateway MCPs first.

Compression happens after the facts land. Short and wrong is still wrong.
