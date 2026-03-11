# CEL Reference for ActivityPolicy Rules

## Audit Rule Variables

### `audit` (map)
The full audit log entry. Key fields:
- `audit.verb` — string: "create", "update", "patch", "delete", "get", "list", "watch"
- `audit.objectRef.resource` — string: resource type (e.g., "httpproxies")
- `audit.objectRef.name` — string: resource name
- `audit.objectRef.namespace` — string: namespace
- `audit.objectRef.apiGroup` — string: API group
- `audit.user.username` — string: authenticated username
- `audit.responseStatus.code` — int: HTTP status code
- `audit.responseObject` — map: the response resource (for create/get)
- `audit.requestObject` — map: the request body (for create/update/patch)

### `actor` (string)
Convenience variable: the username extracted from `audit.user.username`.

### `actorRef` (map)
Reference to the actor with fields:
- `actorRef.type` — string: "user", "serviceaccount", "system", or "unknown"
- `actorRef.name` — string: the actor's name

### `kind` (string)
The plural resource name (lowercase) extracted from `audit.objectRef.resource`.
For example: `"httpproxies"`, `"pods"`, `"deployments"` — not the PascalCase Kind like `"HTTPProxy"`.

## Event Rule Variables

### `event` (map)
The full Kubernetes Event. Key fields:
- `event.reason` — string: e.g., "Programmed", "FailedCreate", "ScalingReplicaSet"
- `event.type` — string: "Normal" or "Warning"
- `event.note` — string: human-readable event message
- `event.regarding.name` — string: resource name the event is about
- `event.regarding.namespace` — string: namespace
- `event.regarding.kind` — string: resource kind
- `event.reportingController` — string: controller that reported the event
- `event.source.component` — string: source component name

### `actor` (string)
Controller name extracted from `event.reportingController` or `event.source.component`.

### `actorRef` (map)
Reference to the actor:
- `actorRef.type` — always "controller"
- `actorRef.name` — the controller name

## Functions

### `link(displayText string, resourceRef map) -> string`
Creates a clickable resource reference in the activity UI.

**Parameters:**
- `displayText` — text to display (e.g., `"HTTPProxy my-proxy"`)
- `resourceRef` — map identifying the resource (typically `audit.responseObject` or `audit.requestObject`)

**Example:**
```
link(kind + ' ' + audit.objectRef.name, audit.responseObject)
```

## Summary Template Syntax

Summaries use `{{ CEL expression }}` delimiters. Each expression must return a string.
Multiple expressions can appear in one summary.

**Examples:**
```
{{ actor }} created {{ link(kind + ' ' + audit.objectRef.name, audit.responseObject) }}
{{ actor }} updated {{ kind }} {{ audit.objectRef.name }} in namespace {{ audit.objectRef.namespace }}
{{ actor }} performed {{ audit.verb }} on {{ kind }} {{ audit.objectRef.name }}
```

## Common Match Patterns

| Pattern | Description |
|---------|-------------|
| `audit.verb == 'create'` | Matches resource creation |
| `audit.verb in ['update', 'patch']` | Matches modifications |
| `audit.verb == 'delete'` | Matches deletion |
| `event.reason == 'Programmed'` | Matches specific event reason |
| `event.type == 'Warning'` | Matches warning events |
| `event.reason.startsWith('Failed')` | Matches failure events |
| `true` | Fallback — matches everything (must be last rule) |

## Rule Evaluation

- Rules are evaluated **in order** — first match wins
- Always include a **fallback rule** with `match: "true"` as the last rule
- Name rules descriptively for debugging (e.g., "create-resource", "scale-replicas")
