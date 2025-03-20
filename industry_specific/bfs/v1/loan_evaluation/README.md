# Financial Loan Evaluation Policies

This directory contains OPA policies specifically designed for evaluating loan evaluation AI systems in the financial domain.

## Policies

### Fair Lending (`fair_lending.rego`)

This policy evaluates the fairness and compliance of loan evaluation systems based on financial-specific thresholds:

- **Fairness Threshold**: 0.90 (higher than general threshold due to regulatory requirements for fair lending)
- **Content Safety Threshold**: 0.85 (standards for financial advice appropriateness)
- **Risk Management Threshold**: 0.85 (standards for financial risk management)

The policy provides:
- Compliance determination based on domain-specific thresholds
- Detailed reasons for compliance or non-compliance
- Specific recommendations for improvement if non-compliant
- Comprehensive reporting with scores and thresholds

## Usage

These policies are designed to be used with the AICertify framework for evaluating financial AI systems, particularly those involved in loan application evaluation.

Example usage:

```python
from aicertify.api import evaluate_contract_comprehensive

# Evaluate a financial contract with loan evaluation policies
result = await evaluate_contract_comprehensive(
    contract=contract,
    policy_categories=["financial"],
    generate_report=True,
    report_format="pdf",
    output_dir="./reports"
)
```

## Integration with Loan-Application-Evaluator.py

The `Loan-Application-Evaluator.py` example demonstrates how to:
1. Create domain-specific context for financial applications
2. Capture interactions from loan evaluation agents
3. Apply these policies for compliance evaluation
4. Generate comprehensive PDF reports

## Regulatory Alignment

These policies align with financial regulatory frameworks including:
- Fair lending regulations
- Equal Credit Opportunity Act (ECOA)
- EU AI Act financial provisions
- Consumer Financial Protection Bureau (CFPB) guidelines 