# Changelog

Notable changes to the Datum Cloud Claude Code plugins.

## [datum-operations 1.0.0] - 2026-05-11

### Added

- **New plugin: datum-operations** — Operational tooling for the Datum AI Edge, extracted from `datum-platform`. Includes the `operational-reviewer` agent and `operational-review` skill (VictoriaMetrics queries, anomaly detection, report format, on-call issue linking).

## [datum-platform 2.0.0] - 2026-05-11

### Removed

- **Operational reviewer agent** (`operational-reviewer`) — Moved to the new `datum-operations` plugin.
- **Operational review skill** (`operational-review`) — Moved to the new `datum-operations` plugin.

## [1.7.1] - 2026-05-11

### Changed

- **Operational review skill** (`operational-review`) — After opening the traffic report PR, now finds the current on-call issue in `datum-cloud/engineering` (open issue titled "on-call: week of …") and posts a comment linking the review.

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
