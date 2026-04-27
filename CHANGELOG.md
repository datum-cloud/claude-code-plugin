# Changelog

Notable changes to the Datum Cloud Claude Code plugins.

## [1.6.1] - 2026-04-27

### Fixed

- **Kyverno container label** (`operational-review`) — Corrected three queries that filtered on `container="kyverno-admission-controller"` (returns no data) to the actual cAdvisor/kube-state-metrics label `container="kyverno"`. Added `namespace="kyverno-system"` scoping to all three queries.
- **Kyverno memory limit comment** (`operational-review`) — Updated stale `1536Mi` figure to the current confirmed limit of `2048Mi (2Gi)` across all 18 clusters.
- **`kyverno_update_requests_total` availability** (`operational-review`) — Added note that this metric is not emitted by the deployed Kyverno version and that the Kubernetes MCP `UpdateRequest` path is the only viable approach.

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
