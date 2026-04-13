# Report Format and Publishing

## File Convention

| Attribute | Value |
|-----------|-------|
| Repo | `~/src/datum-cloud/engineering` |
| Path | `reports/traffic/YYYY-MM-DD-datum-traffic.md` |
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

## Top Consumers

### Control Plane (available)

Top 10 projects by API request volume. Source: `apiserver_request_total` by `namespace`,
joined with `ProjectControlPlane` resources for owner resolution.

| Owner | Project | Avg RPS | Error rate | Notable pattern |
|-------|---------|--------:|----------:|-----------------|
| ... | ... | ... | ...% | ... |

### Edge (not yet available)

Per-consumer edge breakdown requires tenant identity to be propagated to Envoy metrics.
See `consumer-identity.md` for the options. Until resolved, note:

> Consumer-level edge segmentation is unavailable. Envoy metrics carry only infrastructure
> namespace labels. See `consumer-identity.md` for remediation options.

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

## Observations

- [Control plane traffic share]
- [Edge POP burst leaders]
- [Spike correlation notes]
- [Consumer concentration or growth trends]
- [Persistent error patterns]
- [Provisioning health summary]
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

`reports/traffic/YYYY-MM-DD-datum-traffic.md`
```

## Git Workflow

```bash
# From ~/src/datum-cloud/engineering
git checkout main && git pull
git checkout -b ops/traffic-report-YYYY-MM-DD
mkdir -p reports/traffic
# Write report file
git add reports/traffic/YYYY-MM-DD-datum-traffic.md
git commit -m "ops: add weekly traffic report for YYYY-MM-DD"
git push -u origin ops/traffic-report-YYYY-MM-DD
gh pr create --title "Ops Review: Weekly traffic report YYYY-MM-DD" --body "..."
```

## Incremental Updates

If asked to add data to an existing report (e.g. "add latencies", "add consumer breakdown"):

1. Read the current file
2. Add the new section in the appropriate position (follow the structure order above)
3. Update the `**Source:**` line to include the new metric if needed
4. Commit with a short message: `ops: add {section} to traffic report`
5. Push — the existing PR updates automatically
