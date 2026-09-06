---
name: pr-review-loop
description: >
  Runs two read-only opus reviewers with different angles on a pull request,
  compares their verdicts, and either spawns the fixer to carry the PR to
  auto-merge or puts the choice to a human. Trigger on "review this PR",
  "double review", "two reviewers", "run the review agents", "I just opened a
  PR", "check this before it merges", and on the session opening any pull
  request itself, including one opened by a subagent.
---

# PR Review Loop

A session that writes a change is the worst judge of it. This skill runs two reviewers that do not know about each other on every pull request the session opens, then acts on what they agree on and asks a person about the rest.

The reviewers are agents, so their model pin, tool allowlist, and read-only posture hold every time they run. This skill is the protocol around them, and it holds only when the session follows it. Follow it.

## When to run

Run the loop on every pull request this session opens, including one a subagent opened on the session's behalf. Run it when the user asks with any of the trigger phrases above, or types `/pr-review`. A subagent that opens a PR can run the loop itself, since a subagent can spawn subagents, and does not need to come back to the main session first.

The unit of review is one PR against one base SHA. A push after the review ran means a new review.

## Cost caps

Each reviewer costs roughly 100k to 160k tokens and the pair plus the fixer adds ten to fifteen minutes of wall time per PR. Both reviewers run at once, so the wall time is one review, not two. That is cheap next to one broken reconcile and expensive on a typo, so:

- **Nothing deployable changed.** A diff confined to Markdown, a changelog, or comments gets `pr-conventions-reviewer` alone.
- **Trivial diff.** Under about twenty changed lines in a single file gets one reviewer: `pr-adversary` when the file deploys, `pr-conventions-reviewer` when it does not.
- **Never skip on reach.** Any diff that touches a shared base, a production overlay, a cluster overlay that tracks trunk, or an alert rule gets both reviewers regardless of size. Blast radius decides, not diff size.
- **Run in the background.** Keep working while the reviews run and pick them up when they land. Both reviewer agents carry `background: true`.

When one reviewer is skipped, the agreement conditions in `protocol.md` cannot all hold, because they need two finished reports. A single-reviewer run is advisory: report its findings and verdict to the user and do not spawn the fixer without their say.

## Launch

Read the PR number and base SHA first:

```
gh pr view <n> --json number,baseRefOid,headRefOid,headRefName,baseRefName,url
```

Launch both reviewers in the same message so they run at once, each with `subagent_type` set to the plugin-scoped agent name and `run_in_background` on. Give each the same prompt:

```
Review PR #<n> in <owner>/<repo>. Base SHA <baseRefOid>, head SHA <headRefOid>,
branch <headRefName> against <baseRefName>. Return findings and a verdict in
the shape your definition gives. Post nothing to GitHub.
```

Do not tell either reviewer what the other is doing, and do not pass either one's report to the other.

While they run, keep working. When both notifications arrive, read both reports in full.

## Compare and act

Apply `protocol.md`. In short: check the five agreement conditions and the always-escalate list, then either spawn `pr-review-fixer` with both reports and say in one line what it is doing, or put the choice to the user with a recommendation and act on the answer.

Never post a reviewer's report to GitHub yourself. The fixer posts one comment at the end of its path, and that is the only comment the loop produces.

## Output contract

Both reviewers return the same shape, defined once in `protocol.md`: one line per finding as `<path>:<line>: <severity>: <problem>. <fix>.`, then `VERDICT: merge|hold. <reason>`. Severity is `blocker`, `warning`, `nit`, or `decision`, and `decision` is what routes a review to a person rather than to the fixer.

## Files

- `protocol.md`: the output contract, the severity table, the five agreement conditions, the always-escalate list, and the fix and ready path.
- `agents/pr-adversary.md`, `agents/pr-conventions-reviewer.md`, `agents/pr-review-fixer.md`: the three agents this skill drives.
- `commands/pr-review.md`: the `/pr-review` entry point.
