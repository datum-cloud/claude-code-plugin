---
name: changelog-entry
description: >
  Turn raw engineering notes, PR/issue links, commit messages, or a one-line
  feature description into a changelog entry for Datum Cloud's GitHub Discussions
  Changelog category: a benefit-led title plus a markdown body, drafted for
  users and ready to hand off for final capture and publish. Use when someone
  says "write a changelog entry", "announce this in the changelog", or "post
  this to the changelog discussions" — this is the community-facing changelog
  POST, not the Keep a Changelog release file (that lives in `gtm-templates`).
---

# Changelog Entry

Produce an entry for the [Datum Cloud Changelog discussions](https://github.com/orgs/datum-cloud/discussions/categories/changelog):
a benefit-led **title** plus a markdown **body**, written for a Datum *user*
deciding whether this changes what they can do today — not for an engineer
reviewing the implementation. The output is a **complete draft ready to hand
off**, not a post you publish directly: it ends with a handoff block (Step 8)
listing what a human must do first.

This is a different artifact from `gtm-templates`, which covers the
Keep-a-Changelog *release file* (`### Added / Changed / Fixed` in a repo's
`CHANGELOG.md`). Don't paste a Keep-a-Changelog block into a discussion —
reshape it with this skill.

Use `template.md` for the fill-in skeleton and `example.md` for a full worked
run (raw notes → finished draft, including the handoff block).

**Model to imitate:** [datumctl v0.16.0 — Bring your own plugin catalog](https://github.com/datum-cloud/datum/discussions/259)
for *structure and voice* — context-then-benefit lead, `###` sections, fenced
code, `> [!NOTE]` callouts, per-section 📖 docs links, compare-link footer. It
predates the now-required visual, closing question, reaction invite, and
community credit, so it is **not** a complete model for those — `example.md` is.
(It links a PR in each header; PR links are fine for traceability, see Step 4.)

## Ground rule: draft from the input, never fabricate

The most common failure of this skill is inventing a specific to fill a slot.
**Never invent** a scenario, docs URL, command syntax, flag, version, metric,
product limit (retention window, quota, deprecation), or requester. If the input
doesn't give you one:

- **ask** the requester for it, or
- mark it inline as **`[VERIFY: what to confirm]`** and carry it into the
  Step 8 handoff block — never present an inferred specific as fact.

For CLI features, verify command syntax against `--help` or docs rather than
guessing flags or argument shapes. This mirrors the gtm-comms agent's hard rule:
never fabricate capabilities or performance claims.

---

## Process

### Step 1 — Gather inputs

From the notes/PRs/commits, pull out (and ask only for what's genuinely
missing rather than filling it in yourself — see the Ground rule):

- **What a user can now do** — the capability, in plain terms.
- **The concrete "so what"** — the real scenario this helps with. It must come
  from the input. If the input gives none, don't invent one: ask, or mark it
  `[VERIFY]` and note it in the handoff block. (Shape it looks like: "useful
  when your upstream routes traffic by hostname — multi-tenant SaaS,
  virtual-hosted buckets, model gateways that key off the request host" — but
  those specifics have to be *true of this feature*, not borrowed.)
- **The docs page** — a `datum.net/docs/...` link **only if it is published and
  live**. A draft/PR-only page is not a URL yet (Step 7).
- **Who to credit, and whether it's safe to name them publicly** — the public
  discussion where a user requested or reported it, *and* whether the requester
  is a community member in a public thread vs. a design partner / NDA / internal
  user (Step 7 credit gate).
- **Media** — a screenshot, GIF, or terminal recording? If not, you'll emit a
  placeholder (Step 6).
- **For a CLI release** — the version, the previous version (compare footer),
  and the real command syntax.
- **Product limits** (retention, quotas, deprecation dates) only if the input
  states them. Never assert a limit the input didn't give.

### Step 2 — Classify the entry (and gate on scope)

| Type | Signal | Shape |
|------|--------|-------|
| **CLI release** | `datumctl vX.Y.Z`, a tag, release notes | Title pairs version + headline feature; hero feature + grouped changes + **compare-link footer** |
| **Feature launch** | one substantial user-facing capability | Benefit title; hero feature section with visual; docs link |
| **Digest / roundup** | several small changes, none a headline on its own | Benefit title (not a grab-bag); **no hero** — go straight to grouped changes |

**A digest may carry a breaking change or security fix** — that alone doesn't
force a hero or a separate post. Render the `### Heads-up` / `### Security` groups
(Step 4) *above* New/Improved/Fixed, and if a breaking change has a hard
deadline, make the title signal it (e.g. name the replacement API). A breaking
change big enough to need its own migration narrative gets its own post instead.

**Scope gate — stop before drafting if:**

- **Not a product change.** Company/marketing news (handbook, website nav,
  design-system, hiring) does **not** belong in the changelog. Redirect to a
  blog post (`gtm-templates`) or drop it.
- **Cosmetic UI change with no capability change** (a footer redesign, a color
  tweak) — not a changelog entry on its own.
- **Too thin to stand alone.** A stub under ~100 words of real substance should
  be **held and merged into the next digest**, not posted by itself.

**The gate holds regardless of who asks.** If someone — including marketing or a
stakeholder — explicitly asked to include out-of-scope content, do **not**
silently drop it and do **not** silently include it. Exclude it from the post,
then name it in the Step 8 handoff block with the right venue (blog, separate
post) so the requester can decide.

### Step 3 — Write the title

Benefit-led **and** feature-named. Sentence case. `datumctl` always lowercase.
The claim must match the feature — don't say "one command" for a three-command
group.

| Do | Don't |
|----|-------|
| `Access logs: debug routing without leaving the dashboard` | `Access logs` (bare noun) |
| `datumctl v0.16.0 — Bring your own plugin catalog` | `datumctl v0.16.0` (version only) |
| `Rewrite the Host header per route` | `AI Edge, Connectors, and Improvements` (vague grab-bag) |

Lead with the payoff, name the feature. Avoid opening every title with
"Introducing X" — vary it. For a CLI release, pair the version with the headline
feature using an em-dash (`—`).

### Step 4 — Draft the body (fixed structure)

Follow `template.md`:

1. **Lead paragraph** — what you can now do + why it matters, 1–2 sentences, in
   "you can now…" voice. No preamble, no "we're excited to announce." For a
   digest, the lead spans the batch: "This release speeds up search, localizes
   log timestamps, and adds CSV export."
2. **Hero feature** — the headline change, with the visual (Step 6) and its
   concrete scenario. Use `###` headings and fenced code for commands/config.
   *A pure digest has no single hero — omit this and go straight to the groups.*
3. **Remaining changes** — grouped under `### New`, `### Improved`, `### Fixed`
   (omit empty groups; one benefit-first line each). The hero is **not** repeated
   under `### New`. Don't restate the lead's scenario verbatim in a group.
4. **Breaking changes / deprecations** — if any, a `### Heads-up` group
   (`> [!IMPORTANT]`) rendered **above** New/Improved/Fixed, stating the
   **migration path** and any **deadline**. Never bury one inside `### Fixed`.
5. **Security fixes** — if any, an explicit `### Security` group, also **above**
   New/Improved/Fixed. Say what was fixed and who should act; do **not** publish
   exploit detail. Link the advisory — or `[VERIFY: add link once published]` if
   it isn't live yet — and credit the reporter only if disclosure is public. Say
   "fix is deployed, no action needed" only if the input supports it; otherwise
   mark it `[VERIFY]`.
6. **Docs deep-links** — one 📖 link per **major/new** feature to a live
   `datum.net/docs/...` page (Step 7). `Improved` and `Fixed` lines don't need
   their own docs link.
7. **Closing** — community credit + a single pointed question (Step 7).
8. **Footer (versioned CLI releases only)** — `**Full changelog:** [vA...vB](compare-url)`.
   An unversioned CLI change inside a digest is just a New/Improved line — no footer.

**Code blocks must use real syntax.** In a CLI post the fenced block is what
users copy — don't invent flags or argument shapes. Verify against `--help`/docs;
if the syntax is unknown, ask or omit the block and flag it in Step 8. When you
can't run `--help`/docs in the drafting environment, keep your best draft of the
block but flag it in the handoff block — that's the expected path, not a blocker.

**Callouts only when earned.** Use `> [!NOTE]` / `> [!IMPORTANT]` for genuine
upgrade or compatibility notes. If there's no real note, omit the callout — don't
manufacture one to match the gold-standard's look.

**Links.** Link live product docs, a CLI compare link, and — for traceability —
the PR(s) that delivered a change if useful. **Never** link internal
work-tracking issues (`enhancements/issues/NNN`) and never end with a bare "View
the details on GitHub" pointing at one — the single most common mistake in past
posts.

### Step 5 — Voice pass: translate engineer-speak to user outcomes

Rewrite anything that describes *how it was built* into *what the user gets*.
Cut internal implementation trivia entirely. The distinction that matters:

- **Internal component/mechanism changed** → cut it. ("Replaced the Express BFF
  with Hono"; "moved to cursor-based pagination"; "reconciled by the controller".)
- **Observable effect on what the user installs or experiences** → keep it,
  user-framed, mechanism dropped. (Smaller download, faster startup, lower
  memory, quicker page loads.)

| Engineer wrote | User reads |
|----------------|------------|
| "Added the `AccessLogConfig` CRD, reconciled by the logging-controller" | "Turn on access logs for any proxy" |
| "reconciliation loop now converges faster" | "changes take effect in seconds" |
| "logs stream from Envoy via the activity pipeline" | "your live traffic shows up in the dashboard" |
| "migrated to a shared transport, binary ~8% smaller" | "the CLI download is about 8% smaller" |
| "p95 query latency down ~70% on large orgs" | "the slowest page loads are about 70% faster" |
| "fixed a token-refresh race condition" | "fixed a bug that could briefly log you out" |

The list is illustrative — the test is whether the term describes *how it's
built*. If a build-side term (CRD, controller, reconcile, webhook, informer,
pagination, transport) survives into the draft, replace it with the outcome.
Literal file/config paths (`~/.config/datumctl/config.yaml`) are plumbing — fold
the effect into prose and drop the path unless the user must type it.

> This is a user-facing artifact, so the general "Kubernetes-native — use
> ecosystem terminology" voice guidance from `gtm-comms` and `gtm-templates`
> deliberately does **not** apply here. Strip the jargon.

### Step 6 — Visuals

Every post needs at least one visual — **except a pure fix/roundup digest**,
where a visual is optional. If you have the media, embed it. If you can't produce
it, emit a clearly marked placeholder so a human captures it before publishing —
describe *exactly* what to show:

```markdown
> 🎬 **VISUAL PLACEHOLDER — capture before publishing**
> Show: filtering the access-log stream by status code, then clicking a 404 to
>       reveal which host/route matched.
> Format: GIF (or terminal recording via asciinema/vhs for CLI features).
> Caption: "Filter to 404s and see the matched route inline."
```

Prefer a GIF or terminal recording for anything interactive; a screenshot is the
floor. A post resting on a placeholder is **ready to hand off for capture**, not
ready to publish (Step 8).

### Step 7 — Docs links, community credit, and one CTA

**Docs — never invent a URL.** Link only a page you can confirm is published and
live. If the docs are drafted but not published (e.g. an unmerged docs PR),
either hold the post until they publish, or emit a placeholder — never guess the
final URL by analogy:

```markdown
> 📄 DOCS PLACEHOLDER — confirm the published URL before posting (draft: <PR link>)
```

Any link that will exist but doesn't yet — a security advisory, a launch blog —
gets the same treatment: mark it `[VERIFY: add link once published]` and add a
handoff row rather than guessing the URL.

**Credit gate.** @-mention **and** link back only when the request/report is in a
**public** discussion **and** the requester is a community member. For a design
partner, an NDA user, an internal user, or a private thread: give **generic**
credit ("thanks to the team who requested this"), no @-mention and no link, or
flag the person in the Step 8 handoff block for a consent check. The creditable
discussion can be a feature request, a public design-partner thread, or a bug
report.

**One CTA.** End with exactly **one** pointed question that invites a *story* or
an opinion, plus a reaction invite. Anti-patterns:

- No compound "and" questions (that's two questions).
- No count/metric fishing ("how many orgs are you juggling?").
- No yes/no questions.
- Nothing that reads like the banned "let us know what you think!" / "tell us
  below!"

Good: "What's the first route you'll add a header rewrite to?"

### Step 8 — "Before publishing" handoff block (required)

Every draft ends with a handoff block listing everything a human must clear
before the post goes live. Include only the rows that apply; omit the block only
if there is genuinely nothing to confirm (rare). Tell the human to delete this
block before posting.

```markdown
> [!WARNING]
> **⚠️ Before publishing — a human must clear these, then delete this block:**
> - **Capture visuals:** <what to record/screenshot>
> - **Confirm docs URLs are live:** <list links; name any that were guessed>
> - **Verify command syntax:** <blocks/flags to check against --help or docs>
> - **Confirm unstated claims:** <every [VERIFY] scenario, metric, or limit>
> - **Consent-check credits:** <named people to confirm are OK to name publicly>
> - **Excluded on scope:** <out-of-scope items dropped + recommended venue>
```

---

## Self-review checklist

Run this before returning the draft. Every rule above is mirrored here — if a
box can't be checked, fix the draft (a checklist that passes a fabricated URL or
a compound CTA is worthless).

- [ ] **Title** is benefit-led *and* names the feature (not a bare noun or vague grab-bag); sentence case; `datumctl` lowercase; the claim matches the feature; version paired with headline for CLI releases.
- [ ] **Lead** is 1–2 sentences in "you can now…" voice — no "excited to announce."
- [ ] **No invented specifics** — every scenario, metric, URL, version, command, and product limit reflects the input or is marked `[VERIFY]` and listed in the handoff block.
- [ ] **Jargon glossed** — no CRD / controller / reconcile / webhook / pagination / transport / BFF or other build-side term survived; observable effects (smaller/faster) kept but user-framed with the mechanism dropped.
- [ ] **Concrete scenario is sourced** — the "useful when…" is true of this feature, not borrowed or inferred as fact.
- [ ] **At least one visual** (or a marked placeholder saying exactly what to capture) — except a pure digest, where it's optional.
- [ ] **Docs URLs confirmed live** — none invented; pending docs (or any not-yet-published link like an advisory/blog) use a placeholder or `[VERIFY]`; one 📖 link per major/new feature (Improved/Fixed don't need one).
- [ ] **No internal issue link** — nothing points at `enhancements/issues/NNN`; PR, compare, and live-docs links are fine.
- [ ] **Breaking changes** get a `### Heads-up` group (migration path + any deadline) and **security fixes** an explicit `### Security` group — both rendered above New/Improved/Fixed, without exploit detail; a hard-deadline breaking change is signaled in the title.
- [ ] **Credit is safe** — any @-mention is a public community member from a public discussion; design partners/NDA/internal get generic credit or a consent-check in the handoff block.
- [ ] **Exactly one CTA question** — no compound "and", no count/metric fishing, no yes/no; invites a story; no "let us know!" / "tell us below!"
- [ ] **CLI releases** carry a `Full changelog:` compare-link footer, and code blocks use verified syntax (or the block is omitted and flagged).
- [ ] **Scope is clean** — no marketing/company/cosmetic-UI content silently included; anything a stakeholder asked for but that's out of scope is excluded and surfaced in the handoff block.
- [ ] **Handoff block present** listing every visual, unconfirmed URL, syntax, `[VERIFY]` claim, credit to consent-check, and excluded item.

---

## Related

- `gtm-templates` — Keep-a-Changelog *release file* format and other GTM
  templates; complementary, not a substitute. `template.md` and `example.md`
  here cover the fill-in skeleton and a full worked run.
