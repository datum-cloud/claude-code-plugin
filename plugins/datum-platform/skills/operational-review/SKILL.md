---
name: operational-review
description: Covers producing weekly operational reports for the Datum AI Edge. Use when asked for an ops review, traffic report, latency analysis, provisioning report, or edge performance summary. Guides metric queries, anomaly detection, and publishing to datum-cloud/engineering.
---

# Operational Review

This skill covers producing and publishing weekly ops review reports for the
Datum AI Edge — covering edge traffic performance, consumer patterns, and
control plane provisioning health.

## Scope

An operational review covers two domains:

### Edge Traffic

Analysis of request traffic flowing through the Datum AI Edge:

- **Request volume** — total requests processed, RPS trends, daily averages, peak
- **Latency** — P50/P90/P95 globally and per POP
- **Performance** — per-POP throughput and latency rankings
- **Top consumers** — highest-traffic tenants/namespaces, usage patterns
- **Error codes by API group** — 4xx/5xx breakdown per API group to surface
  degraded or misconfigured routes

### Control Plane Traffic

Analysis of AI Edge resource lifecycle and provisioning health:

- **AI edges created** — creation rate and total count over the review period
- **Provisioning performance** — time-to-ready across Karmada propagation,
  scheduler latency, per-cluster distribution
- **Error codes by API group** — webhook admission errors, controller reconcile
  errors, and API server error rates per resource group

## Key Files

| File | Purpose |
|------|---------|
| `queries.md` | VictoriaMetrics queries for all metric categories |
| `report-format.md` | Report structure, section order, and PR conventions |
| `consumer-identity.md` | How to map identity to resources — what works today, what needs platform work |

## Workflow

```
Query metrics + incidents → Analyze → Correlate → Write report → Open PR
```

### 1. Discover available metrics

Before querying, confirm what labels are available for consumer/tenant
segmentation and API group breakdowns. Use:

```
victoria-metrics metrics (search: "envoy_http", "karmada", "apiserver_request")
victoria-metrics label_values (label: "cluster", "namespace", "resource", "group")
```

### 2. Query metrics

Run all queries in parallel. See `queries.md` for the exact expressions.

Collect:
- **Edge traffic** — RPS (hourly + 1m peak), per-POP RPS, latency P50/P90/P95
  (hourly global, 6h per-POP), top consumers by request volume, error rate by
  API group
- **Control plane** — AI edge creation rate, time-to-ready distribution,
  Karmada propagation latency, API server error rate by resource group

### 3. Analyze

From the raw time series, compute:

| Metric | How |
|--------|-----|
| Weekly average RPS | Mean of hourly values |
| Baseline range | Mode band (exclude spikes >2× median) |
| Peak RPS | True 1m-resolution max |
| Daily avg RPS | Mean per calendar day (UTC) |
| Latency weekly median | `statistics.median()` per cluster — more robust than mean |
| Per-POP latency ranking | Sort by P90 median ascending |
| Top consumers | Sum by tenant/namespace, sort descending, take top 10 |
| Error rate by group | Total errors / total requests per API group |
| Provisioning P90 | Histogram quantile for time-to-ready |

### 4. Detect anomalies

Flag automatically — see `queries.md` for thresholds.

### 5. Surface relevant incidents

Query GitHub for incidents in `datum-cloud/engineering`:

```bash
gh issue list --repo datum-cloud/engineering \
  --label ":incident/issue" \
  --state all \
  --json number,title,state,createdAt,closedAt
```

Filter for AI Edge relevance:
- **Include**: incidents opened or closed within the report period (±2 days)
- **Include**: any open incidents touching proxies, edge, routing, Envoy, Karmada, or provisioning
- **Exclude**: unrelated infrastructure (DNS for non-edge domains, staff portal, auth UI)

Where an incident's timing overlaps a metric anomaly, note the correlation explicitly
in both the Open Incidents section and the relevant Key Finding.

### 6. Write and publish report

- File path: `reports/traffic/YYYY-MM-DD-datum-traffic.md` in `datum-cloud/engineering`
- Branch: `ops/traffic-report-YYYY-MM-DD`
- PR title: `Ops Review: Weekly traffic report YYYY-MM-DD`
- See `report-format.md` for the full report structure

## Infrastructure

- **Metrics source**: VictoriaMetrics prod (`mcp__datum-infra-prod__victoria-metrics-mcp-server`)
- **Target repo**: `~/src/datum-cloud/engineering`
- **Key edge metrics**: `envoy_http_downstream_rq_total`, `envoy_http_downstream_rq_time_bucket`
- **Key control plane metrics**: `apiserver_request_total`, Karmada scheduler/propagation metrics

## Known Patterns

### Bimodal latency distribution

The global P50 (~0.35ms edge, ~4ms control plane) vs P90 (~170ms) gap is expected. It reflects
two distinct traffic classes:
- **Fast**: health checks, lightweight API calls (~0.35ms)
- **Slow**: proxied upstream requests (~170ms)

Do not flag as an anomaly.

### Control plane traffic dominance

`prod-infrastructure-control-plane` typically carries ~60% of total RPS. This is expected.

### RPS spike + P50 rise with stable P90

Spike composed of fast requests (health checks, retries). Not a latency regression.

### RPS spike + P90/P95 rise

Investigate per-POP latency — one POP is likely saturated or experiencing network issues.

## Related Skills

- `capability-telemetry` — General observability instrumentation
- `fluxcd-deployment` — Correlate latency spikes with deployment timelines
