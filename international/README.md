# International Policies

This directory contains policies specific to international regulatory frameworks and standards for AI systems.

## Directory Structure

- **eu_ai_act/**: Policies related to the European Union AI Act
  - **v1/**: Version 1 implementation
    - `fairness.rego`: Fairness requirements under EU AI Act
    - `transparency.rego`: Transparency requirements under EU AI Act
    - `risk_management.rego`: Risk management requirements under EU AI Act

- **india/**: Policies related to Indian AI regulatory frameworks
  - **v1/**: Version 1 implementation
    - `digital_india_policy.rego`: Digital India AI policy requirements

- **nist/**: Policies related to NIST AI standards
  - **v1/**: Version 1 implementation
    - `ai_600_1.rego`: NIST AI 600-1 framework requirements

## Usage

International policies provide requirements specific to regulatory frameworks from different regions and international standards bodies. These can be applied based on the jurisdiction in which the AI system operates.

## Adding New Policies

When adding new international policies:
1. Place them in the appropriate framework and version directory (e.g., eu_ai_act/v1/)
2. Follow the naming convention: `<policy_area>.rego`
3. Use the package name `international.<framework>.<version>.<policy_area>`
4. Include comprehensive metadata and documentation including references to specific sections of the regulatory text

## Composition

International policies can import global policies to extend them with specific requirements:

```rego
import data.global.v1.fairness
``` 