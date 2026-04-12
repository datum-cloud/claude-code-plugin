---
name: operational-review
description: Covers producing weekly operational traffic reports for the Datum Cloud global Envoy edge ingress. Use when asked for an ops review, traffic report, or latency analysis across POPs. Guides metric queries, anomaly detection, and publishing to datum-cloud/engineering.
---

# Operational Review

This skill covers producing and publishing weekly ops review reports covering global Envoy edge
ingress traffic and latency across all POPs.

## Overview

An operational review covers the past 7 days of production traffic across the 18 global POPs.
The output is a structured Markdown report committed to `datum-cloud/engineering` as a pull
request. Source data comes from VictoriaMetrics prod via the MCP server.

## Key Files

| File | Purpose |
|------|---------|
| `queries.md` | VictoriaMetrics queries for RPS and latency |
| `report-format.md` | Report structure, section order, and PR conventions |

## Workflow

```
Query VictoriaMetrics → Analyze → Detect anomalies → Write report → Open PR
```

### 1. Query metrics

Run all metric queries in parallel. See `queries.md` for the exact expressions.

Collect:
- **Global RPS** — hourly for 7 days, plus 1m-resolution max for the true peak
- **POP count** — confirm how many clusters are reporting
- **Per-POP RPS** — to identify which clusters drive spikes
- **Global latency P50/P90/P95** — hourly for 7 days
- **Per-POP latency P50/P90/P95** — 6h resolution for 7 days

### 2. Analyze

From the raw time series, compute:

| Metric | How |
|--------|-----|
| Weekly average RPS | Mean of hourly values |
| Baseline range | Mode band (exclude spikes >2× median) |
| Peak RPS | True 1m-resolution max |
| Daily avg RPS | Mean per calendar day (UTC) |
| Latency weekly median | `statistics.median()` per cluster — more robust than mean for tail metrics |
| Per-POP latency ranking | Sort by P90 median ascending |

### 3. Detect anomalies

Flag automatically:

- RPS spikes > 150% of weekly average
- Per-POP P90 > 300ms (threshold for investigation)
- Per-POP P95 > 500ms
- Clusters that changed latency regime mid-week (regime shift)
- Clusters with *recurring* (not one-off) tail spikes — suggests persistent issue

### 4. Write and publish report

- File path: `reports/traffic/YYYY-MM-DD-datum-traffic.md` in `datum-cloud/engineering`
- Branch: `ops/traffic-report-YYYY-MM-DD`
- PR title: `Ops Review: Weekly traffic report YYYY-MM-DD`
- See `report-format.md` for the full report structure

## Infrastructure

- **Metrics source**: VictoriaMetrics prod (`mcp__datum-infra-prod__victoria-metrics-mcp-server`)
- **Target repo**: `~/src/datum-cloud/engineering`
- **18 POPs**: 1 control plane + 16 `*-alice` edge POPs + 1 lab cluster
- **Key metrics**: `envoy_http_downstream_rq_total`, `envoy_http_downstream_rq_time_bucket`

## Known Patterns

### Bimodal latency distribution

The global P50 (~0.35ms edge, ~4ms control plane) vs P90 (~170ms) gap is expected. It reflects
two distinct traffic classes:
- **Fast**: health checks, lightweight API calls (~0.35ms)
- **Slow**: proxied upstream requests (~170ms)

Do not flag this as an anomaly. It is the normal operating state.

### Control plane traffic dominance

`prod-infrastructure-control-plane` typically carries ~60% of total RPS. This is expected — it
handles all API server traffic. Edge POPs run at ~2–3 RPS baseline.

### RPS spike + P50 rise with stable P90

When the global RPS spikes but P50 rises while P90 holds flat or drops, the spike is composed
of fast requests (health checks, retries). This is not a latency regression.

### RPS spike + P90/P95 rise

When P90 and P95 rise alongside an RPS spike, investigate the per-POP latency — one POP is
likely saturated or experiencing network issues.

## Related Skills

- `capability-telemetry` — General observability instrumentation
- `fluxcd-deployment` — For correlating latency spikes with deployment timelines
