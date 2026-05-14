---
name: explain-framework
description: Walk every Rego policy in a framework directory and produce a plain-English audit-grade summary of what each one enforces. Use this when the user wants to understand what coverage GOPAL provides for a given regulation before applying it.
argument-hint: "<framework path, e.g. international/eu_ai_act/v1>"
---

# Explain Framework

Produce an auditor-readable summary of what every policy under a given framework directory checks.

## Steps

1. **Resolve the framework directory** — expect a path like:
   - `international/eu_ai_act/v1/`
   - `industry_specific/aviation/v1/`
   - `operational/corporate/v1/`
   - `global/v1/`

   If the path doesn't exist, list adjacent valid options and stop.

2. **Enumerate policies** — list every `.rego` file in the directory except those ending in `_test.rego` or named `README.md`.

3. **For each policy**:
   - Read it.
   - Extract the `# METADATA` block (title, description, version, source).
   - Identify the package path.
   - Identify the `default allow` line and the body of the `allow if { ... }` rule.
   - Translate the rule conditions into plain English. Don't paraphrase — describe specifically what fields of `input` must be true/false/set/equal.

4. **Produce a structured output**:

   ```
   # Framework: <human-readable name>

   **Source**: <link from any README.md in the directory>
   **Disclaimer**: These policies are an interpretation of the source text in Rego; they are not legal advice.

   ## Policies (N total)

   ### <policy_name>
   - **Package**: `<domain>.<framework>.v1.<policy_name>`
   - **Title**: <from metadata>
   - **Description**: <from metadata>
   - **Rule**: <plain-English translation of the allow conditions>
   - **Source**: <from metadata>

   <repeat for each policy>

   ## Coverage Summary
   - Total policies: N
   - Tests present: N
   - Articles / sections explicitly covered: <list if discernible from metadata>
   - Gaps surfaced: <any obvious un-covered concerns>
   ```

5. **Cross-link**:
   - If [AICertify](https://github.com/Principled-Evolution/aicertify) vendors these policies, mention it.
   - Link the framework README if it exists.

## Notes

- Be brutally honest about placeholders. If a policy file is empty, has only a default rule with no logic, or contains TODO comments, label it clearly: 🚧 placeholder.
- Don't editorialize about whether the regulation is "good" or "well-written" — just describe what the encoded rules check.
- If a metadata block is missing, flag that — it's a violation of GOPAL conventions.
