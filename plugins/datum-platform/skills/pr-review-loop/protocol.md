# PR Review Protocol

The contract both reviewers return, the conditions under which the session acts on its own, and the path the fixer walks. `pr-adversary`, `pr-conventions-reviewer`, and `pr-review-fixer` all read this file, so the definition lives here once.

## Output contract

One line per finding, then one verdict line, then a `RAN:` list of what the reviewer executed.

```
<path>:<line>: <severity>: <problem>. <fix>.
VERDICT: merge|hold. <the single most important reason>
```

No praise, no restating the PR body, no prose between findings. A PR with nothing wrong returns a bare verdict. A finding with no file uses the PR number as the path and `0` as the line.

| Severity | Meaning | Routes to |
|---|---|---|
| `blocker` | Merging as is breaks something, fails to do what the body claims, reaches somewhere the body does not admit, or misses a rule the gate enforces | fixer |
| `warning` | Real problem, merge survivable, fix before or soon after | fixer |
| `nit` | Small and safe to defer | fixer |
| `decision` | A person has to choose | human |

## The five agreement conditions

The session acts without asking only when both reviews agree cleanly. All five have to hold:

1. **Both reviewers finished.** A timeout, a truncated report, or a report with no verdict line is not an opinion.
2. **Same verdict.** Both `merge`, or both `hold`.
3. **No `decision` finding** from either reviewer.
4. **The fixes are compatible.** Neither reviewer asks to remove what the other asks to add, and neither wants a file the other wants left alone.
5. **Neither reviewer questions the premise.** Neither says the PR should be closed, split, or rewritten to a different goal.

When all five hold, spawn `pr-review-fixer` for its fix phase with the PR number, the repository, the base branch, both reports in full, and the findings to apply, and say in one line what it is doing. The fixer applies every finding that is not a `decision`, whatever the verdicts were: two `merge` verdicts with warnings still get their warnings fixed. Both `merge` with no findings, or with nothing above `nit`, means the fixer goes straight through to the ready path in one run.

When any condition fails, put the choice to the human with a recommendation, then act on the answer.

## Always escalate

Whatever the verdicts say, these go to a person:

- A finding about ownership: which team or repository owns the thing being changed.
- A naming choice that outlives the PR.
- Whether a change that reaches a shared base ships now or waits behind a staging soak.
- Splitting a PR, closing it, or reopening a question the issue already settled.
- A reviewer that could not run the check it needed, so hedged. A hedge is not agreement.

A reviewer tags each of these `decision`, which fails condition 3. The session checks the list anyway, because a reviewer can describe one of these in a `warning` by mistake.

## The fix and ready path

Once the boundary is clear, the fixer's fix phase:

1. Applies the findings in the worktree that already holds the PR branch, found with `git worktree list`, never in a shared checkout and never through `isolation: worktree`.
2. Commits signed, one commit per coherent change, message wrapped at 80 and shaped by `commit-conventions`. Never passes a flag that skips signing.
3. Rewrites the body if a reviewer said to, which sends it back through `pr-op-gate` on the way out.
4. Pushes and returns the new head SHA to the session.

## The re-review

If the fix phase changed anything tagged `blocker` or `warning`, the session fetches the new head and launches both reviewers once more on it, with the same prompt shape and the same five conditions. The ready path unlocks only when that second pass returns two `merge` verdicts, or two `hold` verdicts with nothing left above `nit`.

This is one re-review, not a loop. A second pass that still holds a `blocker` or `warning`, or that fails any of the five conditions, goes to the human with both reports and a recommendation. A fix phase that touched only `nit` findings, or had nothing to apply, needs no second pass and continues into the ready path in the same run.

Then the fixer's ready phase:

5. Waits for CI green on the head.
6. Runs `gh pr ready`, which is what makes GitHub request the CODEOWNERS teams.
7. Requests the configured human reviewer, if one is configured.
8. Enables auto-merge with the merge method the repository's ruleset allows.
9. Posts one comment on the PR recording both verdicts and what each reviewer ran, so the human approver sees what was already checked.

## Guards the path relies on

**Auto-merge is enabled in every repository, and a guarded branch keeps a human in front of it.** A ruleset that requires an approving review, a code-owner review, and approval of the last push, and dismisses stale reviews on every push, means the fixer's push always lands in front of a human, and the step 9 comment is what that human reads first. Where the base branch's ruleset has no review requirement, auto-merge can complete on CI alone, and the comment says so in one line.

**The human reviewer comes from the repository, never from a guess.** The fixer reads `prReview.humanReviewer` from the repository's `.claude/settings.json`, guarding for a repository that has no such file. Absent means request nobody beyond the code owners. No handle is ever invented or taken from history.

**The merge method comes from the ruleset, never from the repository flags.** The fixer reads `gh api repos/{owner}/{repo}/rules/branches/<base>` and uses the method the `pull_request` rule allows. When the endpoint returns no `pull_request` rule, the fallback is `--merge`. The repository API's `allow_squash_merge` and related flags report a setting the ruleset overrides.

**Reviewers never write.** Both reviewer agents carry an enumerated read-only allowlist, which scopes what runs without a prompt, and the plugin registers a `PreToolUse` hook that fires only for those two agents and refuses any `gh api` call with a method or body flag and any shell wrapper such as `eval`, `sh -c`, or `xargs` around `gh`. Neither reviewer fetches, and neither posts to GitHub. The only GitHub writes the loop produces are the fixer's.
