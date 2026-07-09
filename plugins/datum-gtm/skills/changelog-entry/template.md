# Changelog Post Template

Fill in the placeholders. Delete any section that doesn't apply (e.g. omit an
empty `### Improved` group, or the compare-link footer for a non-CLI post).
Notes in `<!-- ... -->` are guidance — remove them from the final post.

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

<!-- HERO FEATURE: the headline change. -->
### <Headline feature, benefit-first>

<One or two sentences on what it does.> Useful when <concrete "so what"
scenario the reader will recognize — a real workflow, not a category>.

> 🎬 **VISUAL PLACEHOLDER — capture before publishing**
> Show: <exactly what to demonstrate>.
> Format: <GIF | terminal recording | screenshot>.
> Caption: <one-line caption>.

<!-- Optional fenced example: a command or config the reader would actually run. -->
```bash
datumctl <example command>
```

> [!NOTE]
> <Upgrade, compatibility, or "no action needed" note, if any.>

📖 [<Docs link text>](https://datum.net/docs/<path>)

<!-- REMAINING CHANGES: keep only the groups that have items. One line each, benefit-first. -->
### New

- **<Change>** — <what the user gets>. 📖 [<docs>](https://datum.net/docs/<path>)

### Improved

- **<Change>** — <what's better now, in user terms>.

### Fixed

- **<Change>** — <the symptom the user no longer hits>.

<!-- CLOSING: community credit + ONE pointed question + reaction invite. -->
Thanks to @<username> for <requesting/reporting> this in <#discussion-link>.

<A single pointed question that invites a specific reply.> React with 👍 if <…>.

<!-- FOOTER: CLI releases only. -->
**Full changelog:** [v<A>...v<B>](https://github.com/datum-cloud/<repo>/compare/v<A>...v<B>)
```

---

## Section reference

| Section | Required? | Notes |
|---------|-----------|-------|
| Lead paragraph | Always | 1–2 sentences, "you can now…", no "excited to announce" |
| Hero feature (`###`) | Always | The headline change + the visual + a concrete scenario |
| Visual placeholder | Always (unless media embedded) | Say exactly what to capture and in what format |
| `### New / Improved / Fixed` | If there are secondary changes | Omit empty groups; one benefit-first line each |
| 📖 docs link | One per feature | `datum.net/docs/...` — never an internal issue link |
| Community credit | When someone requested/reported it | @-mention + link the Feature Request discussion |
| Closing question | Always | One pointed question + reaction invite |
| Compare-link footer | CLI releases only | `compare/vA...vB` |
