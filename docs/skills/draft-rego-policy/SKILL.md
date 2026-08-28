---
name: draft-rego-policy
description: Scaffold a new GOPAL Rego policy file with full metadata, default rule, reporting helper integration, and a sibling test file. Use this when the user wants to add coverage for a new regulation article, industry rule, or operational policy.
argument-hint: "<domain> <framework> <policy_name>"
---

# Draft Rego Policy

Generate a new Rego policy + test file matching GOPAL's strict authoring conventions.

## Inputs

- **domain**: One of: `global`, `international`, `industry_specific`, `operational`.
- **framework**: Existing framework name (e.g. `eu_ai_act`) OR new. Confirm with the user before creating a new framework directory; prefer [add-framework](../add-framework/SKILL.md) for that.
- **policy_name**: `snake_case` filename without `.rego` suffix.

## Steps

1. **Confirm directory layout**:
   ```
   <domain>/<framework>/v1/<policy_name>.rego
   <domain>/<framework>/v1/<policy_name>_test.rego
   ```
   The package path MUST match the directory path. Create the directory if it doesn't exist.

2. **Write the policy file**: fill in title, description, version, source:

   ```rego
   package <domain>.<framework>.v1.<policy_name>

   import data.helper_functions.reporting

   # METADATA
   # title: <one-line summary>
   # description: <what this rule enforces; quote the article/section being encoded>
   # version: 1
   # source: <URL to the official regulation or standard>

   default allow := false

   allow if {
       # Encode the rule. Reference fields like:
       #   input.system.<field>
       #   input.metrics[_].<field>
       true
   }

   report := reporting.compose_report(
       "<framework>.<policy_name>",
       allow,
       [{"name": "<metric_name>", "value": allow, "control_passed": allow}],
   )
   ```

3. **Write the test file**: both `allow` and `deny` paths must be tested:

   ```rego
   package <domain>.<framework>.v1.<policy_name>_test

   import data.<domain>.<framework>.v1.<policy_name>

   test_allow_when_compliant if {
       <policy_name>.allow with input as {
           "system": { /* TODO: compliant shape */ }
       }
   }

   test_deny_when_field_missing if {
       not <policy_name>.allow with input as {}
   }
   ```

4. **Update the framework README** at `<domain>/<framework>/v1/README.md` to add the new policy to the list. If the README doesn't exist, prompt the user to run the [add-framework](../add-framework/SKILL.md) skill first.

5. **Run the CI gates**:
   ```bash
   opa check --ignore custom/ .
   regal lint --ignore-files custom/ .
   ```

6. **Fix any Regal warnings**: look them up in the [Regal rule catalog](https://docs.styra.com/regal/rules). Do NOT silence rules by adding to `.regal/config.yaml` without explicit user approval.

7. **Final reminders**:
   - The `# METADATA` `source:` URL is mandatory: auditors and downstream tooling rely on it.
   - Helpers in `helper_functions/` (reporting, validation) should be used for output composition. Don't roll your own.
   - GOPAL is consumed by [AICertify](https://github.com/Principled-Evolution/aicertify); a new policy here automatically becomes available there on next vendor sync.
