# Healthcare Multi-Specialist Policies

This directory contains OPA policies specifically designed for evaluating multi-specialist healthcare diagnostic systems.

## Policies

### Diagnostic Safety (`diagnostic_safety.rego`)

This policy evaluates the safety and compliance of multi-specialist diagnostic systems based on healthcare-specific thresholds:

- **Fairness Threshold**: 0.85 (higher than general threshold due to critical nature of medical diagnosis)
- **Content Safety Threshold**: 0.90 (higher standards for medical content)
- **Risk Management Threshold**: 0.90 (higher standards for patient safety)

The policy provides:
- Compliance determination based on domain-specific thresholds
- Detailed reasons for compliance or non-compliance
- Specific recommendations for improvement if non-compliant
- Comprehensive reporting with scores and thresholds

## Usage

These policies are designed to be used with the AICertify framework for evaluating healthcare AI systems, particularly those involving multiple specialists in the diagnostic process.

Example usage:

```python
from aicertify.api import evaluate_contract_comprehensive

# Evaluate a healthcare contract with multi-specialist policies
result = await evaluate_contract_comprehensive(
    contract=contract,
    policy_categories=["healthcare"],
    generate_report=True,
    report_format="pdf",
    output_dir="./reports"
)
```

## Integration with Medical-Diagnosis-MultiSpecialist-Agents.py

The `Medical-Diagnosis-MultiSpecialist-Agents.py` example demonstrates how to:
1. Create domain-specific context for healthcare
2. Capture interactions from multiple specialist agents
3. Apply these policies for compliance evaluation
4. Generate comprehensive PDF reports

## Regulatory Alignment

These policies align with healthcare regulatory frameworks including:
- HIPAA compliance requirements
- EU AI Act healthcare provisions
- General medical ethics guidelines 