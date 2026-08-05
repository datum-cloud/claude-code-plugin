---
name: pr-conventions
description: Covers GitHub conventions for pull requests, issues, and comments including linking, language style, formatting, and callout syntax. Use when creating PRs, writing issues, or posting comments on Datum Cloud repositories.
---

# GitHub Conventions

Rules for PR, issue, and comment bodies in every `datum-cloud`, `milo-os`, and
`datum-labs` repository. The `pr-op-gate` hook enforces the countable ones on
`gh pr|issue create|edit` and blocks the call when a body misses them.

## The bar

Countable, so it can be checked rather than believed:

| Limit | Applies to |
|---|---|
| Summary: **4 sentences or fewer** | PR and issue bodies, before the next heading |
| Test plan: **4 checkboxes or fewer** | PRs; behavioral outcomes only, build/lint/test collapse to one row |
| **No** file paths, identifiers, per-file breakdowns, or local tool invocations | PR and issue bodies |
| **No** hard-wrapped prose | everywhere on GitHub |
| Callouts only for a caveat that changes what a reader would do | everywhere |

Target: a reader with no context grasps the why in 30 seconds. Depth goes in a
comment or the commit message, where length costs nothing.

## Writing rules

Orwell, applied:

1. Cut every word that carries no fact. Compress, never omit.
2. Short word over long. Active over passive.
3. No stale metaphor, no jargon with an everyday equivalent.
4. Break any rule sooner than write something barbarous.

[Google's technical writing rules](https://developers.google.com/tech-writing),
applied:

1. One idea per paragraph. Short sentences.
2. Name the audience before writing. Most readers do not work on this codebase.
3. Define a term the first time you use it, or drop the term.
4. Lists for sequences, tables for comparison, prose for reasoning.
5. Delete "simply", "just", "easily", "obviously" — they only tell a stuck
   reader they are stupid.

**Say it once.** Never describe the same behaviour in prose and again in a
checklist. Never restate the summary in the test plan. Anything already in the
linked issue gets linked, not restated.

**Don't hard-wrap.** GitHub reflows Markdown. Fixed-column wrapping produces
ragged lines that are awkward to edit. Wrap only where syntax needs it — lists,
tables, code fences. Hard-wrapping belongs in commit messages alone.

## Structure

PR body:

```markdown
## Summary

<Problem first. Then what changes for users or operators, and why this way.>

## Test plan

- [ ] <Observable outcome>

Fixes #<issue>
```

Issue body: what needs to happen, why it matters, what success looks like.
Outcome-focused acceptance criteria — "a user can do X", not "the handler calls
Y". Keep the solution out of the description; it belongs in comments.

Add `## Breaking changes` when something downstream must migrate. Add
`## Screenshots` for UI work. Omit empty sections.

## Titles

Conventional prefix (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`),
imperative mood, capitalized after the colon, no trailing period, under 72
characters. Describe the outcome, not the mechanism.

**Good:** `feat: Show activity timeline on the resource dashboard`
**Avoid:** `feat: Add ActivityFeed component with websocket polling`

Issue titles state the symptom in plain language: `Users can't see who last
modified a resource`, not `NullPointerException in ResourceController`.

## Linking

Every PR links the issue it addresses. Required.

| Keyword | Use when |
|---|---|
| `Fixes #n` / `Resolves #n` | merging should close the issue |
| `Related to #n` | connected, but does not fully address it |

Never `Closes` — closing is deliberate. Cross-repo references need `org/repo#n`
or a full URL; a bare `#n` resolves in the current repo only. A bare issue or PR
URL renders as a titled, state-aware chip, so prefer it over `[here](url)`.

## Comments

Comments carry the depth the description sheds — tradeoffs, alternatives,
questions. Plain prose. No headers; a header means the content belonged in the
description. No tables except a genuine side-by-side comparison of options.

Only @-mention handles grounded in the repo — CODEOWNERS, the commit history,
existing reviewers — or ones the requester names. When unsure, omit.

## Callouts

`> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`.
Never an emoji header (`## ⚠️ ...`). If everything is highlighted, nothing is.

## Example

```markdown
## Summary

Users had no way to see recent activity on a resource, so understanding what changed meant reading audit logs. The resource detail page now shows the last 20 actions, newest first, drawn from the existing Activity API.

## Test plan

- [ ] Timeline paginates and renders empty and error states
- [ ] Resources predating activity tracking degrade without crashing

Fixes #234
```
