---
name: status
description: Quick summary of recent cluster activity (last hour)
disable-model-invocation: true
argument-hint: "[time-range]"
model: haiku
---

Show a quick activity status for the cluster.

1. Call `summarize_recent_activity` with `startTime` set to "$ARGUMENTS"
   (default: "now-1h" if no argument provided).

2. If there are any failed operations in the summary, call
   `find_failed_operations` for the same time range (limit 5).

3. Format as a brief status block:
   - Total activities in the period
   - Top 3 actors and what they did
   - Top 3 most-changed resource kinds
   - Any failures (with status codes)

Keep it concise — this is a quick check, not a deep investigation.
