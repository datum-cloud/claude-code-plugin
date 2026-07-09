# Worked Example

One end-to-end run: the messy input an engineer hands over, and the finished
changelog post produced from it. Read this alongside `SKILL.md` to see each
standard applied.

---

## Input (raw engineering notes)

> - shipped access logs UI for HTTPProxy. logs stream from Envoy via the
>   activity pipeline into the dashboard. can filter by status code, host, path.
> - added: export the current view to CSV.
> - improved: search now hits the new index, ~5x faster on big projects.
> - fixed: timestamps showed UTC instead of the viewer's tz. now localized.
> - this was our #1 feature request — discussion #180 from @maria-dev, runs a
>   multi-tenant SaaS, needed to debug 404s by hostname.
> - docs: datum.net/docs/observability/access-logs
> - impl: added AccessLogConfig CRD, reconciled by logging-controller. new
>   read path goes through the activity read model. (internal, don't publish)

## How it gets classified

- **Entry type:** Feature launch with a few secondary changes → hero feature +
  `New` / `Improved` / `Fixed` groups.
- **Scope gate:** user-facing product change, well over 100 words of substance —
  post it on its own. ✅
- **Credit:** @maria-dev requested it in #180 → thank + link.
- **Jargon to kill:** `HTTPProxy`, `Envoy`, `activity pipeline`,
  `AccessLogConfig CRD`, `logging-controller`, `activity read model` — none of
  these reach the reader.
- **Visual:** no media provided → emit a placeholder describing the filter-to-404
  flow (the concrete scenario from @maria-dev).

## Output (finished post)

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
upstream routes by hostname — multi-tenant SaaS, virtual-hosted buckets, model
gateways that key off the request host — and you need to know *which* host a
request actually matched.

> 🎬 **VISUAL PLACEHOLDER — capture before publishing**
> Show: filtering the live log stream down to status `404`, then clicking a row
>       to reveal the host and route that matched the request.
> Format: GIF.
> Caption: "Filter to 404s and see the matched host and route inline."

📖 [Access logs](https://datum.net/docs/observability/access-logs)

### New

- **Export to CSV** — download the current filtered view for a spreadsheet,
  a ticket, or an auditor. 📖 [Exporting logs](https://datum.net/docs/observability/access-logs#export)

### Improved

- **Search is ~5x faster** — filtering large projects that used to lag now
  returns near-instantly.

### Fixed

- **Timestamps now match your timezone** — log times display in your local
  timezone instead of UTC, so what you see lines up with when it happened.

Thanks to @maria-dev for raising this in [#180](https://github.com/datum-cloud/datum/discussions/180) —
it was our most-requested feature.

What's the first thing you'll go looking for in your access logs? Tell us below,
and react with 👍 if faster incident debugging is on your list.
```

---

## Why this passes the checklist

- **Title** names the feature (*access logs*) and leads with the payoff (*debug
  routing without leaving the dashboard*) — not the bare noun "Access logs."
- **Lead** is one sentence in "you can now…" voice and answers *why it matters*
  (no setup).
- **Jargon glossed** — "Envoy via the activity pipeline" became "your traffic
  streams in"; the CRD and controller are gone entirely.
- **Concrete scenario** — the multi-tenant / virtual-hosted / model-gateway
  "useful when…" the reader recognizes.
- **Visual placeholder** describes the exact flow to capture and the format.
- **Docs links** point at `datum.net/docs/...`; the internal `AccessLogConfig` /
  controller note never appears, and there's **no** "view details on GitHub"
  issue link.
- **Community credited** — @maria-dev thanked, discussion #180 linked as the
  resolved request.
- **Single closing question** invites a specific reply and a reaction, rather
  than a generic "let us know!"
