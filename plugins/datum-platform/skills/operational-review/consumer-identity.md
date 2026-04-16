# Consumer Identity Mapping

This document covers how to get per-consumer breakdowns in operational reports.

## Summary

| Layer | Consumer identity available? | Metric | Join |
|-------|------------------------------|--------|------|
| Edge traffic (per-route) | **Yes** | `envoy_cluster_upstream_rq_*` | `httproute_namespace` → `kube_namespace_labels` |
| Edge traffic (per-gateway) | **Yes** | `envoy_vhost_vcluster_upstream_rq_*` | `envoy_virtual_host` → `datum_cloud_networking_gateway_info` |
| Control plane (API server) | **Yes** | `apiserver_request_total` | `namespace` → `kube_namespace_labels` |
| Karmada provisioning | **Partial** | Binding count global; new project count via Kubernetes MCP |

**Do not use** `envoy_http_downstream_rq_total` for consumer analysis — it is the global listener
metric and carries no consumer identity (only infra namespace labels).

---

## Edge Traffic: Per-Route Consumer Breakdown (primary approach)

Each consumer's HTTPProxy creates an HTTPRoute in a project namespace (`ns-{uuid}`). The edge
Envoy labels upstream cluster metrics with that namespace, enabling per-consumer queries.

### Step 1 — Query per-project traffic

```
topk(10,
  sum by (httproute_namespace) (
    rate(envoy_cluster_upstream_rq_total{httproute_namespace=~"ns-.*"}[5m])
  )
)
```

- `step: 1d` for weekly trend; `step: 1h` for daily pattern
- Filter `httproute_namespace=~"ns-.*"` to exclude non-project routes

### Step 2 — Resolve namespace → project name

Join with `kube_namespace_labels` to get the project control plane cluster name, then extract
the project name from it:

```
label_replace(
  sum by (httproute_namespace) (
    rate(envoy_cluster_upstream_rq_total{httproute_namespace=~"ns-.*"}[5m])
  ) * on (httproute_namespace) group_left(label_meta_datumapis_com_upstream_cluster_name)
    kube_namespace_labels{label_meta_datumapis_com_upstream_cluster_name!=""},
  "project_name", "$1",
  "label_meta_datumapis_com_upstream_cluster_name", "cluster-_(.*)"
)
```

- Join key: `httproute_namespace` == `namespace` on `kube_namespace_labels`
- `label_meta_datumapis_com_upstream_cluster_name` = `cluster-_{project_name}`
- Regex `cluster-_(.*)` extracts the project name

### Step 3 — Error codes by project

```
label_replace(
  sum by (httproute_namespace, envoy_response_code) (
    rate(envoy_cluster_upstream_rq_xx{httproute_namespace=~"ns-.*"}[5m])
  ) * on (httproute_namespace) group_left(label_meta_datumapis_com_upstream_cluster_name)
    kube_namespace_labels{label_meta_datumapis_com_upstream_cluster_name!=""},
  "project_name", "$1",
  "label_meta_datumapis_com_upstream_cluster_name", "cluster-_(.*)"
)
```

### Step 4 — Latency P90 by project

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

---

## Edge Traffic: Per-Gateway Breakdown (secondary)

Each gateway's virtual host appears in `envoy_vhost_vcluster_upstream_rq_*` with
`envoy_virtual_host` = `{gateway_uid_no_dashes}_datumproxy_net`. Join with
`datum_cloud_networking_gateway_info` to resolve project:

```
label_replace(
  sum by (gateway_uid) (
    label_replace(
      envoy_vhost_vcluster_upstream_rq_total,
      "gateway_uid", "$1", "envoy_virtual_host", "([a-f0-9]+)_datumproxy_net"
    )
  ) * on (gateway_uid) group_left(resourcemanager_datumapis_com_project_name)
    label_replace(
      datum_cloud_networking_gateway_info,
      "gateway_uid", "$1$2$3$4$5", "uid",
      "([a-f0-9]+)-([a-f0-9]+)-([a-f0-9]+)-([a-f0-9]+)-([a-f0-9]+)"
    ),
  "project_name", "$1", "resourcemanager_datumapis_com_project_name", "(.*)"
)
```

The per-route approach (Step 1–4 above) is simpler and more reliable. Use per-gateway only
when you need gateway-level aggregation.

---

## Context: Recording Rule Pipeline

`apps/datum-cloud-telemetry-system/base/kcl/networking.k8s.io.k` defines VMRules that are
designed to produce pre-enriched versions of `envoy_cluster_upstream_rq_*` and
`envoy_vhost_vcluster_upstream_rq_*` with `resourcemanager_datumapis_com_project_name` labels.
These enriched series are not currently present in VictoriaMetrics (confirmed Apr 15, 2026).
Until they exist, use the explicit join queries above.

---

## Control Plane: Per-Project API Activity

```
topk(10,
  sum by (namespace) (
    rate(apiserver_request_total{namespace=~"ns-.*"}[5m])
  ) * on (namespace) group_left(label_meta_datumapis_com_upstream_cluster_name)
    kube_namespace_labels{label_meta_datumapis_com_upstream_cluster_name!=""}
)
```

Same join approach as edge traffic.

---

## Karmada: Per-Project Provisioning

Karmada scheduler metrics are global — no per-project breakdown. Use the Kubernetes MCP to
count `ProjectControlPlane` resources with `creationTimestamp` within the report period:

```python
get_kubernetes_resources(
  apiVersion="infrastructure.miloapis.com/v1alpha1",
  kind="ProjectControlPlane"
)
# Count total; filter creationTimestamp within period for new projects this week
```

---

## Owner Email and User Profile Links

The staff portal user profile URL is:

```
https://staff.datum.net/customers/users/{userId}
```

Where `{userId}` is the user's Kubernetes `metadata.name` — a numeric Zitadel user ID
(e.g., `328747448287632651`).

**What is available through current tooling:**
- Project → owner org name: via `milo_projects_info{resource_name=...}.owner_name` or
  `ProjectControlPlane.metadata.annotations["resourcemanager.miloapis.com/owner-name"]`
- Org type (Personal vs Standard): via `milo_organizations_info`
- Staff portal project link: `https://staff.datum.net/customers/projects/{project-name}`

**What is NOT available through current tooling:**
- User email address — stored in Zitadel, served via `iam.miloapis.com/v1alpha1` User
  `spec.email`. Not in VictoriaMetrics metrics. The `milo_users_info` metric carries
  only the numeric Zitadel ID as `resource_name`, with no email label.
- Staff portal user profile link — requires mapping org name → user Zitadel ID → profile
  URL. This mapping is not exposed via the Kubernetes MCP (User CRD returns no results
  with current RBAC) or metrics.

To add email + profile links to a report, direct IAM API access is required.

---

## Report Table Format

| Project | Avg RPS | P90 latency | 4xx rate | 5xx rate |
|---------|--------:|------------:|---------:|---------:|
| `project-name` | N | N ms | N% | N% |

Resolve `httproute_namespace` → project name via the `kube_namespace_labels` join. If the join
yields an unfamiliar cluster name pattern, note it as unresolved rather than omitting the row.
