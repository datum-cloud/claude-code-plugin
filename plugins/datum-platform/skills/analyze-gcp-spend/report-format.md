# Report Format and Publishing

## File Convention

| Attribute | Value |
|-----------|-------|
| Repo | `/workspace/engineering` |
| Path | `reports/gcp-spend/YYYY-MM-DD-gcp-spend.md` |
| Branch | `ops/gcp-spend-YYYY-MM-DD` |
| PR title (full month) | `Ops Review: GCP spend [Month YYYY] — full month` |
| PR title (MTD) | `Ops Review: GCP spend YYYY-MM-DD` |

`YYYY-MM-DD` is today's date (the run date). The reporting period is described inside the report.

## Report Structure

```markdown
# GCP Spend Analysis — [Month YYYY | MTD YYYY-MM-DD]
*As of YYYY-MM-DD. Computed from BigQuery billing export × live cluster state (us-east4).
[No CUD discounts applied. | CUD/SUD discounts reflected.]*

## Summary: ~$X,XXX/month

| Environment | Cost |
|-------------|------|
| Production | $X,XXX |
| Staging | $X,XXX |
| **Total** | **$X,XXX** |

---

## Compute: $X,XXX/month

| Count | Instance | Type | Pool | $/month |
|-------|----------|------|------|---------|
| N× | machine-type | ON-DEMAND / SPOT | pool-name | $X,XXX |

## Storage: $X,XXX/month

| Storage class | Total | Rate | $/month |
|--------------|-------|------|---------|
| `hyperdisk-balanced` | N GiB | $0.12/GiB | $X,XXX |
| `premium-rwo` (pd-ssd) | N GiB | $0.17/GiB | $X,XXX |
| `standard-rwo` (pd-balanced) | N GiB | $0.10/GiB | $X,XXX |

## Cloud SQL: ~$XXX/month (estimated)

[Tier, HA config, disk size if available. Note if disk size unknown and why.]

---

## 4-Month Spend Trend

### Total Monthly Spend (Production + Staging)

Replace x-axis labels with the actual trailing 4 month abbreviations and fill in dollar totals.

```mermaid
xychart-beta
  title "GCP Monthly Spend — datum-cloud (prod + staging)"
  x-axis ["Mon-1", "Mon-2", "Mon-3", "Mon-4"]
  y-axis "USD" 0 --> UPPER
  bar [TOTAL-1, TOTAL-2, TOTAL-3, TOTAL-4]
```

### Spend by Category (Production)

Three series: Compute, Storage, Other. Pull from the 4-month trend query bucketed by category.

```mermaid
xychart-beta
  title "Production: Monthly Spend by Category"
  x-axis ["Mon-1", "Mon-2", "Mon-3", "Mon-4"]
  y-axis "USD" 0 --> UPPER
  line [COMPUTE-1, COMPUTE-2, COMPUTE-3, COMPUTE-4]
  line [STORAGE-1, STORAGE-2, STORAGE-3, STORAGE-4]
  line [OTHER-1, OTHER-2, OTHER-3, OTHER-4]
```

*Series order: Compute Engine + GKE, Storage, Cloud SQL + Networking*

### Production vs Staging Split

```mermaid
xychart-beta
  title "Monthly Spend: Production vs Staging"
  x-axis ["Mon-1", "Mon-2", "Mon-3", "Mon-4"]
  y-axis "USD" 0 --> UPPER
  bar [PROD-1, PROD-2, PROD-3, PROD-4]
  bar [STAGING-1, STAGING-2, STAGING-3, STAGING-4]
```

*First bar series = Production, second bar series = Staging*

**Chart tips:**
- Set `UPPER` to the maximum monthly total rounded up by ~20% so bars aren't clipped
- Use abbreviated month names: Jan, Feb, Mar, Apr (or whichever 4 trailing months apply)
- Omit chart series that are zero or negligible (< 1% of total)

---

## Top Issues

Sort descending by dollar impact. Include an estimate for each.

### 1. [Issue Name] — ~$X,XXX/month [combined | estimated]
- Bullet: specific resource or pool driving the cost
- Bullet: question or finding (e.g. is utilization matching provisioned capacity?)
- Bullet: comparison to prior month if notable

[Repeat for each significant cost driver. Aim for 4–6 issues.]

---

## Recent Changes That Drove Cost

| Date | Change | Impact |
|------|--------|--------|
| YYYY-MM-DD | Description | +/- ~$X/month |

Pull from git log of the infrastructure/Pulumi repo and compare to prior period node pool and
PVC state. Flag spot→on-demand transitions, new pools, and PVC resizes.

---

## Optimization Opportunities

| Action | Estimated Saving |
|--------|-----------------|
| Description | ~$X/month |

---

## Notes

- Edge clusters excluded (non-GCP infrastructure)
- List prices used; actual bill may be lower with active CUDs or negotiated rates
- [Any estimates or unknowns, e.g. Cloud SQL disk size not exported to billing]
```

## Mermaid Chart Guidelines

- Use `xychart-beta` — it renders in GitHub PR previews
- X-axis: abbreviated month names for the trailing 4 months (e.g. `["Jan", "Feb", "Mar", "Apr"]`)
- Y-axis upper bound (`UPPER`): round the maximum value up by ~20%
- `bar` for total and per-environment breakdown; `line` for multi-series category breakdown
- Keep x-axis labels consistent across all three charts in the same report
- If a month is partial (current MTD), label it `"Apr*"` with a footnote

## PR Body Template

```markdown
## Ops Review — GCP Spend Analysis

[Full month retrospective for {Month YYYY} | MTD snapshot through {YYYY-MM-DD}]

## Summary

- **$X,XXX total** (production $X,XXX · staging $X,XXX)
- **Top cost driver:** {driver} (~$X,XXX/month)
- **{N} optimization opportunities** identified (~$X,XXX combined potential savings)
- {One-line notable finding, e.g. IaC drift}
- {One-line notable finding, e.g. generation-penalty nodes}

## Report

`reports/gcp-spend/YYYY-MM-DD-gcp-spend.md`
```

## Git Workflow

```bash
# From /workspace/engineering
git checkout main && git pull
git checkout -b ops/gcp-spend-YYYY-MM-DD
mkdir -p reports/gcp-spend
# Write the report file, then:
git add reports/gcp-spend/YYYY-MM-DD-gcp-spend.md
git commit -m "ops: add GCP spend report for YYYY-MM-DD"
git push -u origin ops/gcp-spend-YYYY-MM-DD
gh pr create \
  --title "Ops Review: GCP spend YYYY-MM-DD" \
  --body "$(cat <<'EOF'
## Ops Review — GCP Spend Analysis
...
EOF
)"
```

## Incremental Updates

If run a second time in the same period (e.g. to correct a figure or add a section):

1. Check out the existing branch: `git checkout ops/gcp-spend-YYYY-MM-DD`
2. Update only the changed figures or add the new section in the appropriate position
3. Commit: `ops: update GCP spend report YYYY-MM-DD — {what changed}`
4. Push — the existing PR updates automatically; no new PR needed
