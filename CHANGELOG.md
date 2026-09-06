# Changelog

Notable changes to the Datum Cloud Claude Code plugins.

## [1.13.0] - 2026-09-05

### Added

- **PR review loop** (`pr-review-loop`, `/pr-review`, datum-platform). Two read-only opus reviewers run at once on every pull request a session opens, with no knowledge of each other. `pr-adversary` reproduces the failure the PR claims to fix, runs every check the body cites, and attacks each claim. `pr-conventions-reviewer` works out where the change lands once merged, renders it the way Flux will, checks that patch targets anchor, looks for collisions with other open PRs, and measures the commits and body against the `pr-conventions` bar. Both return one line per finding and a `merge` or `hold` verdict. When the two agree cleanly, `pr-review-fixer` applies the findings in the PR's own worktree, commits signed, pushes, waits for CI, marks the PR ready, requests the reviewer named in the repository's settings, enables auto-merge with the method the branch ruleset allows, and posts one comment recording both verdicts. Any `decision` finding, split verdict, or hedge goes to a person instead. This release is opt-in: the loop runs when the skill triggers or on `/pr-review`, and no hook fires it yet.
- **Read-only guard for reviewer agents** (`deny-gh-api-write`, datum-platform). A `PreToolUse` hook that refuses any `gh api` call carrying a method or body flag, so a reviewer whose allowlist grants `gh api` for reads cannot post through it. Fails closed when it cannot read its input.

### Fixed

- **Marketplace catalogue versions**. The catalogue entries for `datum-platform` and `datum-gtm` now match their plugin manifests. They had sat at 1.0.0 while the manifests moved, and the validator warned on every run.

## [1.12.0] - 2026-09-04

### Added

- **Clear writing skill** (`clear-writing`, datum-platform) — The prose basis for every Datum repository, adapted from the European Economic and Social Committee's *Clear Writing* guide. Carries only what the Orwell and Google rules in `pr-conventions` do not: the seven questions a piece of writing has to answer, verbs over nominalized nouns, sentence order and modifier placement, restrictive commas, concrete over abstract, word pairs and false friends, and a technical section on READMEs, error messages, code comments, and reference docs. Includes a phrase table of wordy constructions, Latin tags, and jargon with plain replacements.

### Changed

- **PR/issue body gate** (`pr-op-gate`, datum-platform) — Now refuses any phrase in the clear-writing table, naming each one and its replacement. The gate reads the table from the skill at run time, so the doc and the enforcement cannot drift, and an unreadable table is a refusal rather than a pass. Edits stay judged on what they add, so a phrase already in a colleague's post is not yours to fix.
- **GitHub conventions skill** (`pr-conventions`), **commit conventions** (`commit-conventions`), and the **tech-writer agent** now point at `clear-writing` instead of restating it.

## [1.9.0] - 2026-08-04

### Added

- **PR/issue body gate** (`pr-op-gate`, datum-platform) — A `PreToolUse` hook that measures the body of a `gh pr|issue create|edit` call and blocks the post when it misses the countable rules: summary over four sentences, test plan over four checkboxes, file paths or identifiers in the opening post, a `Closes` keyword, an emoji heading, or hard-wrapped prose. Each denial names the rule and the count that broke it, so the draft gets revised before it goes up rather than after. Replaces per-repository copies of the same checklist that only ever advised.

### Changed

- **GitHub conventions skill** (`pr-conventions`, datum-platform) — Rewritten around a countable bar rather than qualitative advice, and cut by more than half so the skill reads the way it asks writers to write. Adds Orwell's writing rules and Google's technical writing rules as the style basis, states which limits the gate enforces, and drops the prose-about-prose tables and long worked examples that taught the verbosity the skill was meant to prevent.

## [1.8.2] - 2026-07-29

### Changed

- **GitHub conventions skill** (`pr-conventions`, datum-platform) — Sharpened "be concise" into two enforceable rules: say it once (no restating the summary as test-plan checkboxes, no describing the same behaviour in prose and again in a checklist) and cut every word carrying no fact, with a compress-don't-omit clause so brevity never costs facts. Added the two matching rows to the PR "What to Avoid" table.

## [1.8.1] - 2026-07-09

### Changed

- **GitHub conventions skill** (`pr-conventions`, datum-platform) — Added a rule forbidding hard-wrapped prose in PR descriptions, issues, and comments. GitHub reflows Markdown, so manual fixed-column wrapping (e.g. 80 characters) produces ragged, hard-to-edit text; hard-wrapping belongs only in commit messages. Added as a Core Principle and a row in the PR "What to Avoid" table.

## [1.1.0] - 2026-07-08

### Added

- **Changelog entry skill** (`changelog-entry`, datum-gtm) — Guides the gtm-comms agent through turning raw engineering notes, PR/issue links, or a feature description into a hand-off-ready draft for Datum's GitHub Discussions Changelog. Covers benefit-led titling, a fixed post structure (lead → hero feature → New/Improved/Fixed, plus a breaking-changes heads-up and security wording → docs links → single CTA), a voice pass that strips Kubernetes jargon and internal implementation detail, an anti-fabrication rule with a `[VERIFY]` convention, a public-vs-private community credit gate, a scope gate with a stakeholder-override path, and a required pre-publish handoff block. Ships a fill-in `template.md`, a worked `example.md`, and a self-review checklist that mirrors every rule. Complements the Keep-a-Changelog release-file template in `gtm-templates`.

## [1.8.0] - 2026-05-04

### Added

- **Release skill** (`release`) — Generates GitHub releases for any datum-cloud service repository. Gates releases on a green CI status for the release commit and refreshes the third-party `NOTICE` file (license compliance) before tagging. Auto-detects project type (CRD-based operator or aggregated API server), collects merged PRs since the last release, diffs schema/type files to determine compatibility, drafts release notes in the established style, and publishes via `gh release create`. Supports `--patch`, `--minor`, `--major`, and `--draft` flags.

## [1.7.0] - 2026-04-30

### Changed

- **GitHub conventions skill** (`pr-conventions`) — Expanded from PR-only guidance to cover issues and comments. PRs must now link to an issue. Avoid using `Closes`/`Closed` — use `Fixes` or `Resolves` only when intentionally closing. Issue descriptions focus on goals and desired outcomes; technical discussion belongs in comments. Adds GitHub callout syntax guidance and a rule to always use descriptive link text.

## [1.6.0] - 2026-04-12

### Added

- **Operational review skill** (`operational-review`) — Guides the SRE agent through producing weekly traffic and latency ops review reports for the global Envoy edge ingress. Covers VictoriaMetrics queries for RPS and latency (P50/P90/P95) globally and per-POP, anomaly detection thresholds, and publishing structured reports as pull requests to `datum-cloud/engineering`.

## [1.5.0] - 2026-02-20

### Added

- **PR conventions skill** (`pr-conventions`) — Standardized pull request description guidelines covering structure, required sections, and content guidance. Defines Summary, Test plan, and Breaking changes sections. Agents prompt for context when PR purpose is unclear.

## [1.4.0] - 2026-02-20

### Added

- **Commit conventions skill** (`commit-conventions`) — Standardized commit message guidelines based on the seven rules from cbea.ms/git-commit. Provides format, structure, and content guidance for consistent commit history across repositories. Agents prompt for clarification when commit purpose is unclear.

## [1.3.0] - 2026-02-20

### Added

- **Feature gates pattern** (`k8s-apiserver-patterns`) — Guidance for safely introducing experimental features with Alpha/Beta/GA lifecycle stages. Helps API developers ship new capabilities incrementally while giving operators runtime control via `--feature-gates` flags.
