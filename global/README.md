# Global Policies

This directory contains cross-cutting policies that apply across domains and are not tied to any single regulatory framework or industry.

## Directory Structure

- **v1/**: Version 1 of global policies
  - `accountability/accountability.rego`
  - `fairness/fairness.rego`
  - `toxicity/toxicity.rego`
  - `transparency/transparency.rego`
  - `common/` — shared building blocks imported by policies elsewhere in the repo (`common_rules.rego`, `compliance.rego`, `content_safety.rego`, `fairness.rego`, `risk_management.rego`). These aren't standalone policies with their own verdict; they're functions other packages import, e.g. `import data.global.v1.common.fairness as common_fairness`.

9 policies total, including the `common/` helpers.

## Usage

Global policies provide a baseline set of requirements that most AI systems should meet regardless of industry or jurisdiction. Use them standalone, or compose them with a more specific international or industry-specific policy.

## Adding New Policies

When adding new global policies:
1. Place them under `v1/<policy_area>/`
2. Follow the naming convention: `<policy_area>.rego` (+ sibling `<policy_area>_test.rego`)
3. Use the package name `global.v1.<policy_area>`
4. Include a `# METADATA` block with title, description, version, and source references

If you're adding a function meant to be reused by other packages rather than a standalone policy, it belongs under `common/`, following the existing files there as the pattern.

## Composition

Global policies can be imported by other policies using the import statement:

```rego
import data.global.v1.fairness
import data.global.v1.common.fairness as common_fairness
```

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
