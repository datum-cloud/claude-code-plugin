---
name: investigate-incident
description: >
  Investigate a cluster incident by systematically checking recent activity,
  failed operations, and resource changes. Use when the user reports something
  is broken, asks "what happened", mentions an outage, incident, or error,
  or wants to understand recent cluster changes.
context: fork
agent: incident-investigator
---

Investigate the following incident:

$ARGUMENTS

Start by establishing the time window and scope from the description above.
If no time window is specified, default to the last 1 hour.
If no namespace or resource is specified, search across all namespaces.

Follow your investigation methodology and return a structured report with
timeline, key actors, failures, root cause hypothesis, and next steps.
