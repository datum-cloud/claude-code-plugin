# GCP Billing Queries

## Finding the Billing Export Table

```bash
bq ls --project_id datum-cloud-prod billing
```

The export table is typically named `gcp_billing_export_resource_v1_{ACCOUNT_ID}`. Replace
`{BILLING_TABLE}` throughout this file with the fully-qualified table reference, e.g.:
`datum-cloud-prod.billing.gcp_billing_export_resource_v1_XXXXXX_XXXXXX_XXXXXX`

## GCP Projects in Scope

| Environment | Project ID |
|-------------|-----------|
| Production | `datum-cloud-prod` |
| Staging | `datum-cloud-staging` |

## Period Parameters

Set `@period_start` and `@period_end` based on the cadence rule in `SKILL.md`:

| Mode | @period_start | @period_end |
|------|--------------|-------------|
| Full month (day ≤ 7) | First day of prior month | First day of current month |
| MTD (day ≥ 8) | First day of current month | Tomorrow |

## Cost by Service

```sql
SELECT
  project.id                 AS project,
  service.description        AS service,
  SUM(cost)                  AS total_cost
FROM `{BILLING_TABLE}`
WHERE
  DATE(_PARTITIONTIME) >= @period_start
  AND DATE(_PARTITIONTIME) < @period_end
  AND project.id IN ('datum-cloud-prod', 'datum-cloud-staging')
GROUP BY project, service
ORDER BY total_cost DESC
```

## Cost by SKU (Compute + GKE Detail)

```sql
SELECT
  project.id                 AS project,
  service.description        AS service,
  sku.description            AS sku,
  SUM(cost)                  AS total_cost
FROM `{BILLING_TABLE}`
WHERE
  DATE(_PARTITIONTIME) >= @period_start
  AND DATE(_PARTITIONTIME) < @period_end
  AND project.id IN ('datum-cloud-prod', 'datum-cloud-staging')
  AND service.description IN ('Compute Engine', 'Kubernetes Engine')
GROUP BY project, service, sku
ORDER BY total_cost DESC
LIMIT 50
```

## Storage Breakdown

```sql
SELECT
  project.id                 AS project,
  sku.description            AS sku,
  SUM(cost)                  AS total_cost
FROM `{BILLING_TABLE}`
WHERE
  DATE(_PARTITIONTIME) >= @period_start
  AND DATE(_PARTITIONTIME) < @period_end
  AND project.id IN ('datum-cloud-prod', 'datum-cloud-staging')
  AND service.description = 'Compute Engine'
  AND (sku.description LIKE '%Storage%' OR sku.description LIKE '%Disk%')
GROUP BY project, sku
ORDER BY total_cost DESC
```

## 4-Month Trend by Service

Returns monthly totals for the trailing 4 calendar months to power the mermaid trend charts.
Run this query regardless of cadence mode — trend always covers the trailing 4 full months.

```sql
SELECT
  DATE_TRUNC(DATE(_PARTITIONTIME), MONTH)  AS month,
  project.id                               AS project,
  service.description                      AS service,
  SUM(cost)                                AS total_cost
FROM `{BILLING_TABLE}`
WHERE
  DATE(_PARTITIONTIME) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH), MONTH)
  AND project.id IN ('datum-cloud-prod', 'datum-cloud-staging')
GROUP BY month, project, service
ORDER BY month, total_cost DESC
```

Aggregate service rows into three buckets for charting:

| Chart bucket | Billing service rows |
|-------------|---------------------|
| Compute | Compute Engine, Kubernetes Engine |
| Storage | Cloud Storage, Filestore, plus storage/disk SKUs within Compute Engine |
| Other | Cloud SQL, Networking, and everything else |

## Cloud SQL Inventory

```bash
gcloud sql instances list \
  --project datum-cloud-prod \
  --format="table(name, databaseVersion, tier, settings.availabilityType, state, diskSizeGb)"

gcloud sql instances list \
  --project datum-cloud-staging \
  --format="table(name, databaseVersion, tier, settings.availabilityType, state, diskSizeGb)"
```

Cloud SQL cost from billing is often understated if disk size isn't exported. Use the
`diskSizeGb` field above to sanity-check storage costs.

## Live Node Pool Inventory

```bash
# Production
gcloud container node-pools list \
  --cluster infrastructure-control-plane-prod \
  --region us-east4 \
  --project datum-cloud-prod \
  --format="table(name, config.machineType, config.spot, autoscaling.minNodeCount, autoscaling.maxNodeCount, initialNodeCount)"

# Staging
gcloud container node-pools list \
  --cluster infrastructure-control-plane-staging \
  --region us-east4 \
  --project datum-cloud-staging \
  --format="table(name, config.machineType, config.spot, autoscaling.minNodeCount, autoscaling.maxNodeCount, initialNodeCount)"
```

Cross-reference the node pool list against the Pulumi/IaC config in the infrastructure repo.
Any pool not present in IaC should be flagged as drift in the Top Issues section.

## Live PVC Inventory

```bash
# Production
kubectl get pvc --all-namespaces --context infrastructure-control-plane-prod \
  -o custom-columns="NS:.metadata.namespace,NAME:.metadata.name,CLASS:.spec.storageClassName,CAPACITY:.status.capacity.storage"

# Staging
kubectl get pvc --all-namespaces --context infrastructure-control-plane-staging \
  -o custom-columns="NS:.metadata.namespace,NAME:.metadata.name,CLASS:.spec.storageClassName,CAPACITY:.status.capacity.storage"
```

Sum capacity by storage class; reconcile against the Storage section of the billing query output.
Significant gaps between provisioned and billed storage can indicate orphaned volumes.

## GCP List Prices (us-east4 Reference)

Use these for cost decomposition when billing data is aggregated and you need to back-calculate
per-node or per-GiB costs. These are on-demand list prices — actual bill may reflect CUDs or SUDs.

| Resource | Price |
|----------|-------|
| n1-standard-8 (on-demand) | ~$277/month |
| n2-standard-8 (on-demand) | ~$239/month |
| n2d-standard-8 (on-demand) | ~$228/month |
| n2d-standard-2 (on-demand) | ~$57/month |
| n2d-standard-2 (spot) | ~$17/month |
| c4d-standard-8 (on-demand) | ~$312/month |
| n2-standard-4 (on-demand) | ~$139/month |
| hyperdisk-balanced | $0.12/GiB/month |
| pd-ssd (`premium-rwo`) | $0.17/GiB/month |
| pd-balanced (`standard-rwo`) | $0.10/GiB/month |
| pd-standard | $0.04/GiB/month |
| GKE cluster fee | $72/month per cluster |
