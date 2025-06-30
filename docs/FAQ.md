# Gopal - Frequently Asked Questions

## 1. What is Gopal and how does it work?

**Q: What is Gopal and what problem does it solve?**

A: Gopal is a collection of Open Policy Agent (OPA) policies designed for evaluating AI systems against regulatory requirements, compliance standards, and operational criteria. It serves as the policy engine for [AICertify](https://github.com/mantric/aicertify) but can also be used independently.

Gopal solves the challenge of systematically evaluating AI systems for compliance across multiple frameworks simultaneously. Instead of manually checking each requirement, Gopal provides automated policy evaluation using OPA's Rego language.

**Q: How does Gopal work with OPA?**

A: Gopal policies are written in Rego (OPA's policy language) and follow a standardized structure:

```rego
package global.v1.fairness

# Default deny
default allow := false

# Allow if conditions are met
allow if {
    input.metrics.toxicity.score < input.params.toxicity_threshold
    # Additional conditions...
}
```

Each policy evaluates input data (AI system metrics) against defined thresholds and returns compliance decisions with detailed reports.

**Q: What types of policies does Gopal include?**

A: Gopal organizes policies into five main categories:

- **Global Policies**: Baseline requirements applicable to all AI systems (fairness, toxicity, transparency)
- **International Policies**: Specific regulatory frameworks (EU AI Act, NIST, India regulations)
- **Industry-Specific Policies**: Requirements for specific sectors (healthcare, automotive, banking)
- **Operational Policies**: Deployment and maintenance requirements (AIOps, cost management, corporate governance)
- **Custom Policies**: User-defined policy categories for specific organizational needs

## 2. How do I write custom policies?

**Q: How do I create a custom policy for my organization?**

A: Follow these steps to create custom policies:

1. **Create the directory structure:**
```bash
mkdir -p custom/my_category/v1/policy_area
```

2. **Write the policy file** (`custom/my_category/v1/policy_area/my_policy.rego`):
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

# Default deny
default allow := false

# Rules for allowing
allow if {
    input.evaluation.fairness_score > input.params.threshold
    input.evaluation.toxicity_score < 0.2
}

# Generate compliance report
report_output := reporting.compose_report("My Custom Policy", allow, {
    "fairness_score": {
        "name": "Fairness Score",
        "value": input.evaluation.fairness_score,
        "control_passed": input.evaluation.fairness_score > input.params.threshold
    },
    "toxicity_score": {
        "name": "Toxicity Score", 
        "value": input.evaluation.toxicity_score,
        "control_passed": input.evaluation.toxicity_score < 0.2
    }
})
```

3. **Create tests** (`custom/my_category/v1/policy_area/my_policy_test.rego`):
```rego
package custom.my_category.v1.policy_area_test

import data.custom.my_category.v1.policy_area

test_allow_when_compliant {
    allow with input as {
        "evaluation": {
            "fairness_score": 0.9,
            "toxicity_score": 0.1
        },
        "params": {"threshold": 0.8}
    }
}
```

**Q: What input format should my policies expect?**

A: Policies should expect input in this standardized format:

```json
{
    "evaluation": {
        "fairness_score": 0.85,
        "toxicity_score": 0.05
    },
    "metrics": {
        "toxicity": {"score": 0.05},
        "stereotype": {"metrics": {"Stereotype Association": 0.03}}
    },
    "summary": {
        "stereotype_values": {
            "gender_bias_detected": false,
            "racial_bias_detected": false
        }
    },
    "params": {
        "toxicity_threshold": 0.1,
        "fairness_threshold": 0.7
    }
}
```

**Q: How do I use the helper functions for reporting?**

A: Import and use the reporting helper functions to generate standardized reports:

```rego
import data.helper_functions.reporting

# Generate a standardized report
report_output := reporting.compose_report("Policy Name", allow, {
    "metric_name": {
        "name": "Human Readable Name",
        "value": actual_value,
        "control_passed": boolean_result
    }
})
```

The reporting helper validates metric structure and generates timestamped reports with consistent formatting.

## 3. What's the difference between policy categories?

**Q: When should I use global vs. international vs. industry-specific policies?**

A: Choose policy categories based on your compliance requirements:

- **Global Policies**: Use for baseline AI safety requirements that apply universally (toxicity, basic fairness). These are foundational policies that most AI systems should meet.

- **International Policies**: Use when you need to comply with specific regulatory frameworks:
  - `international/eu_ai_act/` for EU AI Act compliance
  - `international/nist/` for NIST AI Risk Management Framework
  - `international/india/` for Indian AI regulations

- **Industry-Specific Policies**: Use when deploying in regulated industries:
  - `industry_specific/healthcare/` for medical AI applications
  - `industry_specific/bfs/` for banking and financial services
  - `industry_specific/automotive/` for autonomous vehicle systems

- **Operational Policies**: Use for deployment and maintenance requirements:
  - `operational/aiops/` for scalability and performance
  - `operational/cost/` for resource efficiency
  - `operational/corporate/` for internal governance

- **Custom Policies**: Use for organization-specific requirements not covered by standard categories.

**Q: Can I combine policies from different categories?**

A: Yes! Gopal is designed for policy composition. You can evaluate an AI system against multiple policy categories simultaneously:

```python
# Example: Evaluate against multiple categories
categories = [
    "global/v1",
    "international/eu_ai_act/v1", 
    "industry_specific/healthcare/v1",
    "operational/aiops/v1"
]
```

This allows comprehensive compliance checking across all relevant frameworks.

**Q: How does versioning work across categories?**

A: Each category maintains independent versioning:

- Use specific versions (e.g., `v1/`) when policy stability is critical
- Use latest versions when up-to-date compliance is more important
- Different categories can be at different versions simultaneously
- Backward compatibility is maintained within major versions

## 4. How do I integrate Gopal with my existing systems?

**Q: Can I use Gopal without AICertify?**

A: Yes! Gopal is designed to work independently with any OPA-compatible system. You can:

1. **Use OPA CLI directly:**
```bash
opa eval -d gopal/ -i input.json "data.global.v1.fairness.allow"
```

2. **Use OPA as a service:**
```bash
opa run --server gopal/
curl -X POST http://localhost:8181/v1/data/global/v1/fairness/allow \
  -H "Content-Type: application/json" \
  -d @input.json
```

3. **Integrate with your application using OPA SDKs** (available for Go, Java, Python, etc.)

**Q: How do I integrate Gopal with AICertify?**

A: When using AICertify, Gopal policies are automatically loaded and evaluated:

```python
from aicertify.api.policy import evaluate_by_policy

# Evaluate using specific policy category
result = await evaluate_by_policy(
    contract=contract,
    policy_folder="global/v1",
    custom_params={"toxicity_threshold": 0.05}
)

# Evaluate using multiple categories
result = await evaluate_by_policy(
    contract=contract,
    policy_folder=["global/v1", "international/eu_ai_act/v1"]
)
```

**Q: What data format does my system need to provide?**

A: Your system needs to provide evaluation metrics in the expected input format. The exact metrics depend on the policies you're evaluating against, but common metrics include:

- `toxicity_score`: Toxicity level (0.0-1.0, lower is better)
- `fairness_score`: Fairness assessment (0.0-1.0, higher is better)  
- `bias_detected`: Boolean flags for different types of bias
- `performance_metrics`: System performance data
- `resource_usage`: Computational resource consumption

Check the policy metadata comments for specific required metrics and parameters.

## 5. How do I test my policies?

**Q: How do I write and run tests for my policies?**

A: Create test files alongside your policies using OPA's testing framework:

1. **Create test file** (e.g., `my_policy_test.rego`):
```rego
package my.policy.package_test

import data.my.policy.package

test_allow_when_compliant {
    allow with input as {
        "evaluation": {"score": 0.9},
        "params": {"threshold": 0.8}
    }
}

test_deny_when_non_compliant {
    not allow with input as {
        "evaluation": {"score": 0.7},
        "params": {"threshold": 0.8}
    }
}
```

2. **Run tests using OPA:**
```bash
# Run all tests
opa test gopal/

# Run tests for specific directory
opa test gopal/global/v1/fairness/

# Run with verbose output
opa test -v gopal/
```

**Q: What should I test in my policies?**

A: Test these key scenarios:

- **Compliant cases**: Input that should pass the policy
- **Non-compliant cases**: Input that should fail the policy  
- **Edge cases**: Boundary conditions and missing data
- **Parameter variations**: Different threshold values
- **Report generation**: Verify compliance reports are correctly formatted

**Q: How do I validate my policy structure?**

A: Use OPA's built-in validation and the helper functions:

```bash
# Check syntax and structure
opa fmt gopal/custom/my_category/

# Validate against schema (if available)
opa test --explain=notes gopal/custom/my_category/
```

Also ensure your policies follow the standard structure with proper metadata, default deny, and standardized reporting using the helper functions.

**Q: How do I debug policy evaluation issues?**

A: Use OPA's debugging capabilities:

```bash
# Trace policy evaluation
opa eval -d gopal/ -i input.json --explain=full "data.global.v1.fairness.allow"

# Interactive debugging
opa run gopal/
> data.global.v1.fairness.allow with input as {"evaluation": {"toxicity_score": 0.15}}
```

This shows the step-by-step evaluation process and helps identify where policies might be failing unexpectedly.
