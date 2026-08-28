# EU AI Act: coverage matrix

Source: **Regulation (EU) 2024/1689** (the Artificial Intelligence Act).

Policies live under [`international/eu_ai_act/v1/`](../../international/eu_ai_act/v1).

Legend: ✅ **Implemented**: checks real input fields against the obligation. ⚠️ **Scaffold**: package exists, returns placeholder denial. 📋 **Planned**: not in repo yet.

## Title II: Prohibited AI practices (Article 5)

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 5(1)(a): Manipulative techniques | [`prohibited_practices/manipulation`](../../international/eu_ai_act/v1/prohibited_practices/manipulation.rego) | ✅ | Detects deployment of subliminal / manipulative techniques |
| Article 5(1)(a): Emotion recognition (workplace/edu) | [`prohibited_practices/emotion_recognition`](../../international/eu_ai_act/v1/prohibited_practices/emotion_recognition.rego) | ✅ | Detects emotion-recognition systems in workplace/educational contexts |
| Article 5(1)(b): Vulnerability exploitation | [`prohibited_practices/vulnerability_exploitation`](../../international/eu_ai_act/v1/prohibited_practices/vulnerability_exploitation.rego) | ✅ | Article 5(1)(b) as a cumulative test: a vulnerability from age, disability or social/economic situation, plus behavioural distortion, plus significant harm |
| Article 5(1)(c): Social scoring | [`prohibited_practices/social_scoring`](../../international/eu_ai_act/v1/prohibited_practices/social_scoring.rego) | ✅ | Detects social-scoring systems leading to detrimental treatment |
| Article 5(1)(d): Criminal-offense profiling | [`prohibited_practices/criminal_profiling`](../../international/eu_ai_act/v1/prohibited_practices/criminal_profiling.rego) | ✅ | Prohibits prediction based solely on profiling; the Article 5(1)(d) carve-out requires both a supported human assessment and grounding in objective verifiable facts |
| Article 5(1)(e): Untargeted facial-recognition scraping | [`prohibited_practices/facial_recognition_scraping`](../../international/eu_ai_act/v1/prohibited_practices/facial_recognition_scraping.rego) | ✅ | Turns on untargeted collection from the internet or CCTV, not on facial recognition as such |
| Article 5(1)(b)+(g): Biometric categorization | [`prohibited_practices/biometric_categorization`](../../international/eu_ai_act/v1/prohibited_practices/biometric_categorization.rego) | ✅ | Six sensitive attributes from Article 5(1)(g); exempts dataset labelling and law enforcement categorisation |
| Article 5(1)(h): Real-time remote biometric identification | [`prohibited_practices/biometric_identification`](../../international/eu_ai_act/v1/prohibited_practices/biometric_identification.rego) | ✅ | Closed list of Article 5(1)(h) objectives, and Article 5(3) prior authorisation required on top of a permitted objective |

## Title III: High-risk AI systems (Articles 6 – 27)

### Chapter 2: Requirements for high-risk AI systems

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 9, Risk management system | [`risk_management/risk_management`](../../international/eu_ai_act/v1/risk_management/risk_management.rego) | ✅ | Checks documented risk-management process & residual risk acceptance |
| Article 10, Data and data governance | [`data_governance/data_quality`](../../international/eu_ai_act/v1/data_governance/data_quality.rego) | ✅ | Article 10(3) criteria are cumulative; Article 10(4) requires the deployment setting to be considered |
| Article 10, Training data | [`data_governance/training_data`](../../international/eu_ai_act/v1/data_governance/training_data.rego) | ✅ | Seven Article 10(2) practices; Article 10(5) special-category use conditional on safeguards |
| Article 11, Technical documentation | [`documentation/technical_documentation`](../../international/eu_ai_act/v1/documentation/technical_documentation.rego) | ✅ | Checks `documentation.technical_documentation.completeness` |
| Article 12, Record-keeping (logging) | [`documentation/record_keeping`](../../international/eu_ai_act/v1/documentation/record_keeping.rego) | ✅ | Six-month floor from Articles 19 and 26(6); a longer sectoral period raises it, a shorter one cannot lower it |
| Article 12, Automated logs | [`documentation/automated_logs`](../../international/eu_ai_act/v1/documentation/automated_logs.rego) | ✅ | Article 12(1)-(2) baseline, plus the four Article 12(3) fields for Annex III 1(a) biometric systems |
| Article 13, Transparency to deployers | [`transparency/transparency`](../../international/eu_ai_act/v1/transparency/transparency.rego) | ⚠️ | Scores documentation completeness and a toxicity threshold. Article 13 requires instructions for use containing specified content; a completeness score is a proxy for that, not a test of it |
| Article 14, Human oversight | [`human_oversight/human_oversight`](../../international/eu_ai_act/v1/human_oversight/human_oversight.rego) | ✅ | Article 14(4)(a)-(e) as four separate controls: oversight designed in, limits understood, automation bias, ability to disregard and to halt |
| Article 15, Accuracy, robustness, cybersecurity | [`technical_robustness/robustness`](../../international/eu_ai_act/v1/technical_robustness/robustness.rego) | ✅ | Accuracy declared in the instructions for use, feedback loops where the system keeps learning, and AI-specific cybersecurity attacks |
| Article 15, Fairness obligations | [`eu_fairness/eu_fairness`](../../international/eu_ai_act/v1/eu_fairness/eu_fairness.rego) | ✅ | Checks bias-metric thresholds and protected-class coverage |

### Chapter 3: Obligations of providers, deployers, importers, distributors

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 16 and 17, provider obligations | [`obligations/provider_obligations`](../../international/eu_ai_act/v1/obligations/provider_obligations.rego) | ✅ | Ten Article 16 limbs tested separately, naming each one outstanding |
| Article 23, Importer obligations | [`obligations/importer_obligations`](../../international/eu_ai_act/v1/obligations/importer_obligations.rego) | ✅ | Article 23 pre-market verifications plus the ten-year retention duty |
| Article 24, Distributor obligations | [`obligations/distributor_obligations`](../../international/eu_ai_act/v1/obligations/distributor_obligations.rego) | ✅ | Article 24 verifications plus the continuing Article 24(4) corrective duty |
| Article 26, Deployer obligations | [`obligations/deployer_obligations`](../../international/eu_ai_act/v1/obligations/deployer_obligations.rego) | ✅ | Article 26, with 26(7) workplace and 26(11) affected-persons duties conditional, and 26(4) scoped to input data the deployer controls |

### Chapter 5: Conformity assessment and CE marking

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 43, Conformity assessment | [`compliance/conformity_assessment`](../../international/eu_ai_act/v1/compliance/conformity_assessment.rego) | ✅ | Article 43 route selection: internal control for Annex III 1 only where harmonised standards were applied |
| Article 47, EU declaration of conformity | [`compliance/declaration_conformity`](../../international/eu_ai_act/v1/compliance/declaration_conformity.rego) | ✅ | Article 47 requires machine readability, Annex V content, ten-year retention and translation |
| Article 48, CE marking | [`compliance/ce_marking`](../../international/eu_ai_act/v1/compliance/ce_marking.rego) | ✅ | Article 48(2) digital marking and Article 48(4) notified body number, both conditional |
| Article 49, Registration in EU database | [`compliance/registration`](../../international/eu_ai_act/v1/compliance/registration.rego) | ✅ | Article 49(1) registration before market, and the Article 49(2) duty to register an Article 6(3) non-high-risk assessment |

## Title V: General-purpose AI models (Articles 51 – 56)

| Obligation | GOPAL policy | Status | Notes |
|---|---|---|---|
| Article 53, GPAI technical documentation | [`gpai/technical_documentation`](../../international/eu_ai_act/v1/gpai/technical_documentation.rego) | ✅ | Article 53(1)(a) with the Article 53(2) open-source exemption, which systemic risk removes |
| Article 53, Downstream transparency | [`gpai/downstream_transparency`](../../international/eu_ai_act/v1/gpai/downstream_transparency.rego) | ✅ | Article 53(1)(b)-(d); the open-source exemption reaches the downstream duty only |
| Article 51, Systemic-risk classification | [`gpai/systemic_risk_classification`](../../international/eu_ai_act/v1/gpai/systemic_risk_classification.rego) | ✅ | Article 51(2) 10^25 FLOP presumption, Article 52(1) notification, and the four Article 55 obligations |

## Not yet covered (📋 Planned)

| Obligation | Why it's open | Help wanted |
|---|---|---|
| Article 6, High-risk classification rules | Needs a structured input schema mapping Annex I/III to system attributes | Yes |
| Article 27, Fundamental-rights impact assessment | Needs FRIA template + checklist input | Yes |
| Article 50, Transparency to natural persons (deepfakes etc.) | Needs use-case taxonomy and disclosure-evidence input | Yes |
| Article 55, Obligations for GPAI with systemic risk | Needs systemic-risk evaluation results input | Yes |
| Article 72, Post-market monitoring | Needs post-deployment metrics input | Yes |
| Annex IV, Technical documentation contents | Currently aggregated into `technical_documentation`; could be split per-line | Maybe |

## How to help

1. **Write a test for a case that has none.** Every policy now has a sibling `*_test.rego` with an empty-input assertion, and [`scripts/check-test-coverage.sh`](../../scripts/check-test-coverage.sh) fails CI if one goes missing. What is still thin is coverage of *cases*: a policy with one test proving it denies an empty input is verified against the fail-open class and nothing else. Adding a case needs no new Rego logic. See [`docs/tutorials/add-your-first-policy.md`](../tutorials/add-your-first-policy.md).
2. **Open a 📋 Planned row.** Comment on the relevant issue (or open one) with your interpretation of the obligation and a proposed input schema before sending a PR.
3. **Disagree with our coverage call?** Open an issue. We'd rather have the dispute in public than ship rules that misread the regulation.

> ⚠️ Reminder: GOPAL is not legal advice. The matrix above is GOPAL's *engineering* interpretation of where each obligation maps. Use it as a starting point for your own compliance review, not a substitute for one.
