# NIST AI RMF: coverage matrix

Source: [**NIST AI Risk Management Framework (AI RMF 1.0)**](https://www.nist.gov/itl/ai-risk-management-framework) and the [Generative AI Profile (NIST AI 600-1)](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf).

Policies live under [`international/nist/v1/`](../../international/nist/v1).

Legend: ✅ **Implemented**: checks real input fields against the obligation. ⚠️ **Scaffold**: package exists, returns placeholder denial. 📋 **Planned**: not in repo yet.

## Core functions

The AI RMF organizes AI risk management into four functions: **Govern, Map, Measure, Manage**. GOPAL ships one package per function plus an orchestrator (`ai_600_1`).

The orchestrator delegates to the four function packages rather than checking top-level keys itself. Until that changed it tested only that each section was present, which meant a system with no governance data recorded at all evaluated to allow. Because it now depends on each function's own `allow`, the shallowness of the Map, Measure and Manage checks below propagates to the orchestrator's verdict.

| Function | GOPAL package | Status | Notes |
|---|---|---|---|
| Govern | [`govern`](../../international/nist/v1/govern/governance.rego) | ✅ | Composes Accountability + Transparency + Fairness sub-checks against `input.governance`, `input.transparency`, `input.fairness` |
| Map | [`map`](../../international/nist/v1/map/map.rego) | ⚠️ | Structure in place; sub-checks return placeholder fields |
| Measure | [`measure`](../../international/nist/v1/measure/measure.rego) | ⚠️ | Structure in place; sub-checks return placeholder fields |
| Manage | [`manage`](../../international/nist/v1/manage/manage.rego) | ⚠️ | Structure in place; sub-checks return placeholder fields |
| Orchestrator (all four) | [`ai_600_1`](../../international/nist/v1/ai_600_1/ai_600_1.rego) | ✅ | Single entry point. Delegates to `govern.allow`, `map.allow`, `measure.allow` and `manage.allow`, each of which carries its own `default allow := false`, so an incomplete section denies |

## Govern: sub-categories implemented

| Category | What the rule checks | GOPAL field |
|---|---|---|
| GOVERN 1, Accountability | Roles & responsibilities documented; oversight mechanisms in place | `input.governance.roles_and_responsibilities_defined`, `input.governance.oversight_mechanisms_in_place` |
| GOVERN 2, Transparency | Public documentation available; decision explanations provided | `input.transparency.public_documentation_available`, `input.transparency.decision_explanations_provided` |
| GOVERN 3, Fairness | Bias assessments conducted; mitigation strategies in place | `input.fairness.bias_assessments_conducted`, `input.fairness.bias_mitigation_strategies_in_place` |

See [`examples/nist-ai-rmf-govern/`](../../examples/nist-ai-rmf-govern/) for a runnable example.

## Map: categories with scaffolding

The Map function focuses on **context**: who's affected, what the use case is, what risks are known. GOPAL ships package-level scaffolding ready for fleshed-out logic.

| Category | Status | Help wanted |
|---|---|---|
| MAP 1, Context established | ⚠️ Scaffold | Yes, needs input schema for use-case description, deployment context, affected populations |
| MAP 2, Categorization of the AI system | ⚠️ Scaffold | Yes, needs taxonomy mapping (LLM, computer vision, recommender, …) |
| MAP 3, Capabilities & limitations characterized | ⚠️ Scaffold | Yes, needs eval-result schema |
| MAP 4, Risks & benefits mapped | ⚠️ Scaffold | Yes, needs risk-register input |
| MAP 5, Impacts characterized | ⚠️ Scaffold | Yes, needs stakeholder-impact input |

## Measure: categories with scaffolding

The Measure function operationalizes risk into metrics. GOPAL has the package structure; the substantive metric thresholds are still open.

| Category | Status | Help wanted |
|---|---|---|
| MEASURE 1, Appropriate methods identified | ⚠️ Scaffold | Yes |
| MEASURE 2, Trustworthiness characteristics evaluated | ⚠️ Scaffold | Yes, needs per-characteristic threshold schema (accuracy, robustness, fairness, etc.) |
| MEASURE 3, Tracked over time | ⚠️ Scaffold | Yes |
| MEASURE 4, Feedback gathered | ⚠️ Scaffold | Yes |

## Manage: categories with scaffolding

| Category | Status | Help wanted |
|---|---|---|
| MANAGE 1, Risks prioritized | ⚠️ Scaffold | Yes |
| MANAGE 2, Risk responses planned | ⚠️ Scaffold | Yes |
| MANAGE 3, Risks from third parties addressed | ⚠️ Scaffold | Yes |
| MANAGE 4, Risk treatment documented | ⚠️ Scaffold | Yes |

## Generative AI Profile (NIST AI 600-1)

| Risk category | Status | Notes |
|---|---|---|
| CBRN information / capabilities | 📋 Planned | Awaiting input schema |
| Confabulation | 📋 Planned | Could overlap with `global/v1/toxicity` patterns |
| Dangerous, violent, hateful content | 📋 Planned | Overlap with `global/v1/toxicity` |
| Data privacy | 📋 Planned | Coordinate with `industry_specific/education/v1/student_data_privacy` |
| Environmental impacts | 📋 Planned | Coordinate with `operational/cost/v1` |
| Harmful bias and homogenization | 📋 Planned | Coordinate with `global/v1/fairness` |
| Human-AI configuration | 📋 Planned | |
| Information integrity | 📋 Planned | |
| Information security | 📋 Planned | Coordinate with `operational/corporate/v1` |
| Intellectual property | 📋 Planned | |
| Obscene, degrading, abusive content | 📋 Planned | Overlap with `global/v1/toxicity` |
| Value chain & component integration | 📋 Planned | |

The `ai_600_1` orchestrator package is in place ([`international/nist/v1/ai_600_1/`](../../international/nist/v1/ai_600_1)): what's needed is per-risk rules that compose into it.

## How to help

1. **Promote a scaffold.** Pick a Map/Measure/Manage category and write field checks against a concrete input schema. Use [`govern/governance.rego`](../../international/nist/v1/govern/governance.rego) as a template.
2. **Open a 600-1 risk.** Pick one of the 12 risk categories above and propose an input schema + Rego rule.
3. **Push back on coverage calls.** If you read NIST differently, open an issue. The matrix is the team's interpretation, not the framework itself.

> ⚠️ Reminder: GOPAL is not legal advice or an official NIST artifact. The matrix above is GOPAL's *engineering* mapping. Use it as a starting point for your own AI risk assessment, not a substitute for one.
