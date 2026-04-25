---
name: analyze-gcp-spend
description: >
  Produces a GCP spend report covering all datum-cloud infrastructure across staging and production.
  On the first week of the month (run date ≤ day 7), performs a full retrospective for the prior
  calendar month. Otherwise produces an MTD snapshot. Queries BigQuery billing exports and live
  cluster state, generates mermaid trend charts for the trailing 4 months, and files a PR to
  the engineering repo.
---

# GCP Spend Analysis

Produces a GCP spend report for all datum-cloud infrastructure (staging + production).
Run weekly on Mondays. On the first week of the month (run date ≤ day 7), produces a full
retrospective for the prior calendar month. All other weeks produce a month-to-date snapshot.

## Cadence Logic

| Run date | Reporting period | Report type |
|----------|-----------------|-------------|
| Day 1–7 of month | Previous calendar month (full) | Full monthly retrospective |
| Day 8+ of month | Current month-to-date | MTD snapshot |

## Scope

| Environment | GCP Project ID | Cluster | Region |
|-------------|---------------|---------|--------|
| Production | `datum-cloud-prod` | `infrastructure-control-plane-prod` | us-east4 |
| Staging | `datum-cloud-staging` | `infrastructure-control-plane-staging` | us-east4 |

Edge clusters (dfw, tyo, syd, etc.) run outside GCP — exclude from this analysis.

## Preflight Checks

Run these before doing any work. If BigQuery fails, stop and report — do not proceed
with estimates in place of real billing data.

```bash
# 1. Verify BigQuery billing export is accessible
bq ls --project_id datum-cloud-prod billing
# Expected: lists at least one table named gcp_billing_export_resource_v1_*
# Failure → stop. Fix: grant bigquery.jobs.create + bigquery.tables.getData
#   on the billing dataset to the active service account or user.

# 2. Verify prod cluster is reachable
gcloud container clusters list --project datum-cloud-prod --format="value(name)"
# Expected: infrastructure-control-plane-prod
# Failure → note in report, use IaC config for prod compute section only

# 3. Verify staging cluster is reachable
gcloud container clusters list --project datum-cloud-staging --format="value(name)"
# Expected: infrastructure-control-plane-staging
# Failure → note in report, use IaC config for staging compute section only
```

**BigQuery is a hard requirement.** Storage and Cloud SQL are only visible in the billing
export — without it the report is missing $2,000–$3,000/month of spend. A report produced
without billing data will be materially wrong. Stop and surface the access error; do not
publish an estimate-based report as if it were authoritative.

## Workflow

1. **Preflight** — run the checks above; halt on BigQuery failure
2. **Determine period** — check today's date; select full-month (day ≤ 7) or MTD mode
3. **Query billing** — run BigQuery queries from `queries.md` for services, SKUs, and storage
4. **Query live state** — pull current node pools, PVC inventory, and Cloud SQL from both clusters
5. **Compute 4-month trend** — run the trailing-4-months query; populate mermaid chart data
6. **Identify issues** — compare billing data to live state; flag IaC drift, oversized resources,
   generation-penalty instances (n1 vs n2), and unexpected on-demand pools
7. **Draft report** — follow the structure and mermaid templates in `report-format.md`
8. **File PR** — write to `/workspace/engineering` and open a PR via `gh pr create`

## What to Flag

- **IaC drift** — node pools or resources visible in the cluster but absent from Pulumi/IaC config
- **Generation penalty** — n1 instances cost ~15% more than equivalent n2; flag and quantify savings
- **Spot vs on-demand transitions** — note any pools that switched from spot to on-demand; compute delta
- **Oversized storage** — PVCs provisioned much larger than workload requirements (flag if detectable)
- **Single points of failure on premium storage** — hyperdisk-balanced or pd-ssd on unreplicated nodes
- **Month-over-month deltas** — any service that increased >10% MoM warrants a note in Top Issues

## Infrastructure

- **Billing source**: BigQuery billing export — see `queries.md` for table discovery
- **Live state**: `gcloud`, `kubectl` — commands in `queries.md`
- **Target repo**: `/workspace/engineering`
- **Output path**: `reports/gcp-spend/YYYY-MM-DD-gcp-spend.md`

## Sub-topics

- `queries.md` — BigQuery billing SQL, gcloud and kubectl commands, 4-month trend queries
- `report-format.md` — report sections, mermaid chart templates, PR workflow and git commands

## Related Skills

- `operational-review` — Weekly traffic and latency report for the Envoy edge ingress
- `capability-quota` — Quota system that can gate resource consumption and bound costs
