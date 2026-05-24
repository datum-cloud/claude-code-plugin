---
name: agpl-compliance
description: >
  Scan a project repository for strict AGPL-3.0 license compliance across Go, Rust, and
  JavaScript/React codebases. Use this skill whenever the user asks to check, audit, verify,
  or enforce AGPL license compliance on a project, repo, or codebase. Triggers on phrases like
  "check agpl compliance", "audit license headers", "is this project agpl compliant",
  "scan for license headers", "check my license files", "agpl audit", or any request involving
  ensuring a project is properly licensed under AGPL. Always use this skill — don't wing
  AGPL compliance checks from general knowledge.
---

# AGPL Compliance Skill

Perform a thorough, pragmatic AGPL-3.0 compliance audit on a project repository. Produce a
pass/fail summary with a prioritized violation list and concrete fix suggestions for each issue.

---

## Language Resources

Per-language skip rules, header placement, and correct header format are in:

| Language | Resource |
|----------|----------|
| Go | `resources/go.md` |
| Rust | `resources/rust.md` |
| JavaScript / TypeScript / React | `resources/javascript.md` |

**Before scanning source files**, read the resource file for each language present in the
repo. To add support for a new language, add a `resources/<lang>.md` following the same
structure as the existing files.

---

## Scope of Audit

### Source Files

Detect which languages are present by looking for `go.mod` (Go), `Cargo.toml` (Rust),
`package.json` (JS/TS). Read the corresponding resource file(s) to determine which files
are in scope and which to skip.

**Universal skip rules (all languages):**
- `vendor/`, `third_party/`, `testdata/` directories
- Protobuf-generated files (see per-language resource for specific patterns)
- Test fixtures that are pure data files with no logic
- Mock or generated client stubs

### Project-Level Files That MUST Exist

| File | Requirement |
|------|-------------|
| `LICENSE` or `LICENSE.md` or `COPYING` | Must contain the full AGPL-3.0 license text |
| `README.md` or `README` | Must reference AGPL-3.0 and include a short license section |

### Optional But Recommended

- `NOTICE` file — required if the project incorporates third-party code that mandates attribution

---

## Header Validation Rules (all languages)

- Must appear at the very top of the file (before package/import/use declarations)
  — see per-language resource for language-specific exceptions
- Must contain "GNU Affero General Public License" — not just "AGPL" or "AGPLv3"
- Must include the `<https://www.gnu.org/licenses/>` URL or equivalent
- Copyright year and author are required — flag if missing or placeholder (`<YEAR>`, `<AUTHOR>`)
- SPDX short-form (`// SPDX-License-Identifier: AGPL-3.0-or-later`) is acceptable
  IF accompanied by a full `LICENSE` file in the repo root; otherwise Critical

---

## Audit Procedure

### Step 1 — Locate the Repository Root

If the user provides a path, use it. Otherwise look for: `go.mod`, `Cargo.toml`,
`package.json`, `.git/`. Confirm the root before scanning.

### Step 2 — Load Language Resources

Check which languages are present and read the relevant files from `resources/`.

### Step 3 — Scan Project-Level Files

**LICENSE check:**
- File exists?
- Contains "GNU AFFERO GENERAL PUBLIC LICENSE" and "Version 3"?
- Is it the full text (not just a badge or a link)?

**README check:**
- File exists?
- Contains a license section (`## License`, `# License`, `### License`)?
- Does it name AGPL-3.0 explicitly?
- Does it link to the LICENSE file or `https://www.gnu.org/licenses/agpl-3.0.html`?

### Step 4 — Enumerate Source Files

Walk the directory tree. Apply skip rules from the language resource files. For each
in-scope file, read the first 30 lines and classify:

- ✅ **Compliant** — valid header present
- ❌ **Missing header** — no license header at all
- ⚠️ **Wrong license** — header present but not AGPL (MIT, Apache, proprietary, etc.)
- ⚠️ **Incomplete header** — partial AGPL text, missing required elements
- ⚠️ **Placeholder header** — `<YEAR>` or `<AUTHOR>` unfilled

### Step 5 — Compile the Report

```
## AGPL-3.0 Compliance Report — <project name>
**Status: PASS / FAIL**
Scanned: <N> files | Compliant: <N> | Violations: <N>

---

### Project-Level Files
| File     | Status   | Notes |
|----------|----------|-------|
| LICENSE  | ✅ / ❌  | ...   |
| README.md| ✅ / ❌  | ...   |

---

### Violations

#### Critical (blocks compliance)
- <file path> — <issue>
  **Fix:** <exact corrective action>

#### Advisory (should fix)
- <file path> — <issue>
  **Fix:** <exact corrective action>

---

### Skipped Files
<N> files skipped. List path patterns skipped.

---

### Suggested Header
<correct header for the detected copyright holder and year, ready to copy-paste>
```

**Severity classification:**

| Issue | Severity |
|-------|----------|
| Missing LICENSE file | Critical |
| LICENSE is wrong version (GPL-2.0, MIT, etc.) | Critical |
| Source file has wrong license header | Critical |
| Source file missing header entirely | Critical |
| README missing license section | Critical |
| SPDX short-form without full LICENSE file | Critical |
| Header has unfilled placeholders | Advisory |
| README has license section but no link | Advisory |

---

## Tone and Output

- State pass or fail up front.
- Group violations by severity — critical first.
- Give a one-line fix for every violation.
- More than 20 missing headers? List the first 10, summarize the rest. Offer to print the full list.
- Fully compliant? Say so clearly and move on.
- No padding.
