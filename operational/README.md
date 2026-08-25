# Operational Policies

This directory contains policies focused on the operational aspects of running AI systems, rather than regulatory compliance.

## Directory Structure

- **aiops/**: AI Operations
  - **v1/**: `scalability/scalability.rego`

- **cost/**: Cost management
  - **v1/**: `resource_efficiency/resource_efficiency.rego`

- **corporate/**: Corporate internal policies
  - **v1/**: `governance/governance.rego`, `infosec/infosec.rego`

4 policies total across 3 categories. All four are implemented and tested; each names the operational controls it failed rather than returning a bare denial.

## Usage

Operational policies address the practical aspects of deploying and maintaining AI systems at scale within organizations: efficiency, cost, security, and internal governance concerns, rather than external regulatory compliance.

## Adding New Policies

When adding new operational policies:
1. Place them in the appropriate category and version directory (e.g., `aiops/v1/<policy_area>/`)
2. Follow the naming convention: `<policy_area>.rego` (+ sibling `<policy_area>_test.rego`)
3. Use the package name `operational.<category>.v1.<policy_area>`
4. Include a `# METADATA` block with clear operational metrics and thresholds

## Composition

Operational policies can be combined with other policy types to provide a comprehensive evaluation:

```rego
import data.global.v1.accountability
import data.operational.aiops.v1.scalability
```

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
