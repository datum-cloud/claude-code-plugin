---
name: github-conventions
description: Covers GitHub conventions for pull requests, issues, and comments including linking, language style, formatting, and callout syntax. Use when creating PRs, writing issues, or posting comments on Datum Cloud repositories.
---

# GitHub Conventions

This skill covers how to work with GitHub effectively — writing pull requests, issues, and comments that are clear, user-friendly, and easy to act on.

## Core Principles

- Write for humans, not machines. Avoid jargon unless the audience is explicitly technical.
- **Say it once.** Do not describe the same behaviour in prose and again in a checklist, or restate the summary in the test plan. Reference it instead.
- **Cut every word carrying no fact.** One dense paragraph beats three that re-sell the same point. Brevity must not drop facts — compress, do not omit.
- Focus on goals and outcomes, not implementation details.
- Use comments to add depth — keep the primary description focused.
- Close issues deliberately. Linking is not closing.
- Don't hard-wrap prose. GitHub renders Markdown and reflows paragraphs on its own, so insert line breaks only where the syntax needs them (lists, tables, code fences, callouts). Manually wrapping text at a fixed column (e.g. 80 characters) produces ragged lines that reflow badly and are awkward to edit. Hard-wrapping belongs in commit messages, not in PR descriptions, issues, or comments.

---

## Pull Requests

### Title

PR titles should be short, plain-language descriptions of what the change delivers.

| Rule | Guidance |
|------|----------|
| Use conventional prefix | `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:` |
| Imperative mood | "Add feature" not "Added feature" |
| Capitalize after colon | Begin with capital letter |
| No period at end | Cleaner appearance |
| Keep concise | Under 72 characters |
| Avoid technical detail | Describe the outcome, not the implementation |

**Good:** `feat: Show activity timeline on the resource dashboard`
**Avoid:** `feat: Add ActivityFeed component with websocket polling and pagination`

### Linking to Issues

Every PR must link to the issue it addresses. This is required, not optional.

```markdown
Fixes #123
```

Use the appropriate keyword based on intent:

| Keyword | When to use |
|---------|-------------|
| `Fixes #n` | This PR resolves the issue — use when you intend to close it |
| `Resolves #n` | Same as Fixes — an alternative |
| `Related to #n` | The PR is connected but does not fully address the issue |

> [!IMPORTANT]
> Never use `Closes` or `Closed`. Closing an issue is a deliberate action — use `Fixes` or `Resolves` only when you are certain the issue should be closed when this PR merges.

If the PR relates to multiple issues or other PRs, link all of them:

```markdown
Fixes #123
Related to #456
Related to #789
```

### Description

Write descriptions for someone who hasn't been following the work. Lead with context, not implementation.

**Required sections:**

```markdown
## Summary

<Describe the problem in 1–2 sentences. Then explain what this PR does and why it matters.>

## Test plan

- [ ] <Specific scenario tested>
- [ ] <Edge case considered>

Fixes #<issue>
Related to #<other work>
```

**Summary guidance:**
- Open with the problem or goal, not what files were changed
- Explain why this approach was chosen if it isn't obvious
- Use bullets only for discrete outcomes that benefit from scanning — lead with prose

**Conditional sections:**

Add a `## Breaking changes` section if anything downstream needs to update. Describe what breaks and how to migrate, in plain terms.

For UI changes, include a `## Screenshots` section with before/after.

### Writing Style

Write like you're explaining the change to a teammate. Non-technical stakeholders may read PRs — avoid assuming deep technical context unless the PR is explicitly internal.

| Use prose for | Use bullets for |
|---------------|-----------------|
| Problem description | Discrete test scenarios |
| Context and rationale | Breaking changes list |
| How components relate | Key observable behaviors |

### What to Avoid

| Avoid | Why |
|-------|-----|
| `Closes` / `Closed` keyword | Use `Fixes` or `Resolves` deliberately |
| PRs without an issue link | Every change should trace to intent |
| Technical jargon in summaries | Not all readers have the same context |
| Bullet-point-only summaries | Lead with prose for orientation |
| Test-plan items that restate the summary | The test plan says what you verified, not what you wrote |
| Paragraphs re-selling a point already made | Say it once, densely |
| Hard-wrapping prose at a fixed column | GitHub reflows Markdown — wrap only where syntax requires |
| Tool attribution / watermarks | Clutters the PR |
| Empty sections | Omit optional sections rather than leaving them blank |

---

## Issues

### Title

Issue titles should clearly describe what needs to happen or what is going wrong — in plain language.

**Good:** `Users can't see who last modified a resource`
**Avoid:** `NullPointerException in ResourceController.getOwner()`

### Description

Issue descriptions should focus on **goals and desired outcomes**, not implementation approaches. Keep them concise. Use comments for detailed discussion.

**Structure:**

```markdown
## What needs to happen

<Describe the goal or problem in plain language. What should be true when this is done?>

## Why this matters

<Optional: Who is affected and what is the impact?>

## Desired outcome

<What does success look like? What can a user do that they couldn't before, or what stops happening?>
```

**Guidance:**
- Write for someone unfamiliar with the internals
- Avoid prescribing the solution in the description — that belongs in comments
- If you have acceptance criteria, keep them outcome-focused: "A user can do X" not "The handler must call Y"

> [!NOTE]
> Implementation approaches and technical discussion belong in comments, not the issue description. Keep the description stable and focused on the "what" and "why."

### Linking Related Work

Link related issues, PRs, and context using descriptive text:

```markdown
Related to #456
See also: [Rate limiting investigation](#789)
```

Always prefer descriptive link text over bare URLs or raw issue numbers when linking to external resources.

---

## Comments

### Purpose

Comments are for depth — elaborating on approaches, surfacing tradeoffs, asking questions, and discussion. The issue or PR description captures the "what"; comments capture the "how" and the conversation around it.

### Formatting

Keep comments conversational. Avoid heavy formatting unless it genuinely aids clarity.

- Use plain prose for most comments
- Use a simple list only when enumerating discrete options or steps
- Avoid headers in comments — they suggest the content belongs in the description instead
- Never use tables in comments unless you're comparing multiple options side by side

### Callouts

Use [GitHub's callout syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts) to highlight key points:

```markdown
> [!NOTE]
> Something the reader should be aware of but won't block progress.

> [!TIP]
> A helpful suggestion or shortcut.

> [!IMPORTANT]
> Something the reader must know to proceed correctly.

> [!WARNING]
> Something that could cause problems if overlooked.

> [!CAUTION]
> A risk of data loss, breakage, or significant consequence.
```

Use callouts sparingly. If everything is highlighted, nothing is.

### Links

Always use descriptive link text. A reader should understand where a link goes before clicking.

**Good:** `See the [rate limiting design doc](link) for context.`
**Avoid:** `See this: https://...` or `See [here](link).`

This applies everywhere in GitHub — issues, PRs, and comments.

---

## Examples

### Good PR Description

```markdown
## Summary

Users had no way to see recent activity on their resources, making it hard to understand what changed and when. This adds an activity timeline to the resource detail page that shows the last 20 actions in reverse chronological order.

The timeline uses the existing Activity API, so no backend changes are required.

## Test plan

- [ ] Timeline renders correctly with activity data
- [ ] Empty state displays when there is no activity
- [ ] Pagination loads additional items on scroll
- [ ] Error state handles API failures without crashing

Fixes #234
Related to #198
```

### Good Issue Description

```markdown
## What needs to happen

Team members need to see who last modified a resource and when, so they can understand recent changes without digging through audit logs.

## Desired outcome

The resource detail page shows a "last modified by" line with the user's name and a relative timestamp (e.g., "Modified by Dana 2 hours ago").
```

### Good Comment

```markdown
Two approaches here — we could pull this from the activity log on read, or store it directly on the resource. Storing directly is simpler and faster to query, but means we'd need a migration. Pulling from the activity log avoids schema changes but adds latency.

> [!NOTE]
> The activity log approach will break if a resource predates activity tracking (anything created before March 2025).

I'd lean toward storing it directly. Happy to discuss if there's a reason to avoid the migration.
```
