---
name: activity-summary
description: >
  Generate a summary of recent cluster activity for handoffs, standups,
  or status updates. Use when the user asks for a status update, what
  happened recently, needs a summary for a handoff, or says "catch me up".
model: haiku
---

Generate a concise activity summary.

1. Call `summarize_recent_activity` for the requested time range.
   Default to "last 24 hours" for handoffs/standups, "last 1 hour" for quick checks.

2. Call `get_activity_timeline` with an appropriate bucket size
   (e.g., "1h" for 24h range, "5m" for 1h range) to show activity distribution.

3. If the user wants to know if current activity is unusual, call
   `compare_activity_periods` comparing the current window to the same
   duration immediately before.

4. Format output as a concise status report:
   - **Highlights**: Top 3-5 notable changes
   - **Top actors**: Who was most active
   - **Most changed resources**: Which resource kinds saw the most activity
   - **Failures**: Any failed operations (if any)
   - **Activity pattern**: Whether activity is normal, elevated, or reduced

$ARGUMENTS
