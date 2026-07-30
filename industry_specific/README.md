# Industry-Specific Policies

This directory contains policies specific to particular industry verticals and their unique AI compliance requirements.

## Directory Structure

- **education/**: Education technology
  - **v1/**: 12 policies across `academic_integrity/`, `assessment_and_evaluation/`, `fairness_and_equity/`, `safe_learning_environment/`, and `student_data_privacy/` (FERPA, COPPA)

- **healthcare/**: Healthcare
  - **v1/**: `diagnostic_safety/diagnostic_safety.rego`, `patient_safety/patient_safety.rego`

- **bfs/**: Banking and Financial Services
  - **v1/**: `loan_evaluation/fair_lending.rego`, `model_risk/model_risk.rego`

- **automotive/**: Automotive
  - **v1/**: `vehicle_safety/vehicle_safety.rego`

17 policies total across 4 verticals.

## Usage

Industry-specific policies address the unique requirements and risks associated with AI systems deployed in a particular sector. Apply them in addition to `global/` and any applicable `international/` policies for comprehensive coverage.

## Adding New Policies

When adding new industry-specific policies:
1. Place them in the appropriate industry and version directory (e.g., `healthcare/v1/<policy_area>/`)
2. Follow the naming convention: `<policy_area>.rego` (+ sibling `<policy_area>_test.rego`)
3. Use the package name `industry_specific.<industry>.v1.<policy_area>`
4. Include a `# METADATA` block referencing the specific standard or regulation it encodes

Adding a brand-new vertical (not one of the four above)? See [`skills/add-framework/SKILL.md`](../skills/add-framework/SKILL.md) for the scaffold, and update the count in this file and the top-level README once it lands.

## Composition

Industry-specific policies can import global and international policies to extend them with industry-specific requirements:

```rego
import data.global.v1.fairness
import data.international.eu_ai_act.v1.eu_fairness
```

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
