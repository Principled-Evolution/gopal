# Changelog

All notable changes to **GOPAL** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). See [COMPATIBILITY.md](COMPATIBILITY.md) for the versioning model applied to individual policy directories.

## [Unreleased]

### Added
- **UK AI governance framework** (`international/uk/v1/`, 6 policies). The five cross-sectoral principles from the pro-innovation white paper (CP 815), plus the automated decision-making regime in UK GDPR Articles 22A to 22D as substituted by section 80 of the Data (Use and Access) Act 2025, in force 5 February 2026. Two things are encoded that a naive reading would miss: the principles are non-statutory and are labelled as such, and the proportionality qualifiers in the source text ("appropriate" transparency, contestability "where appropriate") are implemented as real branches rather than flattened away. Fairness is anchored to the nine protected characteristics in the Equality Act 2010, and the report names which ones went untested.
- **UK financial services** (`industry_specific/bfs/v1/`, 2 policies). PRA SS1/23 model risk management across all five principles, with independent-validation recency proportionate to the assigned risk tier and vendor models in scope. FCA Consumer Duty (PRIN 2A) covering the three cross-cutting obligations, the four retail outcomes, plain-language explainability for customer-facing AI, and SM&CR named senior manager accountability. Neither regulator has AI-specific rules, so both policies test the existing obligations.
- **Legal services vertical** (`industry_specific/legal/v1/`, 3 policies). A new industry vertical: verification of AI-assisted citations before filing, client confidentiality and privilege in AI tools, and competence, supervision and client disclosure. Grounded in the SRA warning notice on misuse of AI, the BSB's May 2026 guidance, and the judiciary's guidance for judicial office holders.
- **[UK coverage matrix](docs/coverage/uk.md)**, including a table of where the UK regime diverges from the EU.
- READMEs for both new directories.

### Fixed
- **`international/nist/v1/ai_600_1`: closed a fail-open in the NIST AI RMF orchestrator.** `govern_compliant` used `object.get(input, "governance", {})` and then tested the result for existence. Because a defaulted `{}` is a defined value, the check succeeded even when the input carried no governance data at all, so an AI system with nothing recorded under `governance`, `transparency` or `fairness` was reported compliant. The orchestrator now delegates to the `govern`, `map`, `measure` and `manage` policies it already imported but never called, each of which carries its own `default allow := false`. This makes the four previously dead imports live and deletes the four shallow presence-only helper rules.

### Added
- **Hand-authored, theme-aware SVG diagrams** under [`diagrams/`](diagrams/) — paired `_light.svg` + `_dark.svg` for hero banner, hero numbers, directory tree, policy anatomy, and evaluation flow. Embedded via `<picture>` so GitHub light- and dark-theme readers each see the matching variant.
- **Brand assets** — standalone `logo_{light,dark}.svg` (hexagon + `{}` curly braces, signalling policy-as-code), `og_card_{light,dark}.svg` + a 1200×630 `og_card.png` for GitHub Settings → Social preview.
- **[`diagrams/STYLE.md`](diagrams/STYLE.md)** — design-system reference (palette, typography, shape language, light/dark pattern, contribution flow) shared with sister project AICertify.
- **[`CONTRIBUTING.md`](CONTRIBUTING.md)** — policy-authoring conventions, local-checks recipe, PR review criteria, and a "adding a new framework" guide. Resolves the broken link the README had been carrying.
- **[`SECURITY.md`](SECURITY.md)** — private vulnerability-disclosure flow at `security@principledevolution.ai`, 5-business-day acknowledgement, coordinated disclosure. Explicitly distinguishes security issues from policy-correctness disputes.
- **`AGENTS.md`** — new "Diagrams and visual assets" section pointing future agents at the SVG system and explicitly retiring the matplotlib generator.
- Previously (still in this Unreleased line): `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` operational instructions for AI coding agents; `skills/` directory with 3 Claude Code skills (`draft-rego-policy`, `explain-framework`, `add-framework`); comparison table vs generic OPA bundles and vendor governance SaaS in the README.

### Changed
- **CI now runs `opa test`.** The workflow ran `opa check` and `regal lint` but never executed the 226 policy tests in the repo, which is why the NIST fail-open above went unnoticed.
- **Top of README** — replaced the `<h1>GOPAL</h1>` + bold tagline with a hero banner SVG that bakes in the wordmark and value prop, tightening the top fold across all 5 language READMEs (en, zh-CN, ja-JP, ko-KR, hi-IN).
- README rewritten for product-page clarity: hero numbers, then quick start, then differentiation, then directory map.

### Removed
- **`diagrams/generate_diagrams.py`** — matplotlib generator retired. Hand-authored SVGs are now the source of truth; see [`diagrams/STYLE.md`](diagrams/STYLE.md) for how to add new ones.
- **`diagram4_framework_grid.png`** — the markdown comparison table directly below it does the same job; the embedded image was redundant.

## [1.0.0] — 2025-07

### Added
- **Aviation industry** (17 policies, 1,635+ LOC, 71+ passing tests): detect-and-avoid, certification, design standards, maintenance, flight readiness, communication systems, AI system integration validation, AI regulatory compliance validation.
- **Aviation standards frameworks**: RTCA DO-365, RTCA DO-366, ASTM F3442, ISO 21384.
- **Aviation regulators**: FAA Part 107, FAA Remote ID, EASA Regulation 2019/947, EASA SORA, ICAO Doc 10019.
- **Education industry** (12 policies): FERPA compliance, COPPA compliance, responsible AI proctoring, human-in-the-loop grading, data minimization, student opt-out, and others.
- **Automotive industry**: vehicle safety integration policy.
- **Brazil AI Governance Bill** policy.
- **India Digital Policy** scaffold.
- **NIST AI RMF**: Govern, Map, Measure, Manage + AI 600-1.
- `helper_functions/reporting.rego` — standardized report-output composition (`compose_report`, `is_valid_report`, validators).
- `helper_functions/validation.rego` — field-presence and required-field validators.
- `custom/` directory contract: local-only policies, git-ignored and CI-skipped.
- Disclaimer notices in every framework-level README.

### Changed
- All policies pass `opa check` and `regal lint` as a CI gate.
- Pre-commit hooks enforce OPA syntax and Regal style checks before commit.
- Standardized metadata annotations (`@title`, `@description`, `@version`, `@source`) on every policy.

### Fixed
- Numerous Regal lint violations across NIST and FERPA policy sets.
- `non-loop-expression` violations resolved by extracting boolean checks before loop iteration.
- `messy-rule` violations in FERPA compliance.
- OPA formatter (`opa fmt -w`) consistently applied.

## Earlier history

For changes prior to 1.0.0, see the [Git log](https://github.com/Principled-Evolution/gopal/commits/main).

[Unreleased]: https://github.com/Principled-Evolution/gopal/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Principled-Evolution/gopal/releases/tag/v1.0.0
