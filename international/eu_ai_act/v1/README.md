# EU AI Act Policies

Source: **Regulation (EU) 2024/1689** (the Artificial Intelligence Act): https://eur-lex.europa.eu/eli/reg/2024/1689/oj

29 policies organized by obligation area:

- `prohibited_practices/`: Article 5 banned AI practices (manipulation, social scoring, biometric categorization, etc.)
- `risk_management/`: Article 9 risk management system
- `data_governance/`: Article 10 data and data governance
- `documentation/`: Articles 11–12 technical documentation and record-keeping
- `transparency/`: Articles 13 and 52 transparency to deployers and end users
- `human_oversight/`: Article 14 human oversight
- `technical_robustness/`: Article 15 accuracy, robustness, cybersecurity
- `eu_fairness/`: fairness and bias-metric checks tied to Article 15
- `obligations/`: Chapter III obligations of providers, deployers, importers, distributors
- `compliance/`: Chapter 5 conformity assessment, CE marking, registration
- `gpai/`: Title V general-purpose AI model obligations (Articles 51–56)

**Not every policy here is fully implemented.** Several packages exist to establish a stable path but currently return a placeholder denial pending real logic. See [`docs/coverage/eu-ai-act.md`](../../../docs/coverage/eu-ai-act.md) for the exact Implemented / Scaffold / Planned status of every obligation, and [`docs/tutorials/add-your-first-policy.md`](../../../docs/tutorials/add-your-first-policy.md) if you want to turn a scaffold into a real check.

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
