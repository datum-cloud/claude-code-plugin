---
name: preview-policy
description: >
  Test an ActivityPolicy against sample data and iterate on its rules.
  Use when the user wants to test, debug, or validate an existing or
  in-progress ActivityPolicy, or when they say "preview this policy"
  or "test this policy".
---

Test and validate an ActivityPolicy.

## Workflow

1. **Load the policy**: Read the ActivityPolicy YAML from the file or conversation
   context provided by the user.

2. **Run preview**: Call `preview_activity_policy` with the policy spec and
   `autoFetch: { limit: 20, timeRange: "24h", sources: "both" }` to test
   against real data.

3. **Analyze results**: For each input in the preview results:
   - Did it match a rule? Which one?
   - Is the generated summary accurate and readable?
   - Are there CEL evaluation errors?

4. **Report coverage**:
   - Rules that matched and their hit counts
   - Inputs that were **unmatched** (gaps in rule coverage)
   - Any CEL errors with explanations and suggested fixes

5. **Suggest improvements**: If rules have errors or many inputs are unmatched,
   propose new or modified rules.

6. **Re-preview**: After making changes, preview again to verify fixes.

$ARGUMENTS
