---
name: release
description: >
  Create a new GitHub release. Determines the next version from the latest tag,
  summarizes merged PRs since the last release, drafts release notes in the
  established style, and publishes via gh release create. Works for any
  datum-cloud service repository.
tools: Read, Bash
model: sonnet
context: fork
agent: general-purpose
argument-hint: "[vX.Y.Z] [--draft] [--patch|--minor|--major]"
---

# Release Command

Generate and publish a new GitHub release for this repository.

## Usage

```
/release                      Auto-determine next minor version and publish
/release v0.7.0               Publish a specific version tag
/release --patch              Bump patch (v0.6.0 → v0.6.1)
/release --minor              Bump minor (v0.6.0 → v0.7.0) — default
/release --major              Bump major (v0.6.0 → v1.0.0)
/release --draft              Create a draft release for review before publishing
```

## Arguments

Version or flags: $ARGUMENTS

---

## Workflow

### Step 1 — Determine the next version

```bash
# Get the latest tag
git tag --sort=-version:refname | head -1

# List recent releases for context
gh release list --limit 5
```

Parse the latest tag (e.g., `v0.6.0`) and bump the appropriate component:
- `--patch`: `v0.6.0` → `v0.6.1`
- `--minor` (default): `v0.6.0` → `v0.7.0`
- `--major`: `v0.6.0` → `v1.0.0`
- An explicit version argument overrides all flags.

### Step 2 — Collect merged PRs since the last release

```bash
# Get the publish date of the last release
gh release view <last-tag> --json publishedAt --jq '.publishedAt'

# List merged PRs since that date
gh pr list --state merged \
  --json number,title,author,mergedAt,labels,body \
  --search "merged:>YYYY-MM-DDTHH:MM:SSZ" | jq '.'
```

Filter out:
- Automated dependency bumps from `renovate[bot]` (unless they represent a significant upgrade worth calling out)
- PRs merged before the previous release date

Group remaining PRs into categories based on title prefix or labels:
- **Breaking changes** (`feat!`, `fix!`, or label `breaking-change`)
- **Features** (`feat:`)
- **Fixes** (`fix:`)
- **Infrastructure / chores** (`chore:`, `ci:`, `build:`)

### Step 3 — Detect project type and schema changes

Auto-detect what kind of project this is so the release note includes the right compatibility statement. Run these checks in order; a project may match more than one.

**Check 1 — CRD-based operator:**
```bash
# Look for generated CRD YAML files
find . -name '*.yaml' \( -path '*/crd/bases/*' -o -path '*/crds/*' \) | grep -v vendor | head -10
```

If CRD files are found, extract the kinds they define:
```bash
grep '^  name:' <crd-files> | awk '{print $2}' | sort -u
# or
grep -h 'kind:' <crd-files> | grep -v '#' | sort -u
```

Diff those files against the previous tag:
```bash
git diff <last-tag>...HEAD -- <crd-paths>
```

- Changed: note the affected resources and whether existing objects require migration.
- Unchanged: include `> No schema changes. Existing resources keep working without any conversion.`

**Check 2 — Aggregated API server:**
```bash
# Look for APIService registration manifests
find . -name '*.yaml' | xargs grep -l 'kind: APIService' 2>/dev/null | grep -v vendor | head -5

# Look for the aggregated apiserver binary entry point
find . -type d -name 'apiserver' | grep -E 'cmd/|server/' | grep -v vendor | head -5

# Look for the pkg/apis layout used by aggregated API servers
find . -type d -name 'registry' | grep -v vendor | head -5
```

If an aggregated API server is detected, find the API type files:
```bash
# Types live in Go files, not YAML — look for *_types.go under api/ or pkg/apis/
find . -name '*_types.go' | grep -v vendor | head -20
```

Diff those type files against the previous tag to detect schema changes:
```bash
git diff <last-tag>...HEAD -- $(find . -name '*_types.go' | grep -v vendor | tr '\n' ' ')
```

- Changed structs or fields: note that consumers using the Go client or REST API may be affected.
- Unchanged: include `> No API type changes. Existing clients and resources keep working without any update.`

**Check 3 — Go module name** (for import path callouts in breaking releases):
```bash
head -1 go.mod
```

**Check 4 — Container image** (for image ref callouts in breaking releases):
```bash
grep -r 'ghcr.io' .github/ Makefile config/ --include='*.yaml' --include='*.yml' -l 2>/dev/null | head -3
```

If neither CRDs nor an aggregated API server are found, omit the schema / compatibility section entirely.

### Step 4 — Draft release notes

Examine the last 2–3 releases with `gh release view <tag>` to match the established style and tone of this repository before writing new notes.

**Structure:**

```markdown
{One-sentence summary of the release theme.}

{Optional: > [!IMPORTANT] block for breaking changes — list exactly what
consumers must update: imports, image refs, install paths, CRD migrations, etc.}

## What's new

- **{Feature title}** — {one-sentence description}. ({PR link(s)})
- **{Fix title}** — {one-sentence description}. ({PR link(s)})

{Optional: > [!NOTE] block for schema/compatibility or upgrade notes}
```

**Style rules:**
- Each bullet leads with a **bold short title** followed by an em-dash (`—`), then a single sentence.
- Link every bullet to the PR(s) that delivered it: `([#N](url))`.
- Breaking changes go in a `> [!IMPORTANT]` callout above `## What's new`.
- Upgrade / compatibility notes go in a `> [!NOTE]` callout after `## What's new`.
- For CRD-based projects with no schema changes, add: `> No schema changes. Existing resources keep working without any conversion.`
- Omit routine dependency bumps unless the upgrade is significant (e.g., a major version of a core dependency).
- Release title format: `vX.Y.Z — {Short theme}` (em-dash, not a hyphen; omit if there is no clear theme).

### Step 5 — Confirm before publishing

Show the user:
- The proposed tag (`vX.Y.Z`)
- The release title
- The full release notes body

Ask for confirmation before running `gh release create`.

### Step 6 — Create the release

```bash
gh release create <tag> \
  --title "<tag> — <Short theme>" \
  --notes "$(cat <<'EOF'
<release notes body>
EOF
)" \
  [--draft]
```

If `--draft` was requested, skip publishing and return the draft URL for review.

---

## Output

```
Next version: v0.7.0 (minor bump from v0.6.0)
PRs since v0.6.0: 4 merged
Project type: CRD-based operator  |  aggregated API server  |  plain service
Schema changes: none  |  <list of changed resources>

Proposed release title: v0.7.0 — Webhook high availability

Release notes:
---
...
---

Publish this release? (yes/no)
```

After confirmation:

```
Release published: https://github.com/<org>/<repo>/releases/tag/v0.7.0
```

---

## Error Handling

**Uncommitted changes:**
```
Warning: you have uncommitted changes. Releases should be cut from a clean
main branch. Stash or commit changes before releasing.
```

**Not on main (or default branch):**
```
Warning: current branch is not main. Releases are typically cut from the
default branch. Confirm you want to release from: <branch-name>
```

**Tag already exists:**
```
Tag v0.7.0 already exists. Choose a different version or delete the existing
tag first: git tag -d v0.7.0 && git push origin :v0.7.0
```

**No previous release found:**
```
No previous release found. Collecting all merged PRs and generating
initial release notes.
```
