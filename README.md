<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/hero_banner_dark.svg">
    <img src="docs/diagrams/hero_banner_light.svg" alt="GOPAL: the Rego policy library for AI compliance" width="100%">
  </picture>
</div>

<p align="center">
  <a href="README.md">English</a> |
  <a href="docs/i18n/README.zh-CN.md">简体中文</a> |
  <a href="docs/i18n/README.ja-JP.md">日本語</a> |
  <a href="docs/i18n/README.ko-KR.md">한국어</a> |
  <a href="docs/i18n/README.hi-IN.md">हिन्दी</a>
</p>

<p align="center">
  <em>AI compliance rules you can read, run, diff, and prove.</em>
</p>
<p align="center">
  <sub>EU AI Act · UK AI framework · NIST AI RMF · aviation · financial services · education · healthcare · legal practice</sub>
</p>

<p align="center">
  <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg" alt="OPA CI"></a>
    <a href="https://github.com/Principled-Evolution/gopal/actions/workflows/model-switch-demo.yaml"><img src="https://github.com/Principled-Evolution/gopal/actions/workflows/model-switch-demo.yaml/badge.svg" alt="Compliance gate demo"></a>
  <a href="https://github.com/Principled-Evolution/gopal/stargazers"><img src="https://img.shields.io/github/stars/Principled-Evolution/gopal?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/Principled-Evolution/gopal/releases"><img src="https://img.shields.io/github/v/release/Principled-Evolution/gopal?style=flat-square&color=brightgreen" alt="Latest release"></a>
  <a href="https://www.openpolicyagent.org/"><img src="https://img.shields.io/badge/OPA-1.20.1-blue.svg?style=flat-square" alt="OPA 1.20.1"></a>
  <a href="https://github.com/open-policy-agent/regal"><img src="https://img.shields.io/badge/lint-regal-yellow.svg?style=flat-square" alt="Regal"></a>
  <a href="https://doi.org/10.5281/zenodo.22142302"><img src="https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22142302-blue.svg?style=flat-square" alt="DOI"></a>
  <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square" alt="Apache 2.0"></a>
  <a href="https://github.com/open-policy-agent/awesome-opa"><img src="https://awesome.re/mentioned-badge-flat.svg" alt="Mentioned in Awesome OPA"></a>
  <a href="https://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome"></a>
</p>

<br>

**GOPAL: Governance Open Policy Agent Library.** Think of it as an open policy pack for AI regulation.

92 policies that translate published regulation into industry-standard policy-as-code, written in Rego for [OPA](https://www.openpolicyagent.org/). Each one takes a named instrument, encodes its obligations as executable rules, cites the article or control it enforces, ships with tests, and appears in a coverage matrix that states what is implemented and what is not. The EU AI Act, NIST AI RMF, aviation safety standards, FERPA and COPPA in education, fair-lending rules in banking, and more.

Run them against two kinds of input: facts you declare about the system and the organisation around it, and metrics an evaluator measures. You get back a structured, machine-readable verdict you can drop into CI, an audit log, or a regulator submission.

<p align="center">
  <img src="docs/demo/model-switch-animated.svg" alt="A terminal session. The production model scores 0.0056 against a 0.1 threshold and passes. After swapping the model, the aggregate is 0.1373, global.v1.toxicity.allow fails, and the output responsible is listed at 0.8106." width="88%" />
</p>

<p align="center">
  <sub>Swap the model, keep the prompts and the classifier. A rule nobody edited stops the merge and names the output responsible. <a href="examples/model-switch">This example</a> runs in CI on every push, and asserts both directions.</sub>
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/diagram1_hero_numbers_dark.svg">
    <img src="docs/diagrams/diagram1_hero_numbers_light.svg" alt="GOPAL coverage: 92 policies across international standards, aviation, industry verticals, and cross-cutting principles" width="85%" />
  </picture>
</p>

> **Tell us where this is wrong.** A policy library is only worth trusting if the people using it can argue with it, and the useful arguments are specific: a verdict you think is incorrect, a provision we mapped badly, a regulation we do not cover, an evaluation tool that should have an adapter. We corrected the model-card analysis once already because somebody did exactly that.
>
> [Request a framework](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml) · [Request a policy](https://github.com/Principled-Evolution/gopal/issues/new?template=new_policy.yml) · [Report a wrong verdict](https://github.com/Principled-Evolution/gopal/issues/new?template=bug_report.yml) · [Start a discussion](https://github.com/Principled-Evolution/gopal/discussions)
>
> Every policy is a file with a test beside it, so an extension is a pull request rather than a project. [CONTRIBUTING.md](.github/CONTRIBUTING.md) is short.

<p align="center">
  <b>Jump to:</b>
  <a href="#quick-start">Run it now</a> &middot;
  <a href="#whats-inside">What's covered</a> &middot;
  <a href="#for-opa--rego-users">Already using OPA</a> &middot;
  <a href="#supplying-measured-metrics">Supply your own metrics</a> &middot;
  <a href="#authoring-policies">Write a policy</a> &middot;
  <a href="#comparison">How it compares</a> &middot;
  <a href="#community-and-support">Contribute</a>
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
    <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/diagram5_evaluation_flow_dark.svg">
    <img src="docs/diagrams/diagram5_evaluation_flow_light.svg" alt="How GOPAL evaluation works: input JSON, Rego policy, OPA evaluation, verdict" width="85%" />
  </picture>
</p>

### Try GOPAL in 30 seconds

```bash
git clone https://github.com/Principled-Evolution/gopal.git
cd gopal/examples/eu-ai-act-transparency
./run.sh
```

You'll see a structured EU AI Act transparency verdict against a sample AI system. See [`examples/`](examples) for NIST AI RMF, customer-support LLM, and more.

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
3. **Versioned.** Every framework lives under `v1/` (then `v2/`, etc.) with explicit semver guarantees (see [COMPATIBILITY.md](docs/COMPATIBILITY.md)). When the EU AI Act amends, the old version stays put.

---

## For OPA / Rego users

If you already run OPA for Kubernetes admission, cloud authorization, CI/CD, or service mesh, GOPAL gives you a policy library targeted at AI systems instead of infrastructure.

The packages, conventions, and test patterns are idiomatic Rego. There is no DSL on top, and you don't need Python to evaluate. You can:

- download a prebuilt bundle for one framework, rather than vendoring the whole tree
- evaluate with `opa eval`, [Conftest](https://www.conftest.dev/), or your existing OPA server
- pin to a major version (`v1/`) and review upgrades as PRs
- compose GOPAL rules with your private `custom/` rules in the same evaluation
- lint with [Regal](https://github.com/open-policy-agent/regal), the same linter GOPAL runs in CI

### Per-framework bundles

Every release ships one OPA bundle per framework, so you can take the 29 EU AI Act policies without the aviation or FERPA ones. Each bundle is self-contained: it carries the shared libraries its policies import, so it evaluates with no other GOPAL files present.

```bash
gh release download v1.3.1 --pattern 'gopal-international-eu_ai_act-*.tar.gz'

opa eval -b gopal-international-eu_ai_act-1.3.1.tar.gz \
  --input model_card.json \
  'data.international.eu_ai_act.v1.transparency.allow'
```

The EU AI Act bundle is 24K against 56K for the whole library, and there is a `gopal-all-<version>.tar.gz` if you do want everything. Because the per-framework bundles each include the shared libraries, their roots overlap and OPA will not load two of them side by side; use the full bundle when you need more than one framework. Every release also carries a `checksums.txt`.

Build them yourself with [`scripts/build-bundles.sh`](scripts/build-bundles.sh), which loads each bundle back and asserts a real decision denies on empty input before declaring success.

### Supplying measured metrics

Policies read two kinds of input: facts a person declares, and metrics a tool measures. The measured half is where an integration has to do real work, and [Plug your evaluator into GOPAL](docs/tutorials/supplying-metrics.md) walks it end to end in plain `opa`: find what a policy reads, use the canonical name from [`helper_functions/metrics.rego`](helper_functions/metrics.rego), write the JSON, gate a build on the result. No Python, no framework.

### What automation actually looks like

Change the model, keep everything else, and watch a rule stop the merge:

<p align="center">
  <img src="docs/demo/model-switch.svg" alt="Two runs of check.sh: the production model passes at 0.0056, the swapped model fails at 0.1373 with the offending output named" width="88%" />
</p>

[`examples/model-switch`](examples/model-switch) is the whole thing, and the **Compliance gate demo** badge above runs it on every push. It asserts both directions, because a gate that only ever passes is indistinguishable from a gate that is broken.

Most of the EU AI Act is declarations a person signs; nothing can measure whether a conformity assessment happened. Five policies run entirely on measured metrics, and those are the ones worth automating first: toxicity, Article 11 technical documentation, fair lending, diagnostic safety, and fairness. The example names each one and what supplies it.

If you want a Python framework that handles input capture and PDF/Markdown report generation on top, see [AICertify](https://github.com/Principled-Evolution/aicertify). It takes the scaffolding off you; it is not required to use any of this.

---

## What's Inside

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/diagram2_directory_tree_dark.svg">
    <img src="docs/diagrams/diagram2_directory_tree_light.svg" alt="GOPAL directory layout: 4 top-level branches, policies organized by jurisdiction and vertical" width="85%" />
  </picture>
</p>

```
gopal/
├── international/        Frameworks crossing borders
│   ├── eu_ai_act/v1/         29 policies — EU AI Act 2024/1689
│   ├── nist/v1/              5  policies — NIST AI RMF + AI 600-1
│   ├── india/v1/             1  policy   — Digital India Policy
│   ├── brazil/v1/            1  policy   — AI Governance Bill
│   ├── uk/v1/                6  policies — pro-innovation principles, UK GDPR Arts 22A-22D
│   ├── icao/v1/              1  policy   — ICAO Doc 10019
│   ├── faa/v1/               2  policies — Part 107, Remote ID
│   ├── easa/v1/              2  policies — Regulation 2019/947, SORA
│   └── standards/v1/         2  policies — RTCA DO-365, ISO 21384
│
├── industry_specific/    Vertical-specific requirements
│   ├── education/v1/         12 policies — FERPA, COPPA, proctoring, grading
│   ├── aviation/v1/          12 policies — airworthiness, autonomy, data, ops
│   ├── healthcare/v1/         2 policies — patient & diagnostic safety
│   ├── bfs/v1/                4 policies — model risk, fair lending, PRA SS1/23, FCA Consumer Duty
│   ├── legal/v1/              3 policies — citation verification, privilege, supervision
│   └── automotive/v1/         1 policy   — vehicle safety integration
│
├── global/v1/             4  policies — accountability, fairness, transparency, toxicity
│   └── common/            5  libraries — shared fairness, content-safety, risk
│                                       and compliance helpers, imported by the
│                                       framework policies rather than run directly
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

**92 policies that reach a verdict, plus 7 shared libraries they import. 196 Rego files including tests.** These figures are generated from the tree by [`scripts/generate-coverage.sh`](scripts/generate-coverage.sh) and checked in CI, so they cannot drift from the code. Run `jq .totals docs/coverage/coverage.json` for the current numbers.

---

## Comparison

| | GOPAL | Generic OPA bundle | Vendor governance SaaS |
|---|---|---|---|
| Targets AI systems specifically | ✅ | ❌ | ✅ |
| Open source (Apache 2.0) | ✅ | ✅ | ❌ |
| You can read every rule | ✅ Rego | ✅ Rego | ❌ Hidden |
| Tracks named regulations (EU AI Act, NIST RMF, FAA) | ✅ 10+ | ❌ | Partial |
| Industry-specific verticals out of the box | ✅ 6 | ❌ | Limited |
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
    <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/diagram3_policy_anatomy_dark.svg">
    <img src="docs/diagrams/diagram3_policy_anatomy_light.svg" alt="Anatomy of a GOPAL policy: package path, imports, metadata, default deny, allow rule, report" width="85%" />
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

The [helper_functions/](helper_functions) library gives you `compose_report()`, `validate_required_fields()`, and `field_exists()` so reports come out in a uniform shape no matter who wrote the rule.

See [`docs/tutorials/add-your-first-policy.md`](docs/tutorials/add-your-first-policy.md) for a walkthrough, and [`docs/coverage/`](docs/coverage) for per-framework coverage matrices.

---

## Policy correctness

GOPAL is not legal advice. The policies here are executable interpretations of public regulatory and governance requirements, written by engineers who care about getting them right.

If you believe a rule misreads a regulation or misses an obligation, please open an issue with:

- the regulation, section, or article in question
- your interpretation
- the input/output behavior you'd expect
- any official guidance, regulator text, or precedent

Policy-correctness disagreements are not security vulnerabilities; see [SECURITY.md](.github/SECURITY.md) for those. We want disagreements about interpretation in the open, where the community can review the rules and improve them.

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
curl -L -o regal https://github.com/open-policy-agent/regal/releases/latest/download/regal_Linux_x86_64 && chmod +x regal && sudo mv regal /usr/local/bin/
pre-commit install

# Run the same checks CI runs
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for the PR workflow.

---

## Roadmap

- **More NIST coverage**: filling out the Measure and Manage controls
- **ICO statutory code of practice on AI and automated decision-making**, expected 2026
- **EU GDPR, scoped to the AI-relevant articles**: Article 22 and Recital 71, Article 35 DPIA triggers, Article 9, Articles 5(1)(c) and 5(1)(e), Articles 13 and 14, and Article 25. Deliberately not the whole regulation, because most of GDPR describes organisational practice that an input document cannot evidence. The UK counterpart to the Article 22 regime is already implemented and the two have now diverged, so the pair is worth having side by side
- **MAS / HKMA banking AI guidance** for APAC financial supervision
- **Per-metric test coverage**: every policy is now tested against empty input, but the stronger check is removing one required metric at a time. That is what surfaced the most recent fail-open

Need a framework that isn't here? [Ask for it](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml). You don't have to write any Rego to make the request.

---

## Related Projects

- **[AICertify](https://github.com/Principled-Evolution/aicertify)**: Python framework that uses GOPAL to evaluate AI applications and produce audit-ready PDF/MD/JSON reports.
- **[Open Policy Agent](https://www.openpolicyagent.org/)**: the policy engine.
- **[Regal](https://github.com/open-policy-agent/regal)**: the Rego linter we use in CI.

---

## Community and support

We work upstream as well as here. OPA [v1.20.1](https://github.com/open-policy-agent/opa/releases/tag/v1.20.1) exists to fix a number-comparison regression we found while running this library, [reported and patched](https://github.com/open-policy-agent/opa/pull/9099) by us.

You don't need to know Rego, OPA, or GitHub conventions to get an answer here.

| If you want to | Use this |
| --- | --- |
| Ask how to integrate GOPAL into your CI, OPA server, or platform | [Integration help form](https://github.com/Principled-Evolution/gopal/issues/new?template=integration_help.yml) or a [Q&A discussion](https://github.com/Principled-Evolution/gopal/discussions/new?category=q-a) |
| Request a regulation or standard GOPAL doesn't cover yet | [New framework request](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml) |
| Request a specific policy inside a framework we already cover | [New policy request](https://github.com/Principled-Evolution/gopal/issues/new?template=new_policy.yml) |
| Report a policy that returns the wrong verdict | [Bug report](https://github.com/Principled-Evolution/gopal/issues/new?template=bug_report.yml) |
| Email us instead of using GitHub | **gopal@principledevolution.ai** |
| Report a security vulnerability | See [SECURITY.md](.github/SECURITY.md). Please don't open a public issue. |

Two things answer most questions before you file anything. The [coverage matrices](docs/coverage) list what's already implemented, article by article. The [FAQ](docs/FAQ.md) covers scope, input shapes, and how GOPAL relates to AICertify.

Contributions of any size are welcome; see [CONTRIBUTING.md](.github/CONTRIBUTING.md). Participation is governed by our [Code of Conduct](.github/CODE_OF_CONDUCT.md).

### Listed in

- [**awesome-opa**](https://github.com/open-policy-agent/awesome-opa), the Open Policy Agent project's own curated list, under Policy Packages
- [**OPA ecosystem directory**](https://www.openpolicyagent.org/ecosystem/entry/principled-evolution)
- [**Awesome Europe**](https://github.com/GeiserX/awesome-europe), under Digital Regulation
- [**Awesome AI Governance**](https://github.com/agentrust-io/awesome-ai-governance), under Policy as Code
- [**Awesome Responsible AI**](https://github.com/AthenaCore/AwesomeResponsibleAI), under Policy as Code
- [**Awesome AI Agent Governance**](https://github.com/systempromptio/awesome-ai-agent-governance#policy-engines-and-authorisation), under Policy Engines and Authorisation

---

## How it fits together

Two diagrams, because the commonest misunderstanding is that a policy library
evaluates your model. It does not. It evaluates two kinds of statement that
come from two different places and carry two different levels of proof.

<p align="center">
  <img src="docs/diagrams/usage1_two_inputs.svg" alt="How a GOPAL policy gets its inputs: declared facts asserted by a person, and measured metrics produced by evaluators such as AICertify running DeepEval or LangFair, both feeding a Rego policy that returns satisfied, not satisfied, or no conclusion" width="70%">
</p>

Facts you **declare** are the ones no tool can measure: whether the CE marking
was affixed, whether logs are retained for six months. Metrics an evaluator
**measures** are the ones typing a number would not prove: toxicity, fairness
disparity, content safety. A policy reads both.

<p align="center">
  <img src="docs/diagrams/usage2_ci_loop.svg" alt="GOPAL as a required status check: a pull request carries committed compliance facts, AICertify runs evaluators to add measured metrics, opa eval runs a pinned GOPAL bundle, and the status check passes with a retained report or fails naming the article and control" width="70%">
</p>

Policy as code only means something once a policy can fail a pull request the
way a unit test does. Sources for both diagrams are in
[`docs/diagrams/src/`](docs/diagrams/src), rendered with
[`render-all.sh`](docs/diagrams/src/render-all.sh).

## Cite this

If GOPAL informs a paper, a policy submission or a regulator response, please
cite it. [`CITATION.cff`](CITATION.cff) is machine-readable, so GitHub's
**Cite this repository** button will generate APA or BibTeX for you.

```bibtex
@software{gopal,
  author  = {Madan, Kapil and {Principled Evolution}},
  title   = {{GOPAL}: the {Rego} policy library for {AI} compliance},
  version = {1.3.1},
  year    = {2026},
  license = {Apache-2.0},
  doi     = {10.5281/zenodo.22142302},
  url     = {https://doi.org/10.5281/zenodo.22142302}
}
```

That DOI is the *concept* DOI: it always resolves to the newest release, so a
citation using it does not go stale. To pin a reader to this exact version,
cite `10.5281/zenodo.22142303` instead. Each release is archived by Zenodo, so
the artefact survives independently of GitHub.

Cite the coverage matrices rather than the library as a whole if your claim is
about a specific framework: they state per article what is implemented and what
is not, which is the part that can be checked.

## License

Apache License 2.0. See [LICENSE](LICENSE).

<p align="center"><sub>Maintained by <a href="https://github.com/Principled-Evolution">Principled Evolution</a> · Compliance you can read, run, and prove.</sub></p>
