# Changelog Post Template

Fill in the placeholders. Delete any section that doesn't apply (e.g. omit an
empty `### Improved` group, the hero for a pure digest, or the compare-link
footer for a non-CLI post). Notes in `<!-- ... -->` are guidance — remove them
from the final post. Never invent a value to fill a slot: if the input doesn't
give it, ask or mark it `[VERIFY: ...]` and list it in the handoff block.

---

## Title

```
<Benefit-led, feature-named title in sentence case>
```

<!--
  Feature launch: "Access logs: debug routing without leaving the dashboard"
  CLI release:    "datumctl v0.16.0 — Bring your own plugin catalog"
  Digest:         "Faster search, localized timestamps, and CSV export"
  NOT: a bare noun ("Access logs") or a vague grab-bag ("AI, Connectors, and Improvements").
-->

## Body

```markdown
<!-- LEAD: 1–2 sentences, "you can now…" voice. What you can do + why it matters. -->
You can now <capability> — <why it matters to the reader>.

<!-- HERO FEATURE: the headline change. OMIT for a pure digest (no single hero). -->
### <Headline feature, benefit-first>

<One or two sentences on what it does.> Useful when <concrete "so what"
scenario FROM THE INPUT — mark [VERIFY] if the input didn't give one>.

> 🎬 **VISUAL PLACEHOLDER — capture before publishing**
> Show: <exactly what to demonstrate>.
> Format: <GIF | terminal recording | screenshot>.
> Caption: <one-line caption>.

<!-- Optional fenced example: a command or config the reader would actually run.
     CLI syntax must be REAL — verify against --help/docs, don't invent flags. -->
```bash
datumctl <verified example command>
```

> [!NOTE]
> <A genuine upgrade/compatibility note, if any. Omit the callout if there isn't one.>

<!-- DOCS: link only if the page is published and live. If not, use the placeholder. -->
📖 [<Docs link text>](https://datum.net/docs/<path>)
> 📄 DOCS PLACEHOLDER — confirm the published URL before posting (draft: <PR link>)

<!-- REMAINING CHANGES: keep only the groups that have items. One line each,
     benefit-first. Do NOT repeat the hero here. -->
### New

- **<Change>** — <what the user gets>. 📖 [<docs>](https://datum.net/docs/<path>)

### Improved

- **<Change>** — <what's better now, in user terms>. <!-- no docs link needed -->

### Fixed

- **<Change>** — <the symptom the user no longer hits>.

<!-- HEADS-UP: only if there's a breaking change / deprecation / removal. -->
### Heads-up

> [!IMPORTANT]
> **<What's changing and by when.>** <Migration path: what the reader must do,
> and the deadline if there is one.>

<!-- SECURITY: say what was fixed and who should act; NO exploit detail.
     Link the advisory / credit the reporter only if disclosure is public. -->

<!-- CLOSING: community credit + ONE pointed question + reaction invite. -->
Thanks to @<username> for <requesting/reporting> this in <#public-discussion-link>.
<!-- @-mention + link only a PUBLIC community member from a PUBLIC discussion.
     Design partner / NDA / internal → generic credit, no @-mention, no link. -->

<A single story-inviting question — no compound "and", no count/metric, no yes/no.>
React with 👍 if <…>.

<!-- FOOTER: CLI releases only. -->
**Full changelog:** [v<A>...v<B>](https://github.com/datum-cloud/<repo>/compare/v<A>...v<B>)

<!-- HANDOFF: required. List everything a human must clear, then they delete this block. -->
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

## Section reference

| Section | Required? | Notes |
|---------|-----------|-------|
| Lead paragraph | Always | 1–2 sentences, "you can now…", no "excited to announce" |
| Hero feature (`###`) | Always, except a pure digest | The headline change + the visual + a sourced scenario |
| Visual placeholder | Always, except a pure digest | Say exactly what to capture and in what format |
| `### New / Improved / Fixed` | If there are secondary changes | Omit empty groups; one benefit-first line each; don't repeat the hero |
| `### Heads-up` (`> [!IMPORTANT]`) | If there's a breaking change/deprecation | Migration path + deadline |
| Security wording | If there's a security fix | What/who, no exploit detail; credit only if disclosure is public |
| 📖 docs link | One per major/new feature | Confirmed-live `datum.net/docs/...`, or a DOCS PLACEHOLDER — never invented |
| Community credit | When someone requested/reported it | @-mention + link only a public community member from a public discussion |
| Closing question | Always | One story-inviting question + reaction invite |
| Compare-link footer | CLI releases only | `compare/vA...vB` |
| Handoff block (`> [!WARNING]`) | Always (unless nothing to confirm) | Everything a human must clear before publish |
