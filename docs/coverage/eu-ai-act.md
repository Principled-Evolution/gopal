# EU AI Act — coverage matrix

Source: **Regulation (EU) 2024/1689** (the Artificial Intelligence Act).

Policies live under [`international/eu_ai_act/v1/`](../../international/eu_ai_act/v1).

Legend: ✅ **Implemented** — checks real input fields against the obligation. ⚠️ **Scaffold** — package exists, returns placeholder denial. 📋 **Planned** — not in repo yet.

## Title II — Prohibited AI practices (Article 5)

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 5(1)(a) — Manipulative techniques | [`prohibited_practices/manipulation`](../../international/eu_ai_act/v1/prohibited_practices/manipulation.rego) | ✅ | Detects deployment of subliminal / manipulative techniques |
| Article 5(1)(a) — Emotion recognition (workplace/edu) | [`prohibited_practices/emotion_recognition`](../../international/eu_ai_act/v1/prohibited_practices/emotion_recognition.rego) | ✅ | Detects emotion-recognition systems in workplace/educational contexts |
| Article 5(1)(b) — Vulnerability exploitation | [`prohibited_practices/vulnerability_exploitation`](../../international/eu_ai_act/v1/prohibited_practices/vulnerability_exploitation.rego) | ✅ | Detects exploitation of age/disability/social vulnerabilities |
| Article 5(1)(c) — Social scoring | [`prohibited_practices/social_scoring`](../../international/eu_ai_act/v1/prohibited_practices/social_scoring.rego) | ✅ | Detects social-scoring systems leading to detrimental treatment |
| Article 5(1)(d) — Criminal-offense profiling | [`prohibited_practices/criminal_profiling`](../../international/eu_ai_act/v1/prohibited_practices/criminal_profiling.rego) | ⚠️ | Package exists; logic placeholder |
| Article 5(1)(e) — Untargeted facial-recognition scraping | [`prohibited_practices/facial_recognition_scraping`](../../international/eu_ai_act/v1/prohibited_practices/facial_recognition_scraping.rego) | ⚠️ | Package exists; logic placeholder |
| Article 5(1)(b)+(g) — Biometric categorization | [`prohibited_practices/biometric_categorization`](../../international/eu_ai_act/v1/prohibited_practices/biometric_categorization.rego) | ⚠️ | Package exists; logic placeholder |
| Article 5(1)(h) — Real-time remote biometric identification | [`prohibited_practices/biometric_identification`](../../international/eu_ai_act/v1/prohibited_practices/biometric_identification.rego) | ⚠️ | Package exists; logic placeholder |

## Title III — High-risk AI systems (Articles 6 – 27)

### Chapter 2 — Requirements for high-risk AI systems

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 9 — Risk management system | [`risk_management/risk_management`](../../international/eu_ai_act/v1/risk_management/risk_management.rego) | ✅ | Checks documented risk-management process & residual risk acceptance |
| Article 10 — Data and data governance | [`data_governance/data_quality`](../../international/eu_ai_act/v1/data_governance/data_quality.rego) | ⚠️ | Scaffold |
| Article 10 — Training data | [`data_governance/training_data`](../../international/eu_ai_act/v1/data_governance/training_data.rego) | ⚠️ | Scaffold |
| Article 11 — Technical documentation | [`documentation/technical_documentation`](../../international/eu_ai_act/v1/documentation/technical_documentation.rego) | ✅ | Checks `documentation.technical_documentation.completeness` |
| Article 12 — Record-keeping (logging) | [`documentation/record_keeping`](../../international/eu_ai_act/v1/documentation/record_keeping.rego) | ⚠️ | Scaffold |
| Article 12 — Automated logs | [`documentation/automated_logs`](../../international/eu_ai_act/v1/documentation/automated_logs.rego) | ⚠️ | Scaffold |
| Article 13 — Transparency to deployers | [`transparency/transparency`](../../international/eu_ai_act/v1/transparency/transparency.rego) | ✅ | Checks documentation completeness + toxicity threshold |
| Article 14 — Human oversight | [`human_oversight/human_oversight`](../../international/eu_ai_act/v1/human_oversight/human_oversight.rego) | ⚠️ | Scaffold |
| Article 15 — Accuracy, robustness, cybersecurity | [`technical_robustness/robustness`](../../international/eu_ai_act/v1/technical_robustness/robustness.rego) | ⚠️ | Scaffold |
| Article 15 — Fairness obligations | [`eu_fairness/eu_fairness`](../../international/eu_ai_act/v1/eu_fairness/eu_fairness.rego) | ✅ | Checks bias-metric thresholds and protected-class coverage |

### Chapter 3 — Obligations of providers, deployers, importers, distributors

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 16 + 17 — Provider obligations | [`obligations/provider_obligations`](../../international/eu_ai_act/v1/obligations/provider_obligations.rego) | ⚠️ | Scaffold |
| Article 23 — Importer obligations | [`obligations/importer_obligations`](../../international/eu_ai_act/v1/obligations/importer_obligations.rego) | ⚠️ | Scaffold |
| Article 24 — Distributor obligations | [`obligations/distributor_obligations`](../../international/eu_ai_act/v1/obligations/distributor_obligations.rego) | ⚠️ | Scaffold |
| Article 26 — Deployer obligations | [`obligations/deployer_obligations`](../../international/eu_ai_act/v1/obligations/deployer_obligations.rego) | ⚠️ | Scaffold |

### Chapter 5 — Conformity assessment and CE marking

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 43 — Conformity assessment | [`compliance/conformity_assessment`](../../international/eu_ai_act/v1/compliance/conformity_assessment.rego) | ⚠️ | Scaffold |
| Article 47 — EU declaration of conformity | [`compliance/declaration_conformity`](../../international/eu_ai_act/v1/compliance/declaration_conformity.rego) | ⚠️ | Scaffold |
| Article 48 — CE marking | [`compliance/ce_marking`](../../international/eu_ai_act/v1/compliance/ce_marking.rego) | ⚠️ | Scaffold |
| Article 49 — Registration in EU database | [`compliance/registration`](../../international/eu_ai_act/v1/compliance/registration.rego) | ⚠️ | Scaffold |

## Title V — General-purpose AI models (Articles 51 – 56)

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 53 — GPAI technical documentation | [`gpai/technical_documentation`](../../international/eu_ai_act/v1/gpai/technical_documentation.rego) | ⚠️ | Scaffold |
| Article 53 — Downstream transparency | [`gpai/downstream_transparency`](../../international/eu_ai_act/v1/gpai/downstream_transparency.rego) | ⚠️ | Scaffold |
| Article 51 — Systemic-risk classification | [`gpai/systemic_risk_classification`](../../international/eu_ai_act/v1/gpai/systemic_risk_classification.rego) | ⚠️ | Scaffold |
| Article 52 — Transparency obligations for certain systems | [`transparency/transparency`](../../international/eu_ai_act/v1/transparency/transparency.rego) | ✅ | Shared with Article 13 |

## Not yet covered (📋 Planned)

| Obligation | Why it's open | Help wanted |
|---|---|---|
| Article 6 — High-risk classification rules | Needs a structured input schema mapping Annex I/III to system attributes | Yes |
| Article 27 — Fundamental-rights impact assessment | Needs FRIA template + checklist input | Yes |
| Article 50 — Transparency to natural persons (deepfakes etc.) | Needs use-case taxonomy and disclosure-evidence input | Yes |
| Article 55 — Obligations for GPAI with systemic risk | Needs systemic-risk evaluation results input | Yes |
| Article 72 — Post-market monitoring | Needs post-deployment metrics input | Yes |
| Annex IV — Technical documentation contents | Currently aggregated into `technical_documentation`; could be split per-line | Maybe |

## How to help

1. **Promote a scaffold to implementation.** Pick a row marked ⚠️ Scaffold, read the corresponding article, and replace the placeholder logic with concrete field checks. See [`docs/tutorials/add-your-first-policy.md`](../tutorials/add-your-first-policy.md).
2. **Open a 📋 Planned row.** Comment on the relevant issue (or open one) with your interpretation of the obligation and a proposed input schema before sending a PR.
3. **Disagree with our coverage call?** Open an issue. We'd rather have the dispute in public than ship rules that misread the regulation.

> ⚠️ Reminder: GOPAL is not legal advice. The matrix above is GOPAL's *engineering* interpretation of where each obligation maps. Use it as a starting point for your own compliance review, not a substitute for one.
