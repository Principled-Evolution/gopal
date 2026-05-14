# Agent Instructions — GOPAL

This file is the canonical operational guide for AI coding agents working in this repository (Claude Code, Cursor, Codex, Windsurf, Gemini CLI, Copilot, etc.). Tool-specific files (`CLAUDE.md`, `GEMINI.md`) inherit from this and add only platform-specific notes.

## What this project is

**GOPAL** (Governance Open Policy Agent Library) is a curated set of [OPA](https://www.openpolicyagent.org/) Rego policies encoding real-world AI-governance requirements — the EU AI Act, NIST AI RMF, aviation safety standards, FERPA/COPPA in education, fair-lending rules, and more.

It is consumable two ways:

1. **Standalone** via the OPA CLI / Go SDK / any OPA-compatible runtime
2. **As the policy engine for [AICertify](https://github.com/Principled-Evolution/aicertify)**, which provides a Python framework, report generators, and an end-to-end compliance flow

## Repository layout

```
gopal/
├── global/v1/                Cross-cutting categories (fairness, transparency, …)
├── international/            Per-jurisdiction frameworks
│   ├── eu_ai_act/v1/         29 policies — EU AI Act 2024/1689
│   ├── nist/v1/              NIST AI RMF + AI 600-1
│   ├── india/v1/             India Digital Policy
│   ├── brazil/v1/            Brazil AI Governance Bill
│   ├── icao/, faa/, easa/    Aviation regulators
│   └── standards/v1/         RTCA DO-365/366, ASTM F3442, ISO 21384
├── industry_specific/
│   ├── aviation/v1/          17 policies — detect & avoid, certification, design
│   ├── education/v1/         12 policies — FERPA, COPPA, proctoring, grading
│   ├── healthcare/v1/        Patient & diagnostic safety
│   ├── bfs/v1/               Model risk, fair lending
│   └── automotive/v1/        Vehicle safety integration
├── operational/              AIOps, cost, corporate
├── helper_functions/         Shared utilities (reporting.rego, validation.rego)
├── custom/                   Local-only org policies — git-ignored, CI-skipped
├── pyproject.toml            Distribution as a Python package (Rego files included)
├── .regal/config.yaml        Regal linter configuration
└── .github/workflows/        OPA + Regal CI
```

**94 production policies. 125 Rego files including tests.**

## Useful commands

```bash
# Run the same checks CI runs
opa check --ignore custom/ .
regal lint --ignore-files custom/ .

# Pre-commit (auto-runs on commit if installed)
pre-commit install
pre-commit run --all-files

# Evaluate a policy against an input
opa eval -d international/eu_ai_act/v1 \
  --input your_input.json \
  "data.international.eu_ai_act.v1.transparency.allow"

# Run tests for a single policy
opa test -v international/eu_ai_act/v1/transparency.rego \
        international/eu_ai_act/v1/transparency_test.rego
```

## Authoring a new policy

This is the most common task. Strict conventions:

### 1. Directory structure

```
{domain}/{framework}/v{N}/{policy_name}.rego
{domain}/{framework}/v{N}/{policy_name}_test.rego
```

Where `{domain}` is one of `global`, `international`, `industry_specific`, `operational`.

### 2. Mandatory file contents

```rego
package international.eu_ai_act.v1.transparency  # MUST match directory path

import data.helper_functions.reporting

# METADATA
# title: Transparency obligations for GPAI providers
# description: Article 53 — technical documentation must be published.
# version: 1
# source: https://eur-lex.europa.eu/eli/reg/2024/1689/oj

default allow := false

allow if {
    input.system.technical_documentation_published == true
}

report := reporting.compose_report(
    "eu_ai_act.transparency",
    allow,
    [{"name": "documentation_present", "value": allow, "control_passed": allow}],
)
```

### 3. Tests are required

Every `policy.rego` ships with `policy_test.rego` covering both the `allow` and `deny` paths.

### 4. Framework-level README

At each `international/<framework>/v1/` and `industry_specific/<industry>/v1/`, include a `README.md` with:

- **Source** — link to the official regulation/standard
- **Disclaimer** — "These policies are not legal advice; they encode the authors' reading of the source text in Rego."

### 5. Helpers

Use `helper_functions/reporting.rego` for output composition and `helper_functions/validation.rego` for input checks. Don't roll your own.

## CI quality gate

Both must pass:

```bash
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

If Regal flags an issue, look it up in the [Regal rule catalog](https://docs.styra.com/regal/rules) — don't disable rules without a documented reason.

## Conventions

- **One concept per file** — don't bundle unrelated checks. A policy file should answer one regulatory question.
- **Boolean output** — every policy exposes `allow` (or equivalent) and a `report` composed via `helper_functions.reporting`.
- **No external HTTP/file I/O** — policies must be pure functions of `input` and `data`. They evaluate offline.
- **Stable package paths** — the package path is the public API. Don't rename without bumping a major version.

## Versioning

Each framework lives under `v1/`. When the upstream regulation changes materially, add `v2/` alongside — don't mutate `v1/` in place. See [COMPATIBILITY.md](COMPATIBILITY.md).

## What NOT to do

- Don't edit policies under `custom/` — that's a local-only space for downstream consumers.
- Don't add a policy without tests. CI will pass but Regal lint reviews will catch you.
- Don't introduce dependencies on Styra-only Regal features that aren't in mainline OPA.
- Don't claim a regulation is "fully covered" unless every named article/section has a corresponding policy. Partial coverage is fine, just be explicit.

## Sister project

[AICertify](https://github.com/Principled-Evolution/aicertify) consumes GOPAL. When you add a framework here, AICertify users get it for free on next vendor sync.

## Conservatism

The author prefers **surgical changes**: do only what was asked, present the plan first when there's any ambiguity, and ask before introducing new abstractions. Critique your own design once for elegance, DRY, KISS, and explainability before presenting it.
