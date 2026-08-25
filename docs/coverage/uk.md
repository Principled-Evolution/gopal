# UK AI governance: coverage matrix

Two different kinds of instrument sit behind this matrix, and the distinction matters more here than in any other framework GOPAL covers.

The **five cross-sectoral principles** come from [A pro-innovation approach to AI regulation](https://www.gov.uk/government/publications/ai-regulation-a-pro-innovation-approach/white-paper) (CP 815, March 2023) and the [initial guidance for regulators](https://www.gov.uk/government/publications/implementing-the-uks-ai-regulatory-principles-initial-guidance-for-regulators/implementing-the-uks-ai-regulatory-principles-initial-guidance-for-regulators) (DSIT, February 2024). They are **non-statutory**. They are addressed to regulators, not imposed directly on firms, and there is no UK AI Act behind them. Treat a passing evaluation as assurance evidence, not as a statutory compliance determination.

The **automated decision-making regime** is hard law. Articles 22A to 22D were substituted into the UK GDPR by section 80 of the [Data (Use and Access) Act 2025](https://www.legislation.gov.uk/ukpga/2025/18/section/80/enacted) and came into force on 5 February 2026 (SI 2026/82).

Policies live under [`international/uk/v1/`](../../international/uk/v1).

Legend: ✅ **Implemented**, meaning the rule checks real input fields against the obligation. ⚠️ **Scaffold**, meaning the package exists but returns a placeholder denial. 📋 **Planned**, meaning it is not in the repo yet.

## The five cross-sectoral principles

| Principle | GOPAL policy | Status | What the rule checks |
|---|---|---|---|
| 1. Safety, security and robustness | [`safety_security_robustness`](../../international/uk/v1/safety_security_robustness.rego) | ✅ | Risk assessment completed **and** lifecycle monitoring in place (a one-off assessment fails), security testing completed, performance thresholds and failure handling documented |
| 2. Appropriate transparency and explainability | [`transparency_explainability`](../../international/uk/v1/transparency_explainability.rego) | ✅ | AI use disclosed, purpose documented, decision rationale available; a `high` impact system must additionally document its explainability method |
| 3. Fairness | [`fairness`](../../international/uk/v1/fairness.rego) | ✅ | Bias assessment and legal-rights review completed, all nine Equality Act 2010 characteristics tested, max outcome disparity ≤ 0.1 |
| 4. Accountability and governance | [`accountability_governance`](../../international/uk/v1/accountability_governance.rego) | ✅ | Named accountable person, defined lifecycle roles, oversight body; third-party model supply requires documented accountability |
| 5. Contestability and redress | [`contestability_redress`](../../international/uk/v1/contestability_redress.rego) | ✅ | Where the system affects individuals or carries material harm potential: a contest route that is available, communicated, human-reviewed and time-bound |

### Proportionality is encoded, not assumed

Two principles are explicitly qualified in the source text, and the policies reflect that rather than flattening it:

- Principle 2 says **appropriate** transparency. `transparency_explainability` requires a documented explainability method only where `input.system.impact_level == "high"`.
- Principle 5 says **where appropriate**. `contestability_redress` engages only where `input.system.affects_individuals` or `input.system.material_harm_potential` is true.

In both cases the scope fact has to be asserted. An absent field denies rather than being read as "the principle does not apply".

## UK GDPR Articles 22A–22D

| Article | GOPAL policy | Status | What the rule checks |
|---|---|---|---|
| 22A, significant decision and based solely on automated processing | [`automated_decision_making`](../../international/uk/v1/automated_decision_making.rego) | ✅ | `input.decision.significant` and `input.decision.meaningful_human_involvement` must both be asserted; the regime engages only when significant **and** no meaningful human involvement |
| 22B, significant decisions involving special category data | same policy | ✅ | Where special category data is relied on, an Article 9(2) condition is required in addition to the safeguards |
| 22C, safeguards | same policy | ✅ | All four: information about the decision, ability to make representations, ability to obtain human intervention, ability to contest the decision |
| 22D, Secretary of State power on meaningful human involvement | n/a | 📋 | The power is unexercised to date. Nothing to encode until regulations are made |

The report names precisely which of the four Article 22C safeguards are missing, in `report.metrics.article_22c_safeguards.value`.

### Where this diverges from the EU

If you already evaluate against [`eu-ai-act.md`](eu-ai-act.md), the differences worth knowing:

| | EU | UK |
|---|---|---|
| Risk classification by system class | Prohibited / high-risk / limited-risk tiers | None. Obligations arrive through sector regulators |
| Solely automated significant decisions | Prohibited under GDPR Art 22 absent an exception | **Permitted** for ordinary personal data with Art 22C safeguards |
| Special category data | Narrow Art 22(4) exceptions | Restricted under Art 22B; needs an Art 9(2) condition plus safeguards |
| Fairness anchor | Union non-discrimination law | Equality Act 2010, nine protected characteristics |
| Instrument | One horizontal regulation | Non-statutory principles plus sectoral rules plus the DUAA amendments |

## UK financial services

These are sector requirements rather than cross-sectoral principles, so they live in the banking vertical rather than under `international/uk/`.

| Instrument | GOPAL policy | Status | What the rule checks |
|---|---|---|---|
| PRA SS1/23, model risk management (effective 17 May 2024) | [`uk_ss1_23_model_risk`](../../industry_specific/bfs/v1/uk_ss1_23_model_risk.rego) | ✅ | All five SS1/23 principles; validation recency proportionate to risk tier (365 days high tier, 1095 otherwise); vendor models in scope |
| FCA Consumer Duty (PRIN 2A) | [`uk_fca_consumer_duty`](../../industry_specific/bfs/v1/uk_fca_consumer_duty.rego) | ✅ | Three cross-cutting obligations, four retail outcomes, plain-language explainability for customer-facing AI, SM&CR named senior manager |

Neither the FCA nor the PRA has introduced AI-specific rules. Both supervise AI through these existing frameworks, which is why the policies test the existing obligations rather than a separate AI regime.

## Not yet covered

- 📋 **ICO statutory code of practice on AI and automated decision-making**, required under the Data Protection Act 2018 (Code of Practice on Artificial Intelligence and Automated Decision-Making) Regulations 2026; final guidance expected during 2026
- 📋 **DSIT AI Growth Lab sandbox conditions**, consultation closed January 2026 with no operative rules yet
- 📋 **Sector regulator AI strategies** beyond financial services (Ofcom, CMA, MHRA)
