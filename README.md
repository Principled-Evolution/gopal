<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/hero_banner_dark.svg">
    <img src="diagrams/hero_banner_light.svg" alt="GOPAL: the Rego policy library for AI compliance" width="100%">
  </picture>
</div>

<p align="center">
  <a href="README.md">English</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja-JP.md">日本語</a> |
  <a href="README.ko-KR.md">한국어</a> |
  <a href="README.hi-IN.md">हिन्दी</a>
</p>

<p align="center">
  <em>AI compliance rules you can read, run, diff, and prove.</em>
</p>
<p align="center">
  <sub>85 policies · 8 international frameworks · 5 industry verticals</sub>
</p>

<p align="center">
  <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg" alt="OPA CI"></a>
  <a href="https://github.com/Principled-Evolution/gopal/stargazers"><img src="https://img.shields.io/github/stars/Principled-Evolution/gopal?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/Principled-Evolution/gopal/releases"><img src="https://img.shields.io/badge/version-1.0.0-brightgreen.svg?style=flat-square" alt="Version 1.0.0"></a>
  <a href="https://www.openpolicyagent.org/"><img src="https://img.shields.io/badge/OPA-latest-blue.svg?style=flat-square" alt="OPA"></a>
  <a href="https://github.com/StyraInc/regal"><img src="https://img.shields.io/badge/lint-regal-yellow.svg?style=flat-square" alt="Regal"></a>
  <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square" alt="Apache 2.0"></a>
  <img src="https://img.shields.io/badge/policies-85-orange.svg?style=flat-square" alt="85 Policies">
  <img src="https://img.shields.io/badge/frameworks-8-purple.svg?style=flat-square" alt="8 Frameworks">
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome"></a>
</p>

<br>

**GOPAL: Governance Open Policy Agent Library.** Think of it as an open policy pack for AI regulation.

A curated collection of [OPA](https://www.openpolicyagent.org/) policies, written in Rego, that encode real AI-governance requirements: the EU AI Act, NIST AI RMF, aviation safety standards, FERPA/COPPA in education, fair-lending rules in banking, and more.

Run them against your AI system's metadata, model cards, or evaluation results. You get back a structured, machine-readable compliance verdict you can drop into CI, an audit log, or a regulator submission.

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram1_hero_numbers_dark.svg">
    <img src="diagrams/diagram1_hero_numbers_light.svg" alt="GOPAL coverage: 85 policies across international standards, aviation, industry verticals, and cross-cutting principles" width="85%" />
  </picture>
</p>

---

## AI compliance rules you can read, run, diff, and prove

GOPAL turns regulatory and governance requirements (the EU AI Act, NIST AI RMF, aviation safety standards, FERPA/COPPA, fair lending, healthcare safety) into executable OPA policies.

Use GOPAL when you want AI governance checks that are:

- **Readable.** Every rule is Rego, not a black-box score.
- **Reviewable.** Policy changes go through pull requests.
- **Testable.** Every policy can have allow/deny test cases.
- **Versioned.** Frameworks evolve without breaking pinned users.
- **Automatable.** Run checks in CI/CD, audit workflows, or AICertify.

---

## Why now

The EU AI Act is in force. The NIST AI RMF is the de facto US baseline. The UK, India, Brazil, Singapore, and California are all moving. Aviation regulators are publishing AI/UAS guidance. Financial supervisors are issuing model-risk requirements.

Engineering teams need AI governance checks that run in CI, not PDFs sitting on a shared drive or screenshots pasted into review-board decks.

GOPAL ships executable Rego policies for each of those regimes. They are versioned, testable, and reviewable in pull requests. The same tooling your platform team already uses for Kubernetes admission control can now enforce AI-system requirements.

---

## Quick Start

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram5_evaluation_flow_dark.svg">
    <img src="diagrams/diagram5_evaluation_flow_light.svg" alt="How GOPAL evaluation works: input JSON, Rego policy, OPA evaluation, verdict" width="85%" />
  </picture>
</p>

### Try GOPAL in 30 seconds

```bash
git clone https://github.com/Principled-Evolution/gopal.git
cd gopal/examples/eu-ai-act-transparency
./run.sh
```

You'll see a structured EU AI Act transparency verdict against a sample AI system. See [`examples/`](examples/) for NIST AI RMF, customer-support LLM, and more.

### Standalone with the OPA CLI

```bash
# Get OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa

# Clone gopal
git clone https://github.com/Principled-Evolution/gopal.git && cd gopal

# Evaluate your input against the EU AI Act
./opa eval -d international/eu_ai_act/v1 \
  --input my_ai_system.json \
  "data.international.eu_ai_act.v1.transparency.allow"
```

### As the policy engine for AICertify

```python
from aicertify import regulations, application

regs = regulations.create("eu_compliance")
regs.add("eu_ai_act")  # gopal policies under the hood

app = application.create(name="my-llm-app", ...)
await app.evaluate(regulations=regs, report_format="pdf")
```

See [AICertify](https://github.com/Principled-Evolution/aicertify) for the full Python framework.

---

## Why GOPAL

Most "AI governance" lives in slide decks. The few open implementations are either:

- **Generic OPA bundles** (great for Kubernetes admission, not for the EU AI Act), or
- **Closed SaaS** that hides the rules you're being judged against.

Where GOPAL differs:

1. **AI-specific by construction.** Every policy targets an AI-system concern: bias, transparency, human oversight, model risk, content safety, safety-critical certification. Not generic infrastructure.
2. **Readable.** The rules are Rego. You can `cat` them, diff them in a PR, and reason about them. No black-box scorecards.
3. **Versioned.** Every framework lives under `v1/` (then `v2/`, etc.) with explicit semver guarantees (see [COMPATIBILITY.md](COMPATIBILITY.md)). When the EU AI Act amends, the old version stays put.

---

## For OPA / Rego users

If you already run OPA for Kubernetes admission, cloud authorization, CI/CD, or service mesh, GOPAL gives you a policy library targeted at AI systems instead of infrastructure.

The packages, conventions, and test patterns are idiomatic Rego. There is no DSL on top, and you don't need Python to evaluate. You can:

- pull individual frameworks (`international/eu_ai_act/v1/`, `industry_specific/aviation/v1/`) into a bundle
- evaluate with `opa eval`, [Conftest](https://www.conftest.dev/), or your existing OPA server
- pin to a major version (`v1/`) and review upgrades as PRs
- compose GOPAL rules with your private `custom/` rules in the same evaluation
- lint with [Regal](https://github.com/StyraInc/regal), the same linter GOPAL runs in CI

If you want a Python framework that handles input capture and PDF/Markdown report generation on top, see [AICertify](https://github.com/Principled-Evolution/aicertify).

---

## What's Inside

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram2_directory_tree_dark.svg">
    <img src="diagrams/diagram2_directory_tree_light.svg" alt="GOPAL directory layout: 4 top-level branches, policies organized by jurisdiction and vertical" width="85%" />
  </picture>
</p>

```
gopal/
├── international/        Frameworks crossing borders
│   ├── eu_ai_act/v1/         29 policies — EU AI Act 2024/1689
│   ├── nist/v1/              5  policies — NIST AI RMF + AI 600-1
│   ├── india/v1/             1  policy   — Digital India Policy
│   ├── brazil/v1/            1  policy   — AI Governance Bill
│   ├── icao/v1/              1  policy   — ICAO Doc 10019
│   ├── faa/v1/               2  policies — Part 107, Remote ID
│   ├── easa/v1/              2  policies — Regulation 2019/947, SORA
│   └── standards/v1/         2  policies — RTCA DO-365, ISO 21384
│
├── industry_specific/    Vertical-specific requirements
│   ├── education/v1/         12 policies — FERPA, COPPA, proctoring, grading
│   ├── aviation/v1/          12 policies — airworthiness, autonomy, data, ops
│   ├── healthcare/v1/         2 policies — patient & diagnostic safety
│   ├── bfs/v1/                2 policies — model risk, fair lending
│   └── automotive/v1/         1 policy   — vehicle safety integration
│
├── global/v1/             9  policies — accountability, fairness, transparency,
│                                       explainability, content safety,
│                                       risk management, security, common rules
│
├── operational/          DevOps & corporate
│   ├── aiops/v1/              1 policy   — scalability
│   ├── cost/v1/               1 policy   — resource efficiency
│   └── corporate/v1/          2 policies — InfoSec, governance
│
├── helper_functions/     Shared utilities for policy authors
│   ├── reporting.rego        Standardized report-output helpers
│   └── validation.rego       Field-presence and required-field checks
│
└── custom/               Your private policies (git-ignored, CI-skipped)
```

**85 production policies. 124 Rego files including tests.**

---

## Comparison

| | GOPAL | Generic OPA bundle | Vendor governance SaaS |
|---|---|---|---|
| Targets AI systems specifically | ✅ | ❌ | ✅ |
| Open source (Apache 2.0) | ✅ | ✅ | ❌ |
| You can read every rule | ✅ Rego | ✅ Rego | ❌ Hidden |
| Tracks named regulations (EU AI Act, NIST RMF, FAA) | ✅ 10+ | ❌ | Partial |
| Industry-specific verticals out of the box | ✅ 5 | ❌ | Limited |
| Aviation / safety-critical coverage | ✅ ICAO, RTCA, FAA, EASA, ISO | ❌ | ❌ |
| Education sector (FERPA / COPPA) | ✅ | ❌ | Rare |
| Versioned policies (`v1/`, `v2/` …) | ✅ Semver | Varies | N/A |
| CI/CD integration | ✅ `opa check` + Regal | ✅ | Varies |
| Custom local policies (not shared upstream) | ✅ `custom/` is git-ignored | ❌ | Paid tier |

A few other open-source projects worth knowing about: [VerifyWise](https://github.com/verifywise-ai/verifywise) and [Compl-AI](https://github.com/compl-ai/compl-ai) both evaluate AI systems against the EU AI Act and other frameworks. [airblackbox](https://github.com/airblackbox) scans agent frameworks like LangChain, CrewAI, and AutoGen for compliance gaps at runtime. GOPAL's difference is that it's plain Rego/OPA, so it slots into policy tooling you may already run for Kubernetes or cloud authorization, and it isn't limited to the EU AI Act. Aviation, education, and banking frameworks are in the same tree, all versioned and tested the same way.

---

## GOPAL vs AICertify

| Need | Use |
|---|---|
| I want raw Rego policies | GOPAL |
| I want to evaluate an AI app and generate reports | AICertify |
| I want to plug policies into existing OPA tooling | GOPAL |
| I want PDF/Markdown/JSON audit reports | AICertify |

AICertify uses GOPAL underneath. Pick GOPAL if you already have an OPA workflow you want to extend with AI-specific rules. Pick AICertify if you want a Python framework that captures AI-application interactions and produces audit-ready evidence end-to-end.

---

## Authoring Policies

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="diagrams/diagram3_policy_anatomy_dark.svg">
    <img src="diagrams/diagram3_policy_anatomy_light.svg" alt="Anatomy of a GOPAL policy: package path, imports, metadata, default deny, allow rule, report" width="85%" />
  </picture>
</p>

Every policy follows the same shape:

```rego
package international.eu_ai_act.v1.transparency

import data.helper_functions.reporting

# Metadata describes the rule for tooling and auditors.
# METADATA
# title: Transparency for general-purpose AI systems
# description: GPAI providers must publish technical documentation per Article 53.

default allow := false

allow if {
    input.system.technical_documentation_published == true
    input.system.training_data_summary_published == true
}

report := reporting.compose_report(
    "eu_ai_act.transparency",
    allow,
    [{"name": "documentation_present", "value": allow, "control_passed": allow}],
)
```

Then a sibling `*_test.rego` covers the rule. CI enforces:

1. **`opa check`** for syntax and reference correctness across all packages
2. **`regal lint`** for Rego style and best practices

The [helper_functions/](helper_functions/) library gives you `compose_report()`, `validate_required_fields()`, and `field_exists()` so reports come out in a uniform shape no matter who wrote the rule.

See [`docs/tutorials/add-your-first-policy.md`](docs/tutorials/add-your-first-policy.md) for a walkthrough, and [`docs/coverage/`](docs/coverage/) for per-framework coverage matrices.

---

## Policy correctness

GOPAL is not legal advice. The policies here are executable interpretations of public regulatory and governance requirements, written by engineers who care about getting them right.

If you believe a rule misreads a regulation or misses an obligation, please open an issue with:

- the regulation, section, or article in question
- your interpretation
- the input/output behavior you'd expect
- any official guidance, regulator text, or precedent

Policy-correctness disagreements are not security vulnerabilities; see [SECURITY.md](SECURITY.md) for those. We want disagreements about interpretation in the open, where the community can review the rules and improve them.

---

## Custom Policies

The `custom/` directory is for **your organization's proprietary policies**. It's:

- `.gitignore`d, so nothing in it reaches this repo
- Skipped by CI
- Structured identically to the public tree (`custom/your_org/v1/...`)

Drop in your internal AI use-case rules without forking. They evaluate alongside the public set.

---

## Development

```bash
# One-time setup
pip install pre-commit
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa && sudo mv opa /usr/local/bin/
curl -L -o regal https://github.com/StyraInc/regal/releases/latest/download/regal_Linux_x86_64 && chmod +x regal && sudo mv regal /usr/local/bin/
pre-commit install

# Run the same checks CI runs
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the PR workflow.

---

## Roadmap

- **More NIST coverage**: filling out the Measure and Manage controls
- **UK AI regulation principles**: the pro-innovation framework rules
- **California SB-1047 successor**, once it is finalized
- **MAS / HKMA banking AI guidance** for APAC financial supervision

Need a framework that isn't here? [Ask for it](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml). You don't have to write any Rego to make the request.

---

## Related Projects

- **[AICertify](https://github.com/Principled-Evolution/aicertify)**: Python framework that uses GOPAL to evaluate AI applications and produce audit-ready PDF/MD/JSON reports.
- **[Open Policy Agent](https://www.openpolicyagent.org/)**: the policy engine.
- **[Regal](https://github.com/StyraInc/regal)**: the Rego linter we use in CI.

---

## Community and support

You don't need to know Rego, OPA, or GitHub conventions to get an answer here.

| If you want to | Use this |
| --- | --- |
| Ask how to integrate GOPAL into your CI, OPA server, or platform | [Integration help form](https://github.com/Principled-Evolution/gopal/issues/new?template=integration_help.yml) or a [Q&A discussion](https://github.com/Principled-Evolution/gopal/discussions/new?category=q-a) |
| Request a regulation or standard GOPAL doesn't cover yet | [New framework request](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml) |
| Request a specific policy inside a framework we already cover | [New policy request](https://github.com/Principled-Evolution/gopal/issues/new?template=new_policy.yml) |
| Report a policy that returns the wrong verdict | [Bug report](https://github.com/Principled-Evolution/gopal/issues/new?template=bug_report.yml) |
| Email us instead of using GitHub | **gopal@principledevolution.ai** |
| Report a security vulnerability | See [SECURITY.md](SECURITY.md). Please don't open a public issue. |

Two things answer most questions before you file anything. The [coverage matrices](docs/coverage) list what's already implemented, article by article. The [FAQ](docs/FAQ.md) covers scope, input shapes, and how GOPAL relates to AICertify.

Contributions of any size are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md). Participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## License

Apache License 2.0. See [LICENSE](LICENSE).

<p align="center"><sub>Maintained by <a href="https://github.com/Principled-Evolution">Principled Evolution</a> · Compliance you can read, run, and prove.</sub></p>
