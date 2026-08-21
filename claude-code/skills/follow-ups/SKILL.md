---
name: follow-ups
description: Surface the things a user should follow up on, score each by how stale it is getting, and render the result as an inline colour-coded priority board (🔴 act now / 🟡 this week / 🟢 low or fresh) with a gap-days count on every item. Use this whenever the user asks what they should follow up on, what needs chasing, what is slipping, what they are waiting on, what they owe a reply to, or asks to prioritise, triage, or "clean up" a set of open threads, tasks, deals, applications, or messages. Also trigger on the explicit invocation "/follow-ups", and re-run it (dropping done items) whenever the user says they have handled something and wants the board again. Works on email inboxes, task trackers, CRM pipelines, or any list of items the user pastes in. Trigger it even when the user does not say the word "skill" and even when they only imply prioritisation ("which of these is most urgent?", "am I forgetting anyone?").
---

# Follow-ups

Turn a messy pile of open threads into a short, honest, prioritised board. The core idea: **the right follow-up order is a function of how stale each item is getting, weighted by what is at stake.** Render it as an inline visual, not a wall of text.

This skill is source-agnostic. The items can come from an email inbox, a task tool, a CRM, a spreadsheet, or a list the user pastes into chat. The scoring and rendering are the same everywhere.

## 1. Gather the candidate items

Pull the open items from whatever source is in play. Prefer a connected tool over asking:

- **Email**: use the connected inbox tool to list recent threads (a headless triage search is ideal, e.g. a "since N days" query). Read snippets, not full bodies, unless you need direction (who spoke last).
- **Tasks / CRM / tickets**: use the connected tool to list open or in-progress items.
- **Pasted list**: if the user drops in a list, work from that directly.

For each candidate, you need three things: a **subject/label**, the **date of the last activity**, and enough context to tell **who owes the next move**.

Filter aggressively. Newsletters, receipts, automated no-reply blasts, and cold outreach that needs no action are noise. A follow-up board with 6 real items beats one with 30 padded ones. Flag anything that looks like junk or a scam in one line and leave it off the board (or drop it into a low-priority "ignore" row at most).

## 2. Compute the gap in days

For every item, `gap = today − date of last activity`, in whole calendar days. Always anchor to the real current date. State the anchor date once near the board so the numbers are auditable.

Gap is the raw staleness signal. It is not the final priority (see step 4), but it is the number shown on each row.

## 3. Classify who owes the next move

Direction changes what "follow up" means:

- **You owe a reply / an action** — someone is waiting on the user, or the user committed to something. The follow-up is: do it.
- **You are waiting on them** — the user already acted; the ball is in the other party's court. The follow-up is: chase, but only once it has gone quiet long enough to be worth a nudge.
- **Optional / declinable** — low-value asks the user can answer or ignore at leisure.

A thread whose last message is the user's own, sent today, is usually *fresh* (gap 0) and needs nothing yet — do not mark it urgent just because it is "open".

## 4. Assign priority (colour)

Colour blends staleness with stakes. Do not sort on gap alone — that pushes stale junk to the top and buries fresh-but-critical items.

- 🔴 **Act now** — high stakes and/or a hard deadline in the next few days, or a genuinely stale item on something that matters (a live deal, a key relationship, money owed). A near-term deadline can make a fresh item red even at gap 0.
- 🟡 **This week** — worth doing soon but not on fire: a moderately stale chase, a quick yes/no someone is waiting on, an aging admin task with no hard deadline.
- 🟢 **Low / fresh** — either just touched (ball in the other court) or stale-but-low-value. A stale item can still be green if nothing is really at stake.

Be transparent: add a one-line note on the board explaining that colour = staleness weighted by stakes and deadlines, so the ordering never looks arbitrary.

Sort the board 🔴 → 🟡 → 🟢, and within a colour, stalest first.

## 5. Render the inline board

Render with the visualizer as an inline widget (this matches the "prefer inline canvas when there are lots of numbers" habit). Call `visualize:read_me` with the `data_viz` module once per session before your first `show_widget`, then emit the board.

Keep **all** prose (the intro line, the per-item reasoning, the offer to draft) in your chat response, outside the widget. The widget holds only the visual.

Use this template. Edit the `rows` array and the three metric-card counts; leave the structure intact. Colours are fixed to the three priority ramps.

```html
<div style="padding: 0.5rem 0;">
  <h2 class="sr-only">Follow-up items ranked by days since last activity, colour-coded by priority.</h2>

  <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 1.25rem;">
    <div style="background: var(--surface-1); border-radius: var(--radius); padding: 0.85rem 1rem;">
      <p style="font-size: 13px; color: var(--text-secondary); margin: 0 0 4px;">🔴 Act now</p>
      <p style="font-size: 24px; font-weight: 500; margin: 0; font-variant-numeric: tabular-nums;">RED_COUNT</p>
    </div>
    <div style="background: var(--surface-1); border-radius: var(--radius); padding: 0.85rem 1rem;">
      <p style="font-size: 13px; color: var(--text-secondary); margin: 0 0 4px;">🟡 This week</p>
      <p style="font-size: 24px; font-weight: 500; margin: 0; font-variant-numeric: tabular-nums;">YELLOW_COUNT</p>
    </div>
    <div style="background: var(--surface-1); border-radius: var(--radius); padding: 0.85rem 1rem;">
      <p style="font-size: 13px; color: var(--text-secondary); margin: 0 0 4px;">🟢 Low / fresh</p>
      <p style="font-size: 24px; font-weight: 500; margin: 0; font-variant-numeric: tabular-nums;">GREEN_COUNT</p>
    </div>
  </div>

  <div id="rows" style="display: flex; flex-direction: column; gap: 8px;"></div>

  <p style="font-size: 12px; color: var(--text-muted); margin: 1rem 0 0; line-height: 1.6;">Gap = days since last activity, counted from today, ANCHOR_DATE. Colour blends staleness with stakes: a hard deadline can push a fresh item red, and a stale but low-value item stays green.</p>
</div>

<script>
const rows = [
  { p: 'r', bg: '#FCEBEB', tx: '#A32D2D', subject: 'ITEM NAME', meta: 'who owes what', gap: 7, note: 'why it matters' },
  { p: 'y', bg: '#FAEEDA', tx: '#854F0B', subject: 'ITEM NAME', meta: 'who owes what', gap: 4, note: 'context' },
  { p: 'g', bg: '#EAF3DE', tx: '#3B6D11', subject: 'ITEM NAME', meta: 'who owes what', gap: 0, note: 'context' },
];
const emoji = { r: '🔴', y: '🟡', g: '🟢' };
document.getElementById('rows').innerHTML = rows.map(function(x){
  return '<div style="display: flex; align-items: center; gap: 12px; background: var(--surface-2); border: 0.5px solid var(--border); border-radius: 12px; padding: 0.7rem 0.9rem;">'
    + '<span style="font-size: 15px; line-height: 1;">' + emoji[x.p] + '</span>'
    + '<div style="flex: 1; min-width: 0;">'
    + '<p style="font-size: 15px; font-weight: 500; margin: 0 0 2px; color: var(--text-primary);">' + x.subject + '</p>'
    + '<p style="font-size: 13px; color: var(--text-secondary); margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">' + x.meta + (x.note ? ' · ' + x.note : '') + '</p>'
    + '</div>'
    + '<div style="text-align: center; min-width: 52px; background: ' + x.bg + '; border-radius: var(--radius); padding: 5px 4px;">'
    + '<p style="font-size: 18px; font-weight: 500; margin: 0; color: ' + x.tx + '; font-variant-numeric: tabular-nums;">' + Math.round(x.gap) + '</p>'
    + '<p style="font-size: 10px; margin: 0; color: ' + x.tx + ';">day' + (x.gap === 1 ? '' : 's') + '</p>'
    + '</div>'
    + '</div>';
}).join('');
</script>
```

Row fields: `p` is priority (`r`/`y`/`g`, which also sets the emoji and gap-badge colour), `subject` is the item name, `meta` is the direction ("You: reply", "Waiting on X"), `gap` is the integer day count, `note` is a short why. Keep `subject` and `meta` to one line each; detail goes in your prose.

## 6. Follow through in prose

After the board, in chat: call out why the top item is top, name the single thing most worth doing this week, and offer to draft or action the top one or two. Keep it tight. Do not restate the board as a text list — it is already on screen.

## Re-running and updating

When the user says they have handled something ("done with X", "sent the reply", "cleared those"), re-render the board with those rows removed and the counts updated. Recompute gaps against the current date each time. Treat items you have already drafted a reply for as handled unless the user says otherwise.

## Conventions

- Anchor every gap to the real current date and show that date on the board.
- Round every gap to a whole number.
- Match the user's standing preferences (for this user: no em-dashes anywhere; use their own scheduling link, not the counterparty's, in any drafted reply).
- If there is genuinely nothing worth following up on, say so plainly rather than padding the board.
