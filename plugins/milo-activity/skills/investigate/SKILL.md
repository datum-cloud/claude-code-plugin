---
name: investigate
description: Start an incident investigation with a description of the issue
disable-model-invocation: true
argument-hint: "<description of the incident>"
context: fork
agent: incident-investigator
---

<!-- Manual slash-command entry point: /milo-activity:investigate <description>
     The investigate-incident skill handles auto-invocation for the same workflow. -->

Investigate the following incident:

$ARGUMENTS

Start by establishing the time window and scope from the description above.
If no time window is specified, default to the last 1 hour.
If no namespace or resource is specified, search across all namespaces.

Follow your investigation methodology and return a structured report with
timeline, key actors, failures, root cause hypothesis, and next steps.
