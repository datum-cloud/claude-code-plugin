# Consumer Identity Mapping

This document covers how to get per-consumer breakdowns in operational reports and
what work is needed to close the gaps.

## Current State

| Layer | Consumer identity available? | Source |
|-------|------------------------------|--------|
| Control plane (API server) | **Yes** | `apiserver_request_total{namespace=...}` + `ProjectControlPlane` |
| Edge traffic (Envoy) | **No** | Envoy metrics carry only infra namespace labels |
| Karmada provisioning | **Partial** | Binding count is global; no per-project breakdown |

---

## Control Plane: What Works Today

Each Datum project gets a dedicated Kubernetes namespace. The namespace name is the
project name and maps directly to `ProjectControlPlane.metadata.name`.

### Step 1 — Query per-namespace API activity

```
topk(10, sum by (namespace) (rate(apiserver_request_total[5m])))
```

Filter system namespaces:
```
topk(10, sum by (namespace) (
  rate(apiserver_request_total{
    namespace!~"kube-.*|flux-system|cert-manager|.*-gateway.*|.*-system|monitoring"
  }[5m])
))
```

### Step 2 — Resolve namespace → owner via Kubernetes MCP

```python
get_kubernetes_resources(
  apiVersion="infrastructure.miloapis.com/v1alpha1",
  kind="ProjectControlPlane"
)
```

Each resource yields:
```yaml
metadata:
  name: <project-name>          # matches namespace in metrics
  labels:
    resourcemanager.miloapis.com/project-name: <project-name>
  annotations:
    resourcemanager.miloapis.com/owner-name: <org-name>
```

Join on `namespace == metadata.name` to build:

| Owner | Project | Avg RPS | Error rate |
|-------|---------|--------:|----------:|
| org-abc | project-xyz | 1.2 | 0.3% |

---

## Edge Traffic: The Gap and How to Close It

Envoy processes all inbound HTTPS requests but doesn't expose per-tenant metrics because
JWT claims and project ID headers are not extracted as stat tags.

### Option A — Envoy stat tag extraction (recommended)

Configure the `EnvoyProxy` resource to extract a request header or JWT claim as a
metric label. If every authenticated request carries an `x-project-id` header:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: datum-gateway
spec:
  telemetry:
    metrics:
      sinks:
        - type: OpenTelemetry
          openTelemetry:
            host: otel-collector.monitoring.svc
            port: 4317
  # Request header extraction for stat tags (requires Envoy stats_matcher or
  # WASM extension — consult Envoy Gateway docs for the current supported approach)
```

Once a `project_id` label is propagated, the consumer query becomes:

```
topk(10, sum by (project_id) (rate(envoy_http_downstream_rq_total[5m])))
```

### Option B — AIGatewayRoute per-route metrics

`aigateway.envoyproxy.io/AIGatewayRoute` CRDs are registered on the cluster but no
resources are deployed yet. When routes are created per-consumer (one route per project
or per AI service), Envoy will emit per-route stats that can be broken down by route name.

The closest existing label is `envoy_http_conn_manager_prefix`. Confirmed current values:
`http-80`, `https-443`, `aigateway-mcp-backend-listener-http`, `admin`, `eg-ready-http`,
`eg-stats-http` — all infrastructure listeners, no per-consumer routes.

The agent should check for `AIGatewayRoute` resources at review time:

```python
get_kubernetes_resources(
  apiVersion="aigateway.envoyproxy.io/v1alpha1",
  kind="AIGatewayRoute"
)
```

If resources exist, query:
```
topk(10, sum by (envoy_http_conn_manager_prefix) (rate(envoy_http_downstream_rq_total[5m])))
```

and correlate `conn_manager_prefix` values with route names from the Kubernetes query.

### Option C — Activity system (actor identity)

The Activity system records every API operation with actor identity. If the Activity
service is queryable (check for `activity.miloapis.com` resources or a dedicated
VictoriaMetrics metric), it provides per-user/per-project request counts with full
identity context — at higher query cost than Envoy metrics.

---

## Karmada: Per-Project Provisioning

Karmada scheduler metrics (`karmada_scheduler_schedule_attempts_total`) are currently
global — no project or namespace label is present.

To get per-project provisioning counts, use the Kubernetes MCP to list
`ProjectControlPlane` resources with their `creationTimestamp` and filter by the
reporting period:

```python
get_kubernetes_resources(
  apiVersion="infrastructure.miloapis.com/v1alpha1",
  kind="ProjectControlPlane"
)
# Filter: creationTimestamp within report period
# Group by: annotations["resourcemanager.miloapis.com/owner-name"]
```

This gives a count of new projects created per owner during the week, which is a
reasonable proxy for provisioning activity until per-project Karmada metrics are available.

---

## Summary: What the Agent Should Do Each Week

| Section | How |
|---------|-----|
| Control plane top consumers | VictoriaMetrics `apiserver_request_total` by `namespace` + Kubernetes MCP `ProjectControlPlane` join |
| Edge top consumers | Skip with noted limitation until `AIGatewayRoute` resources exist or stat tags are propagated |
| New projects this week | Kubernetes MCP `ProjectControlPlane` filtered by `creationTimestamp` |
| Karmada per-project | Not available; use global binding count + new project count as proxy |
