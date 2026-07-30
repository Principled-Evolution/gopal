# International Policies

This directory contains policies for named regulatory frameworks that cross a single jurisdiction's borders or apply nationally.

## Directory Structure

- **eu_ai_act/**: EU AI Act (Regulation 2024/1689)
  - **v1/**: 29 policies across `compliance/`, `data_governance/`, `documentation/`, `eu_fairness/`, `gpai/`, `human_oversight/`, `obligations/`, `prohibited_practices/`, `risk_management/`, and `technical_robustness/`

- **nist/**: NIST AI Risk Management Framework
  - **v1/**: 5 policies — `govern/`, `manage/`, `map/`, `measure/`, and `ai_600_1/` (the GenAI-specific companion profile)

- **india/**: India
  - **v1/**: `digital_india_policy/digital_india_policy.rego`

- **brazil/**: Brazil
  - **v1/**: `ai_governance/ai_governance.rego` (AI Governance Bill)

36 policies total across 4 frameworks.

## Usage

International policies encode requirements from a specific named regulation. Apply the one matching the jurisdiction your AI system operates in or serves users from; these are typically combined with `global/` cross-cutting policies and any relevant `industry_specific/` vertical.

## Adding New Policies

When adding new international policies:
1. Place them in the appropriate framework and version directory (e.g., `eu_ai_act/v1/<obligation_area>/`)
2. Follow the naming convention: `<policy_area>.rego` (+ sibling `<policy_area>_test.rego`)
3. Use the package name `international.<framework>.v1.<policy_area>`
4. Include a `# METADATA` block citing the specific article, section, or control the policy encodes

Adding an entirely new framework (a jurisdiction not listed above)? See [`skills/add-framework/SKILL.md`](../skills/add-framework/SKILL.md) for the scaffold, and update the count in this file, `docs/coverage/`, and the top-level README once it lands.

## Composition

International policies can import global policies to extend them with framework-specific requirements:

```rego
import data.global.v1.fairness
```

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
