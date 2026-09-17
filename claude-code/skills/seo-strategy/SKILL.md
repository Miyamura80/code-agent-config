---
name: seo-strategy
description: Plan and write programmatic SEO landing pages that rank for high-intent buyer queries. Use when creating comparison, alternatives, review, "best X for Y", how-to, role, or integration pages, or planning keyword coverage for a product site.
---

# SEO Strategy

Programmatic SEO: one template, one data set, one page per high-intent query.

- Win is intent, not volume
- "[competitor] alternatives" searcher = buyer mid-switch, not browser
- Match page to intent, answer faster + more honest than incumbent
- Give one next step, no more

## Archetypes

One query pattern -> one template. Fill `[bracket]` from data set (competitors, roles, integrations, segments).

- **Alternatives** `[Competitor] alternatives`
- **Head-to-head** `[Competitor] vs [Competitor]`
- **Review** `[Competitor] review`
- **Best-for** `Best [product] for [X]`
- **Switching how-to** `How to export data from [Competitor]`
- **Role** `[Software] for [role]`
- **Integration** `[Software] with [X]` / `connect [X]`

Extend as new shapes appear (pricing, "is X worth it", "X for [industry]"). Method same: one template, data set, page per row.

## Workflow

- **Inventory first.** List which pages exist, which gaps. Never rebuild blind. Site drives pages from one data source? Add a row, do not hand-write page
- **Pick archetype** by target query
- **Research target** from primary sources: competitor docs, pricing, positioning, real API, actual role. Read it, do not recall
- **Write honest content** (see guardrails)
- **Wire internal links** hub-and-spoke: hub lists every spoke, spoke links back + 2-3 siblings
- **Add metadata** (see checklist)
- **Ship + measure**

## Honesty guardrails

Overclaim = legal + trust risk, and search demotes thin misleading pages.

- Every competitor claim = their public positioning
- Unverifiable capability -> mark `unknown`, never guess
- Give competitors real strengths. "Where they win" = required section, not weakness. Zero-merit rival = strawman, converts worse
- Symmetric rows: latency both sides, price both sides. Different axis per row fakes balance
- Lead genuine differentiator (wedge), parity rows honest below. Do not bury parity

## On-page checklist

- **Title**: front-load exact query. `[Competitor] Alternatives` > `Why We Are Better`. < ~60 chars
- **H1**: the query, once, matches title intent
- **Slug**: readable, query-shaped (`/comparison/acme-alternatives`). Stable, never churned
- **Meta description**: one sentence, payoff + click reason. < ~155 chars
- **First paragraph**: answer query in first 2 sentences. No throat-clearing
- **FAQ block**: real questions + FAQ schema (schema.org)
- **One CTA**, repeated, matched to intent (switching -> migration, integration -> setup). Competing CTAs split click
- **Unique body per page**: boilerplate + swapped noun = thin content, will not rank. Data set carries different facts per row

## Prioritize

- Highest buyer intent first: `vs` + `alternatives` for deals you lose, integrations customers ask for
- Where you have differentiated, truthful story
- Long-tail role + best-for once core set exists
- Cannot say anything true + specific? Skip it. Missing page > thin page

## Measure

- Track impressions, clicks, avg position per page (Search Console, grouped by archetype) + conversions
- Position 15 with impressions -> better content/intent match, not more pages
- Never gains impressions after fair window -> prune or merge
