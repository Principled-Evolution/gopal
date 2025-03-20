# Operational Policies

This directory contains policies focused on the operational aspects of AI systems, including AIOps, cost management, and corporate requirements.

## Directory Structure

- **aiops/**: AI Operations policies
  - **v1/**: Version 1 implementation
    - `scalability.rego`: Scalability requirements for AI systems
    - `performance.rego`: Performance requirements for AI systems

- **cost/**: Cost management policies
  - **v1/**: Version 1 implementation
    - `resource_efficiency.rego`: Resource efficiency requirements
    - `budget_compliance.rego`: Budget compliance requirements

- **corporate/**: Corporate internal policies
  - **v1/**: Version 1 implementation
    - `infosec.rego`: Information security requirements
    - `governance.rego`: AI governance requirements

## Usage

Operational policies address the practical aspects of deploying and maintaining AI systems at scale within organizations. These policies focus on efficiency, cost, security, and governance concerns rather than regulatory compliance.

## Adding New Policies

When adding new operational policies:
1. Place them in the appropriate category and version directory (e.g., aiops/v1/)
2. Follow the naming convention: `<policy_area>.rego`
3. Use the package name `operational.<category>.<version>.<policy_area>`
4. Include comprehensive metadata and documentation with clear operational metrics and thresholds

## Composition

Operational policies can be combined with other policy types to provide a comprehensive evaluation:

```rego
import data.global.v1.accountability
import data.operational.aiops.v1.performance
``` 