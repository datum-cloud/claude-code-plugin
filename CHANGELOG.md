# Changelog

Notable changes to the Datum Cloud Claude Code plugins.

## [1.7.1] - 2026-05-11

### Changed

- **Operational review skill** (`operational-review`) — After opening the traffic report PR, now finds the current on-call issue in `datum-cloud/engineering` (open issue titled "on-call: week of …") and posts a comment linking the review.

## [1.7.0] - 2026-04-25

### Added

- **GCP spend analysis skill** (`analyze-gcp-spend`) — Weekly GCP cost report covering datum-cloud staging and production. Queries BigQuery billing exports and live cluster state, generates mermaid trend charts for the trailing 4 months, and files a PR to `datum-cloud/engineering`. Includes a dedicated `cost-analyst` agent and full report-format and query reference.

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
