# Industry-Specific Policies

This directory contains policies specific to different industry verticals and their unique AI compliance requirements.

## Directory Structure

- **bfs/**: Banking and Financial Services
  - **v1/**: Version 1 implementation
    - `model_risk.rego`: Model risk management requirements for financial AI systems
    - `customer_protection.rego`: Customer protection requirements for financial AI systems

- **healthcare/**: Healthcare industry
  - **v1/**: Version 1 implementation
    - `patient_safety.rego`: Patient safety requirements for healthcare AI systems
    - `medical_data.rego`: Medical data handling requirements

- **automotive/**: Automotive industry
  - **v1/**: Version 1 implementation
    - `vehicle_safety.rego`: Vehicle safety requirements for automotive AI systems

## Usage

Industry-specific policies address the unique requirements and risks associated with AI systems deployed in particular sectors. These should be applied in addition to global and applicable international policies to ensure comprehensive compliance.

## Adding New Policies

When adding new industry-specific policies:
1. Place them in the appropriate industry and version directory (e.g., healthcare/v1/)
2. Follow the naming convention: `<policy_area>.rego`
3. Use the package name `industry_specific.<industry>.<version>.<policy_area>`
4. Include comprehensive metadata and documentation with references to industry standards

## Composition

Industry-specific policies can import global and international policies to extend them with industry-specific requirements:

```rego
import data.global.v1.fairness
import data.international.eu_ai_act.v1.transparency
``` 