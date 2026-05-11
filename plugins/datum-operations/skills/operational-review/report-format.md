# Report Format and Publishing

## File Convention

| Attribute | Value |
|-----------|-------|
| Repo | `~/src/datum-cloud/engineering` |
| Path | `reviews/ai-edge/YYYY-MM-DD-edge-ops-review.md` |
| Branch | `ops/traffic-report-YYYY-MM-DD` |
| PR title | `Ops Review: Weekly traffic report YYYY-MM-DD` |

`YYYY-MM-DD` is today's date (end of the reporting period).

## Report Structure

```markdown
# Datum AI Edge — Ops Review YYYY-MM-DD

**Period:** YYYY-MM-DD through YYYY-MM-DD
**Source:** VictoriaMetrics (prod)
**Scope:** Edge traffic, top consumers, error rates, control plane provisioning

---

## Summary

| Metric | Value |
|--------|-------|
| POPs reporting | N |
| Weekly average RPS | N |
| Baseline range | N–N RPS |
| Peak (1m resolution) | **N RPS** |
| Global P90 latency (weekly median) | N ms |
| AI edges active | N |
| AI edges created this week | N |
| Overall 5xx error rate | N% |

### Key Findings

Promote findings here if they are action-required or incident-level. Leave out
baseline/expected behavior. Use ⚠ for items needing investigation, ℹ for notable
but non-urgent context.

- ⚠ [Highest-priority finding — one line, with timestamp and magnitude]
- ⚠ [Second priority finding]
- ℹ [Notable but non-urgent observation]

---

## Open Incidents

Incidents from `datum-cloud/engineering` with label `:incident/issue` that are open or
were opened/closed during the report period, filtered for AI Edge relevance.

| # | Title | Status | Opened | Correlation |
|---|-------|--------|--------|-------------|
| [#N](link) | ... | OPEN / Closed YYYY-MM-DD | YYYY-MM-DD | [metric anomaly or "none"] |

> If no relevant incidents: *No open incidents affecting AI Edge during this period.*

---

## Edge Traffic

### Daily Averages

| Date | Avg RPS |
|------|--------:|
| ... | ... |

### Notable Spikes (>150% of weekly avg)

| Timestamp (UTC) | RPS | Correlated event |
|-----------------|----:|-----------------|
| ... | ... | ... |

### Latency (ms)

Global aggregate across all POPs.

| Date | P50 avg | P50 max | P90 avg | P90 max | P95 avg | P95 max |
|------|--------:|--------:|--------:|--------:|--------:|--------:|
| ... | ... | ... | ... | ... | ... | ... |
| **Weekly** | **N** | **N** | **N** | **N** | **N** | **N** |

**Note:** [Explain any notable distribution pattern, e.g. bimodal split.]

### Latency by POP (weekly median, ms)

Sorted by P90. Spikes excluded from median; noted separately.

| Cluster | P50 | P90 | P95 | Anomalies |
|---------|----:|----:|----:|-----------|
| ... | ... | ... | ... | ... |

**Key findings:**
- [Fastest POP]
- [Slowest POP]
- [Incident-level anomalies]

### Per-POP Breakdown

| Cluster | Avg RPS | Peak RPS |
|---------|--------:|---------:|
| ... | ... | ... |

---

## Project Count and Control Plane Health

Added after datum-cloud/infra#2220: high project count drives Kyverno informer cache growth
and admission controller memory pressure.

| Metric | Value | vs last week |
|--------|-------|-------------|
| Total projects | N | +N |
| New projects this week | N | — |
| Kyverno UpdateRequest backlog | N | +N |
| Kyverno admission memory utilization | N% of NMi limit | — |
| Kyverno admission restarts this week | N | — |

**Memory headroom runway** (at current growth rate): _N weeks until 90% utilization_

Flag in Key Findings if:
- UpdateRequest backlog > 1,000
- Memory utilization > 70%
- Any admission controller restarts occurred

---

## Top Consumers

### Edge traffic

Top 10 projects by upstream RPS. Source: `envoy_cluster_upstream_rq_total` by
`httproute_namespace`, joined with `kube_namespace_labels` to resolve project name.
See `consumer-identity.md` and `queries.md` for the full expressions.

| Project | Avg RPS | P90 latency | 4xx rate | 5xx rate |
|---------|--------:|------------:|---------:|---------:|
| ... | ... | ... ms | ...% | ...% |

### Control plane

Top 10 projects by API request volume. Source: `apiserver_request_total` by `namespace`,
same join pattern.

| Project | Avg API RPS | Error rate |
|---------|------------:|-----------:|
| ... | ... | ...% |

### New Projects This Week

Source: `ProjectControlPlane` resources with `creationTimestamp` within the report period.

| Owner | Project | Created |
|-------|---------|---------|
| ... | ... | ... |

---

## Error Codes by API Group

### Edge (Envoy)

| API Group / Route | 4xx Rate | 5xx Rate | Notes |
|-------------------|--------:|--------:|-------|
| ... | ...% | ...% | ... |

**Overall 5xx rate:** N% (threshold: 1%)

### Control Plane (API Server)

| API Group | Code | Rate | Notes |
|-----------|------|-----:|-------|
| ... | ... | ... | ... |

**Webhook admission rejections:** [N rejections by webhook name, or "none"]

---

## Control Plane: AI Edge Provisioning

| Metric | Value |
|--------|-------|
| AI edges active | N |
| Created this week | N |
| Scheduling P90 | N s |
| Propagation P90 (time-to-ready) | N s |
| Binding failures | N |

### Provisioning Latency by Member Cluster

| Cluster | Propagation P90 | Anomalies |
|---------|----------------:|-----------|
| ... | ... s | ... |

**Key findings:**
- [Fastest cluster]
- [Slowest cluster]
- [Any binding failures or scheduler errors]

---

```

## PR Body Template

```markdown
## Ops Review — Datum AI Edge

Weekly operational report for {period}, sourced from VictoriaMetrics prod.

## Summary

- **{N} POPs** reporting
- **{N} RPS** weekly average; baseline {N}–{N} RPS; peak **{N} RPS** at {timestamp}
- Global P90 latency: **{N} ms** weekly median
- **{N} AI edges** active; **{N}** created this week
- 5xx error rate: **{N}%** overall
- {One-line notable finding}
- {One-line notable finding}

## Report

`reviews/ai-edge/YYYY-MM-DD-edge-ops-review.md`
```

## Git Workflow

```bash
# From ~/src/datum-cloud/engineering
git checkout main && git pull
git checkout -b ops/traffic-report-YYYY-MM-DD
mkdir -p reviews/ai-edge
# Write report file
git add reviews/ai-edge/YYYY-MM-DD-edge-ops-review.md
git commit -m "ops: add weekly traffic report for YYYY-MM-DD"
git push -u origin ops/traffic-report-YYYY-MM-DD
PR_URL=$(gh pr create --title "Ops Review: Weekly traffic report YYYY-MM-DD" --body "..." | tail -1)

# Find the current on-call issue and drop a comment linking the review
ONCALL_ISSUE=$(gh issue list \
  --repo datum-cloud/engineering \
  --search "on-call: week of" \
  --state open \
  --json number,title \
  --jq '.[0].number')

gh issue comment "$ONCALL_ISSUE" \
  --repo datum-cloud/engineering \
  --body "Weekly traffic report open for review: $PR_URL"
```

## Incremental Updates

If asked to add data to an existing report (e.g. "add latencies", "add consumer breakdown"):

1. Read the current file
2. Add the new section in the appropriate position (follow the structure order above)
3. Update the `**Source:**` line to include the new metric if needed
4. Commit with a short message: `ops: add {section} to traffic report`
5. Push — the existing PR updates automatically
