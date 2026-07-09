# Changelog

Notable changes to the Datum Cloud Claude Code plugins.

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
