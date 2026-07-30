# Banking & Financial Services Policies

- `loan_evaluation/fair_lending.rego` — checks fairness, content-safety, and risk-management scores for lending decisions, aligned with fair-lending regulations, ECOA, EU AI Act financial provisions, and CFPB guidance. See its own [README](loan_evaluation/README.md) for thresholds and an AICertify usage example.
- `model_risk/model_risk.rego` — currently a scaffold (`default allow := false` placeholder); the intended checks are model-risk, documentation, and validation scores per its `RequiredMetrics` comment, but the logic isn't implemented yet

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
