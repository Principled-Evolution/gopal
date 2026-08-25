# Banking & Financial Services Policies

- `loan_evaluation/fair_lending.rego`: checks fairness, content-safety, and risk-management scores for lending decisions, aligned with fair-lending regulations, ECOA, EU AI Act financial provisions, and CFPB guidance. See its own [README](loan_evaluation/README.md) for thresholds and an AICertify usage example.
- `model_risk/model_risk.rego`: US and Basel model risk management, covering the SR 11-7 and OCC 2011-12 pillars (identification and risk rating, governance, development and conceptual soundness, independent validation with outcomes analysis, ongoing monitoring) together with BCBS 239 data lineage. Review cadence scales with the assigned risk rating.
- `uk_ss1_23_model_risk.rego`: the UK equivalent, PRA SS1/23 across all five principles. Use this one for a UK-regulated firm and `model_risk.rego` for a US-regulated one.
- `uk_fca_consumer_duty.rego`: FCA Consumer Duty (PRIN 2A) where an AI system touches a retail customer journey, including plain-language explainability and SM&CR accountability.

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
