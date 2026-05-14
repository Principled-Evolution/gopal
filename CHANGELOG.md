# Changelog

All notable changes to **GOPAL** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). See [COMPATIBILITY.md](COMPATIBILITY.md) for the versioning model applied to individual policy directories.

## [Unreleased]

### Added
- Centered HTML hero, ordered badge wall, three big-number value-prop cards, and 5 programmatically-generated marketing diagrams in the README (hero numbers, directory tree, policy anatomy, framework grid, evaluation flow).
- `AGENTS.md` and `CLAUDE.md` — operational instructions for AI coding agents working in this repository. `GEMINI.md` refreshed to inherit from `AGENTS.md` while preserving the author's working principles.
- `skills/` directory with 3 Claude Code skills: `draft-rego-policy`, `explain-framework`, `add-framework`. Each ships as a slash command once installed into `~/.claude/skills/`.
- Comparison table vs generic OPA bundles and vendor governance SaaS in the README.
- `diagrams/generate_diagrams.py` — reproducible matplotlib script that regenerates every marketing PNG.

### Changed
- README rewritten for product-page clarity: hero numbers, then quick start, then differentiation, then directory map.

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
