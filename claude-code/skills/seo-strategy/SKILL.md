---
name: seo-strategy
description: Plan and write programmatic SEO landing pages that rank for high-intent buyer queries. Use when creating comparison, alternatives, review, "best X for Y", how-to, role, or integration pages, or planning keyword coverage for a product site.
---

# SEO Strategy

Programmatic SEO: one reusable page template, filled from a data set, so a whole
family of high-intent queries gets a dedicated page. The win is not volume, it is
intent. Someone searching "[competitor] alternatives" is mid-purchase and comparing
vendors. Rank for that and you meet a buyer, not a browser.

Work the query the searcher actually typed. Match the page to their intent, answer
it faster and more honestly than the incumbent result, and give exactly one next step.

## The archetypes

Each row is a query pattern that maps to one page template. Fill `[bracket]` slots
from your data set (competitors, roles, integrations, segments).

| Archetype | Query pattern | Searcher intent | The page must have |
|---|---|---|---|
| Alternatives | `[Competitor] alternatives` | Unhappy with or evaluating a tool, wants a shortlist | A real ranked list of alternatives (you lead, but list genuine others); why-switch reasons; one honest line per alternative |
| Head-to-head | `[Competitor] vs [Competitor]` | Down to two, wants a decision | Feature matrix; a "who each wins for" verdict; no strawman of the other side |
| Review | `[Competitor] review` | Researching one tool, wants an opinion | Balanced pros and cons; who it fits; a call on where it falls short |
| Best-for | `Best [product] for [X]` | Category shopping within a segment | A curated list scoped to X; selection criteria stated; picks that actually fit X |
| Switching how-to | `How to export data from [Competitor]` | Already leaving, wants the mechanics | Real, correct steps; format and gotchas; migration path as the CTA |
| Role | `[Software] for [role]` | A persona checking fit | The role's specific pains and outcomes, in their language, not generic copy |
| Integration | `[Software] with [X] / connect [X]` | Checking "does it work with X" | Confirmation it works; setup steps; what the integration unlocks |

Extend the set as new query shapes appear (pricing, "is X worth it", "X for [industry]").
The method is identical: one template, a data set, a page per row.

## Workflow

1. **Inventory first.** List which pages in this family already exist and which do
   not. Never rebuild an existing one blind; extend the data set for the gaps. If the
   site already drives these pages from one source of truth (a data file feeding the
   route table and prerender metadata), add a row there, do not hand-write a page.
2. **Pick the archetype** from the table by the query you are targeting.
3. **Research the target** from primary sources: the competitor's own docs, pricing,
   and positioning; the integration's real API; the role's actual job. Read it, do not
   recall it.
4. **Write honest content** (see guardrails).
5. **Wire internal links** hub-and-spoke: a hub page lists every spoke, every spoke
   links back to the hub and to 2 to 3 sibling spokes.
6. **Add metadata** (see on-page checklist).
7. **Ship and measure** (see measurement).

## Honesty guardrails

The one thing these pages must not do is overclaim. An inflated comparison is a legal
and trust risk, and search engines demote thin, misleading affiliate-style pages.

- Every claim about a competitor reflects their public positioning. If a capability
  cannot be verified from public sources, mark it `unknown`, never guess.
- Give competitors real strengths. "Where they win" is a required section, not a
  weakness. A page where the rival has zero merits reads as a strawman and converts worse.
- Comparison rows are symmetric: cite latency for both sides, price for both sides.
  A different axis per row fakes balance.
- Lead with your genuine differentiator (the wedge), then show parity rows honestly
  below it. Do not bury the parity.

## On-page checklist

- **Title tag**: front-load the exact query. `[Competitor] Alternatives` beats
  `Why We Are Better`. Under ~60 chars.
- **H1**: the query, once, matching the title's intent.
- **Slug**: readable and query-shaped (`/comparison/acme-alternatives`,
  `/connect/[integration]`). Stable, never churned.
- **Meta description**: one sentence, the payoff plus a reason to click. Under ~155 chars.
- **First paragraph** answers the query in the first two sentences. No throat-clearing.
- **FAQ block** with real questions people ask, plus FAQ structured data (schema.org).
- **One CTA**, repeated, matched to intent (switching page to migration, integration
  page to setup). Competing CTAs split the click.
- **Unique body content per page.** Boilerplate with a swapped noun is thin content and
  will not rank. The data set must carry genuinely different facts per row.

## Prioritize

Ship in this order:
1. Gaps where buyer intent is highest: `vs` and `alternatives` for competitors you
   lose deals to; integrations customers actually ask for.
2. Where you already have a differentiated, truthful story to tell.
3. Long-tail role and best-for pages once the core comparison set exists.

Skip a page if you cannot say anything true and specific on it. A missing page beats a
thin one.

## Measure

Track impressions, clicks, and average position per page in Search Console (grouped by
archetype), plus conversions from those pages. A page stuck at position 15 with
impressions needs better content or intent match, not more pages. Prune or merge pages
that never gain impressions after a fair window.

Note: dashes in the tables above are format placeholders. Never use em dashes in output.
