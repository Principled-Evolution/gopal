---
name: add-framework
description: Scaffold a brand-new regulatory framework directory in GOPAL — creates the directory tree, framework README with source and disclaimer, and an initial seed policy + test. Use this when the user wants to start covering a new regulation that GOPAL doesn't track yet.
argument-hint: "<domain> <framework_name> <official_source_url>"
---

# Add Framework

Bootstrap a new regulatory framework directory in GOPAL.

## Inputs

- **domain** — One of: `international`, `industry_specific`, `operational`.
- **framework_name** — Short kebab-case or snake_case name (e.g. `uk_ai_principles`, `singapore_ai_verify`, `california_sb1047`).
- **official_source_url** — A canonical link to the regulation's text. This goes in the README and the seed policy metadata. If the user doesn't have one, stop and ask.

## Steps

1. **Confirm naming** — search for an existing directory under `<domain>/<framework_name>/`. If one exists, stop and refer the user to [draft-rego-policy](../draft-rego-policy/SKILL.md) instead.

2. **Create the directory structure**:
   ```
   <domain>/<framework_name>/v1/
   <domain>/<framework_name>/v1/README.md
   <domain>/<framework_name>/v1/<seed_policy>.rego
   <domain>/<framework_name>/v1/<seed_policy>_test.rego
   ```

3. **Write the framework README** at `<domain>/<framework_name>/v1/README.md`:

   ```markdown
   # <Human-Readable Framework Name> (v1)

   The policies in this directory encode requirements from the <regulation name>.

   **Source**: <official_source_url>

   **Disclaimer**: These policies are provided for informational purposes only and do not constitute legal advice. They represent the authors' interpretation of the source text in the Rego policy language and have not been certified by any regulatory body.

   ## Policies

   - `<seed_policy>` — <one-line description>
   ```

4. **Write a seed policy** — typically a high-level "framework-applies" gate. For example:

   ```rego
   package <domain>.<framework_name>.v1.applicability

   import data.helper_functions.reporting

   # METADATA
   # title: <Framework> applicability
   # description: Determines whether this framework applies to the AI system under evaluation.
   # version: 1
   # source: <official_source_url>

   default applies := false

   applies if {
       # TODO: encode the applicability criteria.
       # Example: jurisdiction match, AI system class, deployment context.
       input.system.jurisdiction == "<jurisdiction_code>"
   }

   report := reporting.compose_report(
       "<framework_name>.applicability",
       applies,
       [{"name": "applies", "value": applies, "control_passed": applies}],
   )
   ```

5. **Write the seed test**:

   ```rego
   package <domain>.<framework_name>.v1.applicability_test

   import data.<domain>.<framework_name>.v1.applicability

   test_applies_when_jurisdiction_matches if {
       applicability.applies with input as {
           "system": {"jurisdiction": "<jurisdiction_code>"}
       }
   }

   test_does_not_apply_by_default if {
       not applicability.applies with input as {}
   }
   ```

6. **Update the top-level [README.md](../../README.md)** — add the new framework to the coverage table in the "What's Inside" section with its policy count (`1` initially).

7. **Run the gates**:
   ```bash
   opa check --ignore custom/ .
   regal lint --ignore-files custom/ .
   ```

8. **Suggest follow-ups** — list 3-5 specific articles or sections from the source regulation that should become individual policies. Recommend the user run [draft-rego-policy](../draft-rego-policy/SKILL.md) for each.

## Notes

- Frameworks should map to a single published regulation, standard, or guideline. Don't create catch-all directories like `international/misc/`.
- If the regulation has versioned amendments, prefer `v1/` for the initial publication and add `v2/` later — don't try to encode multiple versions in one directory.
- The framework README must include a "Disclaimer" line stating these policies aren't legal advice. This is non-negotiable.
