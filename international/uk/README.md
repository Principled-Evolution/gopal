# UK AI Governance Policies

This directory contains OPA Rego policies for the United Kingdom's approach to AI governance.

The UK has no AI Act. Rather than a single horizontal statute, it operates a principles-based, sector-led framework in which existing regulators apply five cross-sectoral principles within their own domains. Those principles are **non-statutory**: they are addressed to regulators and are not directly binding on firms. The policies here encode them as an assurance baseline you can evidence against, not as a statutory test.

One instrument in this directory *is* hard law. The automated decision-making regime in Articles 22A to 22D of the UK GDPR was substituted by section 80 of the Data (Use and Access) Act 2025 and came into force on 5 February 2026. It replaced the former Article 22 prohibition with a permission-plus-safeguards model, and it diverges materially from the EU GDPR position.

## Directory Structure

- **v1/**:
  - `safety_security_robustness.rego` - Principle 1: risks identified, assessed and managed across the lifecycle, with security testing and documented failure handling
  - `transparency_explainability.rego` - Principle 2: appropriate transparency, proportionate to the impact of the system
  - `fairness.rego` - Principle 3: unfair discrimination and effects on legal rights, tested against the nine protected characteristics in the Equality Act 2010
  - `accountability_governance.rego` - Principle 4: named accountability, oversight, and documented accountability for third-party model supply
  - `contestability_redress.rego` - Principle 5: a route to contest harmful outcomes that is available, communicated and time-bound
  - `automated_decision_making.rego` - UK GDPR Articles 22A-22D as substituted by the Data (Use and Access) Act 2025

## Where the UK diverges from the EU

Worth knowing if you already evaluate against `international/eu_ai_act/`:

- **No risk tiering by system class.** There is no UK equivalent of the EU's prohibited / high-risk / limited-risk classification. Obligations arrive through sector regulators instead.
- **Automated decisions are permitted by default.** Under Articles 22A-22D a solely automated significant decision on ordinary personal data is lawful provided the Article 22C safeguards are in place. Special category data remains restricted and additionally needs an Article 9(2) condition.
- **Fairness is anchored in the Equality Act 2010.** The nine protected characteristics are the operative list, which is not the same set a US protected-class model would test.

Financial services is the sector furthest ahead in practice. Those policies live in [`industry_specific/bfs/v1/`](../../industry_specific/bfs/v1) rather than here, because they are sector requirements rather than cross-sectoral principles.

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
