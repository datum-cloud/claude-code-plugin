---
name: author-policy
description: >
  Create or edit an ActivityPolicy that translates audit logs or events into
  human-readable activity summaries. Use when the user mentions ActivityPolicy,
  wants to create translation rules, asks about CEL expressions for activity,
  or wants to define how changes appear in the activity timeline.
---

Help the user create or edit an ActivityPolicy.

For detailed CEL variable definitions and function reference, see
[cel-functions.md](reference/cel-functions.md).

## Workflow

1. **Identify the target resource**: What API group and kind should this policy cover?
   Check existing policies with `list_activity_policies`.

2. **Discover available data**: Use `get_audit_log_facets` and `get_event_facets`
   to see what data exists for the target resource.

3. **Fetch samples**: Use `query_audit_logs` (limit 5) filtered to the target
   resource to see real field values.

4. **Draft the policy**: Create ActivityPolicy YAML with rules for common verbs.
   Use the CEL reference for variable names and template syntax.

5. **Preview**: Call `preview_activity_policy` with `autoFetch` enabled to test.

6. **Iterate**: Fix errors, improve summaries, add rules for unmatched inputs.

7. **Save**: Write the final YAML file.

## Quick Example

```yaml
apiVersion: activity.miloapis.com/v1alpha1
kind: ActivityPolicy
metadata:
  name: example-resource-policy
spec:
  resource:
    apiGroup: example.datumapis.com
    kind: ExampleResource
  auditRules:
    - name: create
      match: "audit.verb == 'create'"
      summary: "{{ actor }} created {{ link(kind + ' ' + audit.objectRef.name, audit.responseObject) }}"
    - name: update
      match: "audit.verb in ['update', 'patch']"
      summary: "{{ actor }} updated {{ link(kind + ' ' + audit.objectRef.name, audit.responseObject) }}"
    - name: delete
      match: "audit.verb == 'delete'"
      summary: "{{ actor }} deleted {{ kind }} {{ audit.objectRef.name }}"
    - name: fallback
      match: "true"
      summary: "{{ actor }} performed {{ audit.verb }} on {{ kind }} {{ audit.objectRef.name }}"
```

$ARGUMENTS
