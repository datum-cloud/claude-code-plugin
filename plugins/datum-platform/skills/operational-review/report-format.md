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
# Datum Traffic Report — YYYY-MM-DD

**Period:** YYYY-MM-DD through YYYY-MM-DD
**Source:** `envoy_http_downstream_rq_total`, `envoy_http_downstream_rq_time_bucket` via VictoriaMetrics (prod)
**Scope:** Global Envoy edge ingress across all POPs

---

## Summary

| Metric | Value |
|--------|-------|
| POPs reporting | N |
| Weekly average | N RPS |
| Baseline range | N–N RPS |
| Peak (1m resolution) | **N RPS** |

---

## Daily Averages

| Date | Avg RPS |
|------|--------:|
| ... | ... |

---

## Notable Spikes (>150 RPS)

| Timestamp (UTC) | RPS |
|-----------------|----:|
| ... | ... |

---

## Latency (ms)

Global aggregate across all POPs.

| Date | P50 avg | P50 max | P90 avg | P90 max | P95 avg | P95 max |
|------|--------:|--------:|--------:|--------:|--------:|--------:|
| ... | ... | ... | ... | ... | ... | ... |
| **Weekly** | **N** | **N** | **N** | **N** | **N** | **N** |

**Note:** [Explain any notable pattern in the distribution, e.g. bimodal split.]

---

## Latency by POP (weekly median, ms)

Sorted by P90. Spikes excluded from median; noted separately.

| Cluster | P50 | P90 | P95 | Anomalies |
|---------|----:|----:|----:|-----------|
| ... | ... | ... | ... | ... |

**Key findings:**
- [Fastest POP]
- [Slowest POP]
- [Any incident-level anomalies]

---

## Per-POP Breakdown

| Cluster | Avg RPS | Peak RPS |
|---------|--------:|---------:|
| ... | ... | ... |

---

## Observations

- [Control plane traffic share]
- [Edge POP burst leaders]
- [Spike correlation notes]
- [Any persistent issues flagged]
```

## PR Body Template

```markdown
## Ops Review — Global Envoy Edge Ingress Traffic

Weekly traffic report for {period}, sourced from VictoriaMetrics prod.

## Summary

- **{N} POPs** reporting
- **{N} RPS** weekly average; baseline {N}–{N} RPS
- **{N} RPS** peak (1m resolution, {timestamp})
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

If asked to add data to an existing report (e.g. "add latencies"), amend the report in place:

1. Read the current file
2. Add the new section in the appropriate position (Latency before Per-POP Breakdown)
3. Update the `**Source:**` line to include the new metric
4. Commit with a short message: `ops: add {section} to traffic report`
5. Push — the existing PR updates automatically
