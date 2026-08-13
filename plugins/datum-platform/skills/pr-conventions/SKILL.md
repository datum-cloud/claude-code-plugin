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
| Summary: **4 sentences or fewer**, in paragraphs of **one or two sentences** | PR and issue bodies, before the next heading |
| Test plan: **4 checkboxes or fewer** | PRs; behavioral outcomes only, build/lint/test collapse to one row |
| **No** file paths, identifiers, per-file breakdowns, or local tool invocations | PR and issue bodies |
| **No** hard-wrapped prose | everywhere on GitHub |
| **No** em dashes, and none of the banned phrases below | everywhere |
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
5. Delete "simply", "just", "easily", "obviously". They only tell a stuck
   reader they are stupid.

**Say it once.** Never describe the same behaviour in prose and again in a
checklist. Never restate the summary in the test plan. Anything already in the
linked issue gets linked, not restated.

**Don't hard-wrap.** GitHub reflows Markdown. Fixed-column wrapping produces
ragged lines that are awkward to edit. Wrap only where syntax needs it: lists,
tables, code fences. Hard-wrapping belongs in commit messages alone.

**Cadence.** Break prose into many short, single-idea paragraphs. One-sentence
paragraphs are good.

The summary's four-sentence budget is four paragraphs, not one block of four
sentences. Give each beat its own paragraph, and pair two sentences only where
splitting them would strand one. A four-sentence block passes the count and
still reads as a wall.

A dense block that packs setup, mechanism, and consequence together gets split
so each beat stands alone and a reader can skim. The shape that works: the
problem, how it fails, what should have prevented it, the gap, what this change
does, why it matters. Use a bulleted list for any enumerable beat rather than
packing the items into a comma-run, and let prose carry the narrative.

## Banned words and punctuation

| Banned | Write instead |
|---|---|
| Em dash (`—`) | A period, a comma, or nothing. Reserve it for the rare case where neither works. |
| "load-bearing" | Name the dependency. "That silence is load-bearing" becomes "those alerts evaluate against series nothing produces, so they cannot fire." |
| "gotchas" | Caveats, watch-outs, constraints, limitations. Applies to headings too. |
| Arrows (`→`, `->`) for a sequence | An ordered list. Arrows for a simple mapping or rename are fine; prefer a preposition when one reads well. |

Stacked em dashes read as a verbal tic and blur where one thought ends and the
next begins. A period forces the sentence to finish. "Load-bearing" gestures at
importance without saying what depends on the thing or what breaks without it.

## Naming a cause

State a cause in an issue, a PR, or a comment only when the evidence
discriminates: it has to explain why the broken cases broke *and* why the
working cases worked. "Consistent with the facts" is not the same as explaining
the difference between the case that failed and the case that didn't.

When two groups behave differently, diff their API objects field by field
before theorizing. `gh api repos/<owner>/<repo>/pulls/<n>` carries fields the UI
and `gh pr view` never show.

Say plainly what remains unknown rather than smoothing the gap over.

## Structure

PR body:

```markdown
## Summary

<The problem, in one sentence.>

<How it fails, or why it matters.>

<What this change does.>

<The caveat or the limit, if there is one.>

## Test plan

- [ ] <Observable outcome>

Fixes #<issue>
```

Issue body: what needs to happen, why it matters, what success looks like.
Outcome-focused acceptance criteria: "a user can do X", not "the handler calls
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

Never `Closes`, because closing is deliberate. Cross-repo references need
`org/repo#n` or a full URL; a bare `#n` resolves in the current repo only. A
bare issue or PR URL renders as a titled, state-aware chip, so prefer it over
`[here](url)`.

`Related to` does **not** auto-close on merge. After a batch of PRs lands, close
each shipped issue by hand (`gh issue close --reason completed --comment ...`)
and reconcile any tracker. Verify against issue state, not PR state.

## Lifecycle

Open every PR as a draft (`gh pr create --draft`) unless the requester asks for
it ready. Review and CI should settle before a PR is marked ready.

**Superseding a stale PR.** When a PR sits many commits behind trunk, often with
most of its content already landed through siblings, branch fresh from
`origin/main`, port only what is genuinely unique to it, and open a new PR. Then
comment `Superseded by #NNN` on the old one and close it. Never force-push over
the original author's branch.

**Fanning out PR-opening agents.** Give each writer its own worktree
(`isolation: "worktree"`). Concurrent writers sharing one working tree race on
branch checkout, commit, and push, and one agent's commit lands on another's
branch. Pin the base SHA once up front and hand every agent the literal SHA so
the batch shares a known base. Give each one a stop-and-report escape for when
the premise does not hold. Read-only agents need none of this.

## Comments

Comments carry the depth the description sheds: tradeoffs, alternatives,
questions. Plain prose. No headers; a header means the content belonged in the
description. No tables except a genuine side-by-side comparison of options.

Only @-mention handles grounded in the repo (CODEOWNERS, the commit history,
existing reviewers) or ones the requester names. Never invent a handle. When
unsure, omit the mention entirely.

**Evaluations are the exception to the no-headers rule.** A survey, review, or
multi-part evaluation is a deliverable in its own right, and readers need to
skim to the section they care about. Post it as one comment with `##` headers,
never split across several comments. When a later turn adds a dimension, fold it
into the existing comment rather than appending a new one:

```
gh api --method PATCH repos/<owner>/<repo>/issues/comments/<id> -F body=@file.md
```

**Corrections are one line.** When a claim you posted turns out to be wrong,
state the correction and the evidence that settles it in a single sentence. A
reader arriving at the thread needs the current answer, not the archaeology of
how you got it wrong. Hide the superseded comment as `outdated` instead of
deleting it, which collapses the wrong turn while leaving it auditable:

```
cid=$(gh api repos/<owner>/<repo>/issues/comments/<id> --jq .node_id)
gh api graphql -f query='mutation($id:ID!){minimizeComment(input:{subjectId:$id,classifier:OUTDATED}){minimizedComment{isMinimized}}}' -f id="$cid"
```

Rewrite the issue title and opening post to the corrected framing too. A stale
title outlives every comment.

## Callouts

`> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`.
Never an emoji header (`## ⚠️ ...`). If everything is highlighted, nothing is.

## When the gate blocks a body you did not write

`pr-op-gate` measures the whole body on `gh pr|issue edit`, so ticking a
checkbox on an opening post written before the gate existed gets refused for
violations already in that body. Rewriting the post to satisfy the gate would
destroy the substance it exists to carry.

Never route around the gate on a body you are authoring; fix those. For a state
update to a body whose violations predate your change, diff the edit against the
live body to show it is mechanical, apply it through the API, and say in your
reply that the gate was bypassed and why. The silence is the thing to avoid, not
the routing.

```
gh api -X PATCH /repos/{owner}/{repo}/issues/{n} -F body=@file
```

Whole-body prose rewrites do not need this. Reach for the API route only when
the gate actually refuses.

## Example

```markdown
## Summary

Users had no way to see recent activity on a resource, so understanding what changed meant reading audit logs.

The resource detail page now shows the last 20 actions, newest first, drawn from the existing Activity API.

## Test plan

- [ ] Timeline paginates and renders empty and error states
- [ ] Resources predating activity tracking degrade without crashing

Fixes #234
```
