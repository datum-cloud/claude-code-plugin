# VictoriaMetrics Queries

All queries target the prod VictoriaMetrics instance via the MCP server
(`mcp__datum-infra-prod__victoria-metrics-mcp-server`).

Use `start: YYYY-MM-DDT00:00:00Z` (7 days ago) and `end: YYYY-MM-DDT00:00:00Z` (today) unless
otherwise noted.

## RPS Queries

### Global RPS — hourly (baseline/daily view)

```
sum(rate(envoy_http_downstream_rq_total[5m]))
```

- `step: 1h`
- Use to compute daily averages and identify spike windows

### Global RPS — 1m resolution max (true peak)

```
max_over_time(sum(rate(envoy_http_downstream_rq_total[1m]))[7d:1m])
```

- Single-point query at `start: today`, `step: 7d`
- Returns the true 1m peak; hourly averaging hides intra-hour bursts

### POP count (sanity check)

```
count(sum by (cluster) (rate(envoy_http_downstream_rq_total[5m])))
```

- `step: 1d` — confirm cluster count is stable throughout the week

### Per-POP RPS — hourly

```
sum by (cluster) (rate(envoy_http_downstream_rq_total[5m]))
```

- `step: 1h`
- Use to identify which cluster drives global spikes
- Sort by descending average to rank POPs

## Latency Queries

Source histogram: `envoy_http_downstream_rq_time_bucket` (values in milliseconds).

### Global P50 — hourly

```
histogram_quantile(0.50, sum(rate(envoy_http_downstream_rq_time_bucket[5m])) by (le))
```

### Global P90 — hourly

```
histogram_quantile(0.90, sum(rate(envoy_http_downstream_rq_time_bucket[5m])) by (le))
```

### Global P95 — hourly

```
histogram_quantile(0.95, sum(rate(envoy_http_downstream_rq_time_bucket[5m])) by (le))
```

All global latency queries: `step: 1h`

### Per-POP P50/P90/P95 — 6h resolution

Run all three in parallel, adding `by (le, cluster)`:

```
histogram_quantile(0.50, sum(rate(envoy_http_downstream_rq_time_bucket[5m])) by (le, cluster))
histogram_quantile(0.90, sum(rate(envoy_http_downstream_rq_time_bucket[5m])) by (le, cluster))
histogram_quantile(0.95, sum(rate(envoy_http_downstream_rq_time_bucket[5m])) by (le, cluster))
```

- `step: 6h` — reduces response size while preserving enough resolution to catch spikes
- Use `statistics.median()` (not mean) when aggregating per-cluster — tail spike outliers
  skew the mean and mask the true baseline

## Anomaly Thresholds

| Signal | Threshold | Action |
|--------|-----------|--------|
| Global RPS spike | > 150% of weekly avg | Note timestamp, correlate with per-POP and deployments |
| Per-POP P90 spike | > 300ms | Flag in report, check if recurring |
| Per-POP P95 spike | > 500ms | Flag in report |
| Recurring P95 > 500ms | 3+ occurrences in week | Mark as "persistent issue, investigate" |
| Latency regime shift | P90 changes by > 50ms mid-week and stays | Note possible traffic class change |
