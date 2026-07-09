# Worked Example

One end-to-end run: the messy input an engineer hands over, and the complete
draft produced from it — including the handoff block a human clears before
publishing. Read this alongside `SKILL.md` to see each rule applied. Note where
the input is *incomplete*: the draft marks those spots rather than inventing.

---

## Input (raw engineering notes)

> - shipped access logs UI. users watch live requests to their proxies in the
>   dashboard and filter by status code, host, path. docs are LIVE at
>   datum.net/docs/observability/access-logs
> - new: export the current filtered view to CSV. (docs for the export bit
>   aren't written yet — docs team has a draft in PR datum-cloud/docs#521)
> - improved: search is way faster on big projects now — maybe ~5x, rough number
> - fixed: timestamps showed UTC, now localized to the viewer's timezone
> - #1 feature request: discussion #180 from @maria-dev, a community user running
>   a multi-tenant SaaS who needed to debug 404s by hostname
> - marketing also asked us to plug the new pricing page in this post
> - no screenshots captured yet
> - impl (don't publish): AccessLogConfig CRD reconciled by logging-controller;
>   read path via the activity read model

## How it gets classified

- **Entry type:** Feature launch with secondary changes → hero feature +
  `New` / `Improved` / `Fixed` groups.
- **Scope gate:** the access-logs feature is a real user-facing change, well over
  100 words → post it. The **pricing-page plug marketing asked for is out of
  scope** (marketing news) → excluded from the post, surfaced in the handoff
  block, not silently dropped.
- **Credit:** @maria-dev is a community user in a public discussion (#180) →
  safe to @-mention and link directly.
- **Jargon to kill:** `AccessLogConfig CRD`, `logging-controller`, `reconciled`,
  `activity read model` — none reach the reader.
- **Incomplete inputs, handled not invented:** export docs aren't published
  (→ DOCS PLACEHOLDER); the "~5x" figure is rough (→ `[VERIFY]`); no media
  (→ visual placeholder).

## Output (complete draft)

### Title

```
Access logs: debug routing without leaving the dashboard
```

### Body

```markdown
You can now see every request hitting your proxies in the dashboard, and filter
to exactly the ones you care about — no log shipping or third-party tooling to
set up.

### Live access logs, filtered your way

Open **Observability → Access logs** and your traffic streams in as it happens.
Filter by status code, host, or path to zero in on a problem. Useful when your
upstream routes by hostname — a multi-tenant SaaS where a single 404 could be any
of your tenants — and you need to know *which* host a request actually matched.

> 🎬 **VISUAL PLACEHOLDER — capture before publishing**
> Show: filtering the live log stream down to status `404`, then clicking a row
>       to reveal the host and route that matched the request.
> Format: GIF.
> Caption: "Filter to 404s and see the matched host and route inline."

📖 [Access logs](https://datum.net/docs/observability/access-logs)

### New

- **Export to CSV** — download the current filtered view for a spreadsheet, a
  ticket, or an auditor.
  > 📄 DOCS PLACEHOLDER — confirm the published URL before posting (draft: datum-cloud/docs#521)

### Improved

- **Search is much faster on large projects** — filtering long histories that
  used to lag now returns quickly (around 5×). `[VERIFY: confirm the ~5× figure]`

### Fixed

- **Timestamps now match your timezone** — log times display in your local
  timezone instead of UTC, so what you see lines up with when it happened.

Thanks to @maria-dev for raising this in [#180](https://github.com/datum-cloud/datum/discussions/180) —
it was our most-requested feature.

What's the routing mystery you'll finally get to the bottom of with access logs?
React with 👍 if faster incident debugging has been on your list.

> [!WARNING]
> **⚠️ Before publishing — a human must clear these, then delete this block:**
> - **Capture visuals:** the 404-filter GIF described in the hero placeholder.
> - **Confirm docs URLs are live:** the export CSV page (draft in docs#521) is
>   not published — replace the placeholder with the live URL or hold that line.
>   The Access logs page is stated live; sanity-check it resolves.
> - **Confirm unstated claims:** the "~5×" search figure is a rough dev number —
>   confirm or soften before publishing.
> - **Excluded on scope:** marketing asked to plug the new pricing page — left
>   out as marketing news; suggest a blog post or the pricing page's own channel.
```

---

## Why this passes the checklist

- **Title** names the feature and leads with the payoff — not the bare noun.
- **Lead** is one sentence in "you can now…" voice, answering *why it matters*.
- **No invented specifics** — the scenario comes straight from @maria-dev's
  request; the rough metric is flagged `[VERIFY]`, not stated as fact; the
  unpublished export docs use a DOCS PLACEHOLDER instead of a guessed URL.
- **Jargon glossed** — the CRD, controller, and read-model are gone.
- **Docs** point at a confirmed-live page (hero) and a placeholder (export); no
  internal `enhancements/issues` link appears.
- **Credit is safe** — @maria-dev is a public community member from a public
  discussion, so the direct @-mention and link are fine.
- **One CTA** invites a *story* ("the routing mystery you'll finally get to the
  bottom of"), not a number or a yes/no, and isn't "let us know!"
- **Scope is clean** — the pricing-page plug is excluded and surfaced in the
  handoff block, not silently dropped.
- **Handoff block** lists every visual, unconfirmed URL, `[VERIFY]` claim, and
  excluded item — so the reviewer knows exactly what stands between this draft
  and publish.
