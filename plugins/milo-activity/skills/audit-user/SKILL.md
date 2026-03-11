---
name: audit-user
description: >
  Audit a specific user's recent actions across all resources. Use when the
  user asks about what someone did, requests a user activity report, or needs
  to review actions for security or compliance purposes.
context: fork
agent: incident-investigator
---

Audit the activity of the following user:

$ARGUMENTS

## Your Task

1. Call `get_user_activity_summary` with `includeDetails: true` for this user
   to get an overview and recent activities.

2. Call `find_failed_operations` filtered to this user to identify any
   permission issues or errors they encountered.

3. Call `get_activity_facets` for Activity resource fields `spec.resource.kind`
   and `spec.resource.namespace` filtered to this user to understand their
   scope of changes.

4. Present a structured report:
   - **Summary**: Total actions, time range covered
   - **Resources touched**: Which kinds and namespaces
   - **Actions by type**: Creates, updates, deletes
   - **Failures**: Any failed operations with status codes
   - **Timeline**: Chronological list of significant actions
