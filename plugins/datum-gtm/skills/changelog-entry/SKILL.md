---
name: changelog-entry
description: >
  Write a changelog entry for Datum Cloud's GitHub Discussions Changelog
  category that meets Datum's content standards. Turns raw engineering notes,
  PR/issue links, commit messages, or a one-line feature description into a
  ready-to-post discussion title and markdown body. Use when someone says
  "write a changelog entry", "announce this in the changelog", or "post this to
  the changelog discussions" — this is the community-facing changelog POST, not
  the Keep a Changelog release file (that lives in `gtm-templates`).
---

# Changelog Entry

Produce a ready-to-post entry for the [Datum Cloud Changelog discussions](https://github.com/orgs/datum-cloud/discussions/categories/changelog):
a benefit-led **title** plus a markdown **body**. The reader is a Datum *user*
deciding whether this changes what they can do today — not an engineer reviewing
the implementation.

**This is a different artifact from `gtm-templates`.** `gtm-templates` covers the
Keep-a-Changelog *release file* (`### Added / Changed / Fixed` in a repo's
`CHANGELOG.md`). This skill produces a *community discussion post*: narrative,
visual, and written for users. Don't paste a Keep-a-Changelog block into a
discussion — reshape it with this skill.

Model to imitate: **[datumctl v0.16.0 — Bring your own plugin catalog](https://github.com/datum-cloud/datum/discussions/259)**
(context-then-benefit lead, `###` sections, fenced code, `> [!NOTE]` callouts,
per-section 📖 docs links, compare-link footer).

Use `template.md` for the fill-in skeleton and `example.md` for a full worked
run (raw notes → finished post).

---

## Process

### Step 1 — Gather inputs

From the notes/PRs/commits, pull out (and ask the requester only for what's
genuinely missing):

- **What a user can now do** — the capability, in plain terms.
- **Who benefits and the concrete "so what"** — a real scenario, e.g. "useful
  when your upstream routes traffic by hostname — multi-tenant SaaS,
  virtual-hosted buckets, model gateways that key off the request host."
- **The docs page** that covers it (a `datum.net/docs/...` deep link).
- **Community to credit** — anyone who requested or reported this, and the
  Feature Request / bug discussion it resolves.
- **Media** — is there a screenshot, GIF, or terminal recording? If not, you'll
  emit a placeholder (Step 6).
- **For a CLI release** — the version and the previous version (for the
  compare-link footer).

### Step 2 — Classify the entry (and gate on scope)

| Type | Signal | Shape |
|------|--------|-------|
| **CLI release** | `datumctl vX.Y.Z`, a tag, release notes | Title pairs version + headline feature; body has hero feature + grouped changes + **compare-link footer** |
| **Feature launch** | one substantial user-facing capability | Benefit title; hero feature section with visual; docs link |
| **Digest / roundup** | several small changes, none a headline on its own | Benefit title (not a grab-bag); changes grouped under New / Improved / Fixed |

**Scope gate — stop before drafting if:**

- **Not a product change.** Company/marketing news (handbook, website nav,
  design-system, hiring) does **not** belong in the changelog. Redirect to a
  blog post (`gtm-templates`) or drop it.
- **Too thin to stand alone.** A stub under ~100 words of real substance should
  be **held and merged into the next digest**, not posted by itself. Say so
  instead of padding it.

### Step 3 — Write the title

Benefit-led **and** feature-named. Sentence case. `datumctl` always lowercase.

| Do | Don't |
|----|-------|
| `Access logs: debug routing without leaving the dashboard` | `Access logs` (bare noun) |
| `datumctl v0.16.0 — Bring your own plugin catalog` | `datumctl v0.16.0` (version only) |
| `Rewrite the Host header per route` | `AI Edge, Connectors, and Improvements` (vague grab-bag) |

Name the feature, lead with the payoff. Avoid opening every title with
"Introducing X" — vary it. For a CLI release, pair the version with the headline
feature using an em-dash (`—`).

### Step 4 — Draft the body (fixed structure)

Follow `template.md`:

1. **Lead paragraph** — what you can now do + why it matters, 1–2 sentences, in
   "you can now…" voice. No preamble, no "we're excited to announce."
2. **Hero feature** — the headline change, with the visual (Step 6) and a
   concrete scenario. Use `###` headings and fenced code for commands/config.
3. **Remaining changes** — grouped under `### New`, `### Improved`, `### Fixed`
   (omit any group that's empty). One line each, benefit-first.
4. **Docs deep-links** — a 📖 link per feature to `datum.net/docs/...`.
5. **Closing** — community credit + a single pointed question (Step 7).
6. **Footer (CLI releases)** — `**Full changelog:** [vA...vB](compare-url)`.

Use `> [!NOTE]` / `> [!IMPORTANT]` callouts for upgrade or compatibility notes,
as in the gold-standard post.

### Step 5 — Voice pass: translate engineer-speak to user outcomes

Rewrite anything that describes *how it was built* into *what the user gets*.
Cut internal implementation trivia entirely (e.g. "Replaced the Express BFF with
Hono, 93% smaller" — a user does not care). Gloss or remove Kubernetes jargon:

| Engineer wrote | User reads |
|----------------|------------|
| "Added the `AccessLogConfig` CRD, reconciled by the logging-controller" | "Turn on access logs for any proxy" |
| "reconciliation loop now converges faster" | "changes take effect in seconds" |
| "logs stream from Envoy via the activity pipeline" | "your live traffic shows up in the dashboard" |
| "exposed a new field on the spec" | "a new setting lets you…" |

If a term (CRD, controller, reconcile, webhook, informer) survives into the
draft, it's a bug — replace it with the outcome.

### Step 6 — Visuals (every post needs at least one)

If you have the media, embed it. If you can't produce it, emit a clearly marked
placeholder so a human captures it before publishing — describe *exactly* what to
show:

```markdown
> 🎬 **VISUAL PLACEHOLDER — capture before publishing**
> Show: filtering the access-log stream by status code, then clicking a 404 to
>       reveal which host/route matched.
> Format: GIF (or terminal recording via asciinema/vhs for CLI features).
> Caption: "Filter to 404s and see the matched route inline."
```

Prefer a GIF or terminal recording for anything interactive; a screenshot is
the floor, not the goal.

### Step 7 — Docs links, community hooks, and one CTA

- **Docs, never internal issues.** Link the product docs page. **Never** end with
  "View the details on GitHub" pointing at an internal
  `enhancements/issues/NNN` work-tracking issue — that's the single most common
  mistake in past posts. The only GitHub link that belongs is a CLI **compare**
  link or the resolved **Feature Request** discussion.
- **Credit the community.** @-mention and thank whoever requested or reported it;
  link back to the Feature Request discussion this resolves.
- **One closing CTA.** End with a *single* pointed question that invites a
  specific reply, and invite a reaction — not a generic "let us know what you
  think!" Good: "What's the first route you'll add a header rewrite to?"

---

## Self-review checklist

Run this before returning the entry. Every box must be checked.

- [ ] **Title** is benefit-led *and* names the feature (not a bare noun or vague grab-bag); sentence case; `datumctl` lowercase; version paired with headline for CLI releases.
- [ ] **Lead** is 1–2 sentences in "you can now…" voice — no "excited to announce."
- [ ] **Jargon glossed** — no CRD / controller / reconcile / webhook / Envoy / BFF or other build-side detail survived.
- [ ] **Concrete scenario** present — a real "useful when…" the reader recognizes.
- [ ] **At least one visual** — embedded, or a clearly marked placeholder saying exactly what to capture.
- [ ] **Docs deep-link(s)** to `datum.net/docs/...` — one per feature.
- [ ] **No internal issue link** — nothing points at `enhancements/issues/NNN`; only docs, a Feature Request discussion, or a CLI compare link.
- [ ] **Community credited** where applicable (@-mention + resolved Feature Request link).
- [ ] **Single closing CTA** — one pointed question, plus a reaction invite.
- [ ] **CLI releases** carry a `Full changelog:` compare-link footer.
- [ ] **Scope is clean** — no marketing/company news; not a sub-100-word stub that should be a digest.

---

## Related

- `gtm-templates` — Keep-a-Changelog *release file* format and other GTM
  templates. Complementary, not a substitute for this skill.
- `template.md` — fill-in skeleton for the post.
- `example.md` — raw notes → finished post, worked end to end.
