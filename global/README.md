# Global Policies

This directory contains global policies that apply across all domains and are not specific to any regulatory framework or industry.

## Directory Structure

- **v1/**: Version 1 of global policies
  - `fairness.rego`: General fairness requirements for AI systems
  - `transparency.rego`: Transparency requirements for AI systems
  - `accountability.rego`: Accountability requirements for AI systems
  
- **library/**: Reusable policy components
  - `common_rules.rego`: Common rules that can be imported by other policies
  - `utilities.rego`: Utility functions for policies

## Usage

Global policies provide a baseline set of requirements that all AI systems should meet regardless of their specific industry or regulatory domain. They can be used standalone or combined with more specific policies.

## Adding New Policies

When adding new global policies:
1. Place them in the appropriate version directory (e.g., v1/)
2. Follow the naming convention: `<policy_area>.rego`
3. Use the package name `global.<version>.<policy_area>`
4. Include comprehensive metadata and documentation

## Composition

Global policies can be imported by other policies using the import statement:

```rego
import data.global.v1.fairness
``` 