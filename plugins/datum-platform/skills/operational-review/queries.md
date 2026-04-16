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

**Do not use** `envoy_http_downstream_rq_total` for consumer analysis — it is the global
listener metric and carries no consumer identity. Use `envoy_cluster_upstream_rq_total`,
which carries `httproute_namespace=~"ns-.*"` — one namespace per project.

See `consumer-identity.md` for full background and the gateway-based alternative.

### Top projects by upstream RPS

```
topk(10,
  label_replace(
    sum by (httproute_namespace) (
      rate(envoy_cluster_upstream_rq_total{httproute_namespace=~"ns-.*"}[5m])
    ) * on (httproute_namespace) group_left(label_meta_datumapis_com_upstream_cluster_name)
      kube_namespace_labels{label_meta_datumapis_com_upstream_cluster_name!=""},
    "project_name", "$1",
    "label_meta_datumapis_com_upstream_cluster_name", "cluster-_(.*)"
  )
)
```

- `step: 1d` for weekly trend
- Result carries `project_name` label with the resolved project name

### Top projects by error rate

```
label_replace(
  sum by (httproute_namespace, envoy_response_code) (
    rate(envoy_cluster_upstream_rq_xx{
      httproute_namespace=~"ns-.*",
      envoy_response_code=~"4..|5.."
    }[5m])
  ) * on (httproute_namespace) group_left(label_meta_datumapis_com_upstream_cluster_name)
    kube_namespace_labels{label_meta_datumapis_com_upstream_cluster_name!=""},
  "project_name", "$1",
  "label_meta_datumapis_com_upstream_cluster_name", "cluster-_(.*)"
)
```

### Per-project latency P90

```
label_replace(
  histogram_quantile(0.90,
    sum by (httproute_namespace, le) (
      rate(envoy_cluster_upstream_rq_time_bucket{httproute_namespace=~"ns-.*"}[5m])
    ) * on (httproute_namespace) group_left(label_meta_datumapis_com_upstream_cluster_name)
      kube_namespace_labels{label_meta_datumapis_com_upstream_cluster_name!=""}
  ),
  "project_name", "$1",
  "label_meta_datumapis_com_upstream_cluster_name", "cluster-_(.*)"
)
```

- `step: 6h`

---

## Control Plane: Top Consumers

Same join pattern as edge traffic, using `apiserver_request_total`:

### Top projects by API request volume

```
topk(10,
  label_replace(
    sum by (namespace) (
      rate(apiserver_request_total{namespace=~"ns-.*"}[5m])
    ) * on (namespace) group_left(label_meta_datumapis_com_upstream_cluster_name)
      kube_namespace_labels{label_meta_datumapis_com_upstream_cluster_name!=""},
    "project_name", "$1",
    "label_meta_datumapis_com_upstream_cluster_name", "cluster-_(.*)"
  )
)
```

- `step: 1d`

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

## Control Plane: Project Count and Memory Pressure

High project counts drive Kyverno informer cache growth, which causes memory pressure on
the admission controller. Left undetected, this produces an OOMKill → webhook-down →
stale UpdateRequest backlog loop (see datum-cloud/infra#2220). Track project count trend
and admission controller headroom every review cycle.

### Project count — current and weekly growth (Kubernetes MCP)

```python
get_kubernetes_resources(
  apiVersion="infrastructure.miloapis.com/v1alpha1",
  kind="ProjectControlPlane"
)
```

- Count total resources for the current fleet size
- Filter `creationTimestamp` within the report period to count new projects this week
- Week-over-week growth = (this week count) − (last week count)

### Project namespace count via metrics

```
count(kube_namespace_labels{label_resourcemanager_miloapis_com_project_name!=""})
```

- Single-point query — cross-check against Kubernetes MCP count
- `step: 1d` for weekly trend; flag if growth rate is accelerating

### Kyverno UpdateRequest backlog (Kubernetes MCP)

```python
get_kubernetes_resources(
  apiVersion="kyverno.io/v2",
  kind="UpdateRequest",
  namespace="kyverno"
)
```

- Count total UpdateRequests; anything above ~100 warrants attention
- A large backlog (thousands) indicates the background controller is unable to drain —
  a precursor to the admission webhook failure loop

### Kyverno UpdateRequest backlog via metrics

```
kyverno_update_requests_total
```

- Confirm label set with `labels(kyverno_update_requests_total)`
- `step: 1h` for weekly trend; look for sustained growth rather than transient spikes

### Kyverno admission controller memory — usage vs limit

```
container_memory_working_set_bytes{
  container="kyverno-admission-controller"
}
```

```
kube_pod_container_resource_limits{
  resource="memory",
  container="kyverno-admission-controller"
}
```

- Compute utilization ratio: `working_set / limit`
- `step: 1h` — flag if ratio exceeds 70% (leaves insufficient headroom before OOMKill)
- Current limit after datum-cloud/infra#2220: 1536Mi

### Kyverno admission controller restart rate

```
increase(kube_pod_container_status_restarts_total{
  container="kyverno-admission-controller"
}[1d])
```

- `step: 1d` — any restarts (exit code 137 = OOMKill) are a critical signal
- Cross-check: `kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}`

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
| Project count weekly growth | > 50 new projects/week | Note trend; assess memory headroom runway |
| Kyverno UpdateRequest backlog | > 100 | Background controller is falling behind |
| Kyverno UpdateRequest backlog | > 1,000 | Critical — webhook failure loop risk (see infra#2220) |
| Kyverno admission memory utilization | > 70% of limit | Headroom warning; monitor for OOMKill |
| Kyverno admission memory utilization | > 90% of limit | Imminent OOMKill risk; escalate |
| Kyverno admission restarts | Any in week | Investigate for OOMKill (exit 137) |
