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

When all five hold, spawn `pr-review-fixer` with the PR number, the repository, the base branch, both reports in full, and the findings to apply, and say in one line what it is doing. Both `merge` with no findings means the fixer skips straight to the ready path. Both `hold` with compatible findings means the fixer applies them and then runs the ready path.

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

Once the boundary is clear, the fixer:

1. Applies the findings in the worktree that already holds the PR branch, found with `git worktree list`, never in a shared checkout and never through `isolation: worktree`.
2. Commits signed, one commit per coherent change, message wrapped at 80 and shaped by `commit-conventions`. Never passes a flag that skips signing.
3. Rewrites the body if a reviewer said to, which sends it back through `pr-op-gate` on the way out.
4. Pushes and waits for CI green on the new head.
5. Runs `gh pr ready`, which is what makes GitHub request the CODEOWNERS teams.
6. Requests the configured human reviewer, if one is configured.
7. Enables auto-merge with the merge method the repository's ruleset allows.
8. Posts one comment on the PR recording both verdicts and what each reviewer ran, so the human approver sees what was already checked.

## Guards the path relies on

**Auto-merge cannot fire unaided on a guarded branch.** A ruleset that requires an approving review, a code-owner review, and approval of the last push, and dismisses stale reviews on every push, means the fixer's push always lands in front of a human, and the step 8 comment is what that human reads first. A repository without that ruleset does not get the same guard, and the fixer says so in its comment when it enables auto-merge there.

**The human reviewer comes from the repository, never from a guess.** The fixer reads `prReview.humanReviewer` from the repository's `.claude/settings.json`. Absent means request nobody beyond the code owners. No handle is ever invented or taken from history.

**The merge method comes from the ruleset, never from the repository flags.** The fixer reads `gh api repos/{owner}/{repo}/rules/branches/<base>` and uses the method the `pull_request` rule allows. The repository API's `allow_squash_merge` and related flags report a setting the ruleset overrides.

**Reviewers never write.** Both reviewer agents carry an enumerated read-only allowlist and a `PreToolUse` hook that refuses any `gh api` call with a method or body flag. Neither posts to GitHub. The only GitHub write the loop produces is the fixer's path.
