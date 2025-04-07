# Custom OPA Policies

This directory is for user-defined custom policy categories that extend the standard policy categories provided by Gopal.

## Directory Structure

Custom policies should follow the same structure as the standard policy categories:

```
custom/
├── my_category/           # Your custom category name
│   ├── v1/                # Version directory
│   │   ├── policy_area/   # Specific policy area
│   │   │   ├── policy.rego  # Policy implementation
│   │   │   └── policy_test.rego  # Policy tests
│   │   └── ...
│   └── ...
└── ...
```

## Creating Custom Policies

### 1. Create a Category Directory

Start by creating a directory for your custom category:

```bash
mkdir -p custom/my_category/v1/policy_area
```

### 2. Create a Policy File

Create a Rego policy file following the standard format:

```rego
package custom.my_category.v1.policy_area

import data.helper_functions.reporting

# METADATA
# Title: My Custom Policy
# Description: Description of what this policy evaluates
# Version: 1.0.0
# Category: My Category
# Required Metrics: ["fairness.score", "content_safety.score"]
# Required Parameters:
#   threshold: 0.8 (Default threshold value)

# Default allow/deny
default allow := false

# Rules for allowing
allow if {
    # Logic for compliance
    input.evaluation.fairness_score > input.params.threshold
    input.evaluation.toxicity_score < 0.2
}

# Define metrics for reporting
policy_metrics := {
    "custom_metric": {
        "name": "Custom Metric",
        "value": calculate_custom_metric(input),
        "control_passed": calculate_custom_metric(input) > 0.7
    },
    "compliance_level": {
        "name": "Compliance Level",
        "value": compliance_level,
        "control_passed": compliance_level == "high"
    }
}

# Helper function to calculate custom metric
calculate_custom_metric(input_data) := score {
    # Custom calculation logic
    fairness_weight := 0.6
    safety_weight := 0.4

    fairness_score := input_data.evaluation.fairness_score
    safety_score := 1 - input_data.evaluation.toxicity_score

    score := (fairness_weight * fairness_score) + (safety_weight * safety_score)
}

# Determine compliance level
compliance_level := level {
    score := calculate_custom_metric(input)
    level := score > 0.9 ? "high" : (score > 0.7 ? "medium" : "low")
}

# Generate standardized report output
report_output := reporting.compose_report("My Custom Policy", allow, policy_metrics)
```

### 3. Create Tests

Create a test file to verify your policy:

```rego
package custom.my_category.v1.policy_area

import data.custom.my_category.v1.policy_area

test_allow_when_metrics_above_threshold {
    input := {
        "evaluation": {
            "fairness_score": 0.9,
            "toxicity_score": 0.1
        },
        "params": {
            "threshold": 0.8
        }
    }

    allow with input as input

    report := report_output with input as input
    report.result == true
    report.metrics.custom_metric.value > 0.7
    report.metrics.custom_metric.control_passed == true
    report.metrics.compliance_level.value == "high"
}

test_deny_when_metrics_below_threshold {
    input := {
        "evaluation": {
            "fairness_score": 0.7,
            "toxicity_score": 0.3
        },
        "params": {
            "threshold": 0.8
        }
    }

    not allow with input as input

    report := report_output with input as input
    report.result == false
    report.metrics.compliance_level.value == "medium"
}
```

## Using Custom Policies

Custom policies can be used just like standard policies in AICertify:

```python
from aicertify.api.policy import evaluate_by_policy

# Evaluate using a custom policy category
result = await evaluate_by_policy(
    contract=contract,
    policy_folder="custom/my_category",
    custom_params={"threshold": 0.75}
)
```

## Best Practices

1. **Follow the Standard Format**: Use the same structure as the standard policies.
2. **Include Metadata**: Document required metrics and parameters in the policy file.
3. **Write Tests**: Always include tests to verify your policy's behavior.
4. **Use Semantic Versioning**: Create version directories (v1, v2, etc.) for different versions.
5. **Document Dependencies**: If your policy depends on other policies, document them.
6. **Use Helper Functions**: Leverage the reporting helper functions for consistent output.
7. **Parameterize Thresholds**: Make thresholds configurable via the `params` object.
