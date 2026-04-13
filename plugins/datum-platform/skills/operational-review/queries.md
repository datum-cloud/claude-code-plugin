# VictoriaMetrics Queries

All queries target the prod VictoriaMetrics instance via the MCP server
(`mcp__datum-infra-prod__victoria-metrics-mcp-server`).

Use `start: YYYY-MM-DDT00:00:00Z` (7 days ago) and `end: YYYY-MM-DDT00:00:00Z` (today) unless
otherwise noted.

Before running queries for new metric categories (consumers, API groups, Karmada), use
`metrics` or `label_values` to confirm available metric names and label cardinality.

---

## Edge Traffic: RPS

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

---

## Edge Traffic: Latency

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

- `step: 6h`
- Use `statistics.median()` (not mean) when aggregating per-cluster

---

## Edge Traffic: Top Consumers

**Current state**: Envoy metrics carry no tenant/consumer identity. The `namespace` label on
`envoy_http_downstream_rq_*` only reflects infrastructure namespaces (`datum-downstream-gateway`,
`envoy-gateway-system`). Per-consumer edge breakdown is not available until one of the following
is in place. See `consumer-identity.md` for the full options.

### When `AIGatewayRoute` resources are deployed

Each route will carry a name that maps to a consumer. Query:

```
topk(10, sum by (route) (rate(envoy_http_downstream_rq_total[5m])))
```

Until then, skip this section and note the limitation in the report.

---

## Control Plane: Top Consumers (available today)

Each Datum project maps 1:1 to a Kubernetes namespace. `apiserver_request_total` carries a
`namespace` label, so per-project control plane activity is available now.

### Top projects by API request volume — daily

```
topk(10, sum by (namespace) (rate(apiserver_request_total[5m])))
```

- `step: 1d`
- Filter out system namespaces: add `namespace!~"kube-.*|flux-system|cert-manager|.*-system"`
- Sort descending to rank top consumers

### Top projects by error rate

```
topk(10, sum by (namespace) (rate(apiserver_request_total{code=~"4..|5.."}[5m])))
  / ignoring(code) topk(10, sum by (namespace) (rate(apiserver_request_total[5m])))
```

- Surfaces projects generating the most rejected requests

### Map namespace → project owner (Kubernetes MCP)

`apiserver_request_total` gives namespace names, but not owner identity. Use the Kubernetes
MCP to resolve the mapping:

```
get_kubernetes_resources(
  apiVersion: "infrastructure.miloapis.com/v1alpha1",
  kind: "ProjectControlPlane"
)
```

Each `ProjectControlPlane` resource has:
- `metadata.name` — matches the namespace name in `apiserver_request_total`
- `metadata.labels["resourcemanager.miloapis.com/project-name"]` — human-readable project name
- `metadata.annotations["resourcemanager.miloapis.com/owner-name"]` — organization/owner

Join the metric results to this list by matching `namespace` → `metadata.name` to produce a
table with columns: owner, project, avg RPS, error rate.

---

## Edge Traffic: Error Codes by API Group

Envoy reports response codes via `envoy_http_downstream_rq_xx` counter metrics or
through response code labels on the main histogram. Confirm available labels:

```
label_values(envoy_http_downstream_rq_total, response_code_class)
label_values(envoy_http_downstream_rq_total, route)
```

### Error rate by response class — hourly

```
sum by (response_code_class) (rate(envoy_http_downstream_rq_total[5m]))
```

- `step: 1h`
- Focus on `4xx` and `5xx` classes

### Error rate by API group / route

If a `route`, `virtual_host`, or `grpc_method` label maps to API groups:

```
sum by (route) (rate(envoy_http_downstream_rq_total{response_code_class="5xx"}[5m]))
```

- `step: 1h`
- Sort by descending error rate; top offenders warrant investigation

### 5xx error fraction

```
sum(rate(envoy_http_downstream_rq_total{response_code_class="5xx"}[5m]))
  / sum(rate(envoy_http_downstream_rq_total[5m]))
```

- `step: 1h` — weekly trend of server-side error rate

---

## Control Plane: AI Edges Created

AI edge creation events are tracked as Kubernetes resource lifecycle events.
Confirm metric names:

```
metrics (search: "aiedge", "ai_edge", "datum_aiedge")
```

### AI edge creation rate — daily

```
sum(increase(aiedge_created_total[1d]))
```

- `step: 1d` — daily count of new AI edge resources created
- Adjust metric name based on discovery above

### Total AI edges active

```
sum(aiedge_active_total)
```

- Single-point query — current fleet size
- Useful for week-over-week growth comparison

---

## Control Plane: Provisioning Performance (Karmada)

Karmada propagation and scheduling metrics. Confirm names:

```
metrics (search: "karmada_scheduler", "karmada_binding", "karmada_work")
```

### Karmada scheduler queue latency P90 — hourly

```
histogram_quantile(0.90, sum(rate(karmada_scheduler_scheduling_duration_seconds_bucket[5m])) by (le))
```

- `step: 1h`
- Measures time from resource binding to scheduler decision

### Work propagation latency P90 — hourly (time-to-ready)

```
histogram_quantile(0.90, sum(rate(karmada_work_sync_duration_seconds_bucket[5m])) by (le))
```

- `step: 1h`
- Measures time from work creation to application on member cluster

### Per-cluster propagation latency P90

```
histogram_quantile(0.90, sum by (cluster) (rate(karmada_work_sync_duration_seconds_bucket[5m])) by (le, cluster))
```

- `step: 6h`
- Use to identify slow member clusters

### Binding failure rate

```
sum by (reason) (rate(karmada_scheduler_schedule_attempts_total{result="error"}[5m]))
```

- `step: 1h`
- Surfaces scheduler errors by failure reason

---

## Control Plane: Error Codes by API Group

Uses Kubernetes API server request metrics.

### API server errors by resource group — hourly

```
sum by (group, code) (rate(apiserver_request_total{code=~"4..|5.."}[5m]))
```

- `step: 1h`
- Groups errors by API group (`networking.datumapis.com`, `compute.datumapis.com`, etc.)
  and HTTP response code

### Error rate by verb and resource

```
sum by (resource, verb, code) (rate(apiserver_request_total{code=~"4..|5.."}[5m]))
```

- `step: 1h`
- Useful for pinpointing which operations are failing

### Webhook admission error rate

```
sum by (name, type) (rate(apiserver_admission_webhook_admission_duration_seconds_count{rejected="true"}[5m]))
```

- `step: 1h`
- Surfaces admission webhook rejections by webhook name

---

## Anomaly Thresholds

| Signal | Threshold | Action |
|--------|-----------|--------|
| Global RPS spike | > 150% of weekly avg | Note timestamp, correlate with per-POP and deployments |
| Per-POP P90 spike | > 300ms | Flag in report, check if recurring |
| Per-POP P95 spike | > 500ms | Flag in report |
| Recurring P95 > 500ms | 3+ times in week | Mark as "persistent issue, investigate" |
| Latency regime shift | P90 changes > 50ms mid-week and stays | Note possible traffic class change |
| 5xx error rate | > 1% of total requests | Investigate by API group |
| Karmada scheduling P90 | > 5s | Investigate scheduler queue depth |
| Propagation P90 | > 60s | Investigate member cluster health |
| Binding failure rate | Any sustained > 0 | Flag by failure reason |
| API server 5xx | > 0.5% per group | Investigate by resource group |
