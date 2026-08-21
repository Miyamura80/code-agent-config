---
name: daily-brief
description: Produce a morning email triage brief that surfaces only the inbox threads worth the user's attention and parks the rest. Use whenever the user invokes "/daily-brief", asks "what needs my attention", "what did I miss", "any important email", "brief me on my inbox", or wants a morning rundown of new mail. Also the skill to run on a weekday-morning schedule. Runs on GmailMCP (gmail_curate_inbox, inbox_search, gmail_list_inbox, gmail_get_thread) and uses the curation ledger (inbox_get_curation / inbox_save_curation) so the same thread never gets re-surfaced two mornings in a row. Trigger it even when the user does not say the word "skill".
---

# Daily brief

A morning triage of the inbox. The job is judgment, not volume: pull out the few threads that genuinely need Eito, say why in one line each, and quietly park everything else. A brief that lists everything is useless. A brief that buries something important loses trust. Aim for the small set a sharp chief of staff would flag.

Tools are MCP only, no shell. Never send, reply, archive, or mark anything without being asked. This skill reads and reports; actioning is a separate, explicit step.

## What "worth attention" means

Surface a thread when it needs Eito specifically and soon:

- It needs a decision or a personal reply from him, not a delegate.
- It moves a live thread forward (a deal, an intro, a negotiation, a hire, an investor).
- It is time-sensitive or has a deadline attached.
- It is from a real person who is waiting on him.

Down-rank or park:

- Newsletters, digests, product announcements, marketing.
- Receipts, calendar notifications, "you were mentioned" and other automated noise.
- CC-only threads where he is an observer, not the person on the hook.
- Anything already handled (see the ledger step).

When genuinely unsure whether something needs him, put it in "worth a glance" rather than the top bucket. Never pad the top bucket, and never invent urgency, a deadline, or a sender that is not in the mail.

Use his context as a prior for what is high signal, not as a fixed whitelist: active sales and security conversations, KYC and AML onboarding loops, live deadlines (grant and application dates, filings), investors and their intros, partners and endorsers, and anything touching a deal in flight. New senders reaching out cold still count if the ask is real.

## 1. Set the window

Default to new mail since the last brief. On a Monday, widen to cover the weekend (roughly the last 72 hours) so nothing that landed Friday evening or over the weekend slips through. If the user names a window ("since yesterday", "last 3 days"), use that instead.

## 2. Check the ledger first

Read the curation ledger with `inbox_get_curation` before pulling anything. It records what earlier briefs already surfaced or dismissed. Use it to skip threads already triaged, so a brief never re-serves the same thread two mornings running unless something new arrived on it.

## 3. Pull and rank

- Start with `gmail_curate_inbox` for its heuristic ranking of recent threads. Treat the score as a first pass, not the verdict.
- Use `inbox_search` (or `gmail_list_inbox` with a Gmail query) to pull the full new set in the window, including anything the heuristic ranked low, so nothing is missed.
- For each candidate for the top bucket, open it with `gmail_get_thread` and read enough to summarize it accurately. Do not summarize from the subject line or a snippet alone. If a thread has history, the latest message is not always the point.

Read only what makes the brief better. Do not open every thread.

## 4. Triage and write the brief

Sort into three buckets and write it tight. No em-dashes.

```
Daily brief, {Weekday} {D Month}
{N new since last brief}. {M need you.}

Needs you today
1. {Sender, one or two words on who they are if not obvious}: {one line on what it is}. {Why it matters or the suggested next step.}
2. ...

Worth a glance
- {Sender}: {one line}
- ...

Parked ({count})
{One line rolling up the low-signal buckets, e.g. "9 newsletters, 4 receipts, 3 calendar notifications." No detail.}
```

Rules for the write-up:

- One line per item in the top bucket, plus a short "why" or a concrete next step (reply, book time, forward, decide). Lead with the person, not the subject header.
- Keep the top bucket small. If it runs past five or six, the bar was too low; re-sort.
- Match his voice: concise, direct, no filler, no corporate jargon, no "C-level".
- Keep sensitive internal detail (financials, cap table, named customers, security specifics) out of anything that might get forwarded. The brief is for him, so this is a light touch, but do not paste confidential specifics into a summary that could be copied onward.
- Never fabricate. If you could not read a thread, say so rather than guessing its contents.

## 5. Close the loop

- After presenting the brief, record the run with `inbox_save_curation` so tomorrow starts from a clean slate and today's judgments carry forward.
- Offer next actions, do not take them: "Want me to draft replies to 1 and 3?" A yes hands off to the email-reply skill (drafts only, never auto-send). Marking read or done with `gmail_mark_thread_read` / `gmail_mark_thread_done` also waits for an explicit ask.

## Optional: top the brief with the day

If a calendar tool is connected, and only then, add a two or three line header above "Needs you today" listing today's meetings (time, title, who). Skip it silently if no calendar tool is available. Do not let the calendar pull turn into a second project; it is a garnish on the email brief, not the main course.

## Running it

Invoked by hand each weekday morning by typing `/daily-brief`. No scheduler, no automation to reason about.
