# AICertify OPA Policies

This directory contains the Open Policy Agent (OPA) policies used by AICertify to evaluate AI system compliance across various regulatory frameworks, industry standards, and operational requirements.

## Directory Structure

```
opa_policies/
├── global/               # Global policies applicable across all domains
│   ├── v1/               # Version 1 of global policies
│   └── library/          # Reusable policy components
├── international/        # International regulatory frameworks
│   ├── eu_ai_act/        # European Union AI Act
│   ├── india/            # Indian AI regulatory frameworks
│   └── nist/             # NIST AI standards
├── industry_specific/    # Industry-specific requirements
│   ├── bfs/              # Banking & Financial Services
│   ├── healthcare/       # Healthcare industry
│   └── automotive/       # Automotive industry
└── operational/          # Operational policies
    ├── aiops/            # AI Operations policies
    ├── cost/             # Cost management policies
    └── corporate/        # Corporate internal policies
```

## Policy Organization

Policies are organized in a modular structure to allow for clear separation of concerns and flexible composition:

1. **Global Policies**: Baseline requirements applicable to all AI systems
2. **International Policies**: Requirements from specific regulatory frameworks
3. **Industry-Specific Policies**: Requirements specific to industry verticals
4. **Operational Policies**: Requirements related to operational aspects

## Versioning

Each policy category uses versioned directories (e.g., `v1/`) to support evolution while maintaining backward compatibility. When referencing policies:

- Use specific versions when policy stability is required
- Use the latest version when up-to-date compliance is more important

## Policy Composition

Policies can be composed by importing rules from other policies:

```rego
import data.global.v1.fairness
import data.international.eu_ai_act.v1.transparency
```

## Using the PolicyLoader

The `PolicyLoader` class in `aicertify.opa_core.policy_loader` provides programmatic access to policies with support for versioning and composition.

### Loading Policies

```python
from aicertify.opa_core.policy_loader import PolicyLoader

# Initialize the loader
loader = PolicyLoader()

# Get all policies in a category (using latest version)
global_policies = loader.get_policies("global")

# Get policies in a specific category and subcategory (using latest version)
eu_policies = loader.get_policies("international", "eu_ai_act")

# Get policies with a specific version
eu_v1_policies = loader.get_policies("international", "eu_ai_act", "v1")
```

### Policy Composition

The PolicyLoader can automatically resolve policy dependencies based on imports:

```python
# Get a policy
eu_transparency_policy = loader.get_policies("international", "eu_ai_act")[0]

# Resolve its dependencies
all_policies = loader.resolve_policy_dependencies([eu_transparency_policy])
```

### Evaluating Policies

Use the `OpaEvaluator` to evaluate policies against input data:

```python
from aicertify.opa_core.evaluator import OpaEvaluator

# Initialize the evaluator
evaluator = OpaEvaluator()

# Evaluate a specific policy
result = evaluator.evaluate_policy(policy_path, input_data)

# Evaluate all policies in a category
results = evaluator.evaluate_policies_by_category("international", input_data, "eu_ai_act")
```

## Policy Loading

The AICertify framework loads policies based on the requested policy category. The policy loader will:

1. Resolve the correct policy path based on the requested category and subcategory
2. Automatically select the latest version if not specified
3. Load all policies within that category
4. Resolve policy dependencies for composition
5. Apply them to the evaluation input
6. Return comprehensive compliance results

## Adding New Policies

See the README in each policy category for specific instructions on adding new policies to that category.

## Policy Format

All policies should follow the standard format:

```rego
package <category>.<subcategory>.<version>.<policy_area>

import future.keywords

# METADATA
# Title: Policy Title
# Description: Policy Description
# Version: 1.0.0
# Category: Category Name
# References:
#  - Reference 1: URL
#  - Reference 2: URL

# Default allow/deny
default allow := false

# Rules for allowing
allow if {
    # Logic for compliance
}

# Compliance report
compliance_report := {
    "policy": "Policy Name",
    "version": "1.0.0",
    "overall_result": allow,
    "details": {
        # Detailed compliance information
    },
    "recommendations": [
        # Recommendations for improving compliance
    ]
}
``` 