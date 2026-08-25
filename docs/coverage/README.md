# Policy coverage matrices

This directory documents, per framework, **which obligations are encoded in GOPAL** and **which are not yet**.

The matrices are deliberately honest. A policy is only marked **Implemented** when the Rego rule actually validates input fields against the regulation's requirement. Many directories ship a **Scaffold** that establishes the package path and a `default allow := false` placeholder — useful as a starting point for contributors, not yet enforceable.

## Available matrices

- [EU AI Act](eu-ai-act.md) — Regulation (EU) 2024/1689
- [NIST AI RMF](nist-ai-rmf.md) — NIST Special Publication 1270 + AI 600-1
- [UK AI governance](uk.md) — the five pro-innovation principles, UK GDPR Articles 22A-22D, and UK financial services (PRA SS1/23, FCA Consumer Duty)

## Implemented, matrix not yet written

These frameworks already have real policies in the repo (not scaffolds); nobody has written the per-obligation matrix for them yet. Good first contribution if you want to help without writing Rego.

- India Digital Policy — `international/india/v1/`
- Brazil AI Governance Bill — `international/brazil/v1/`
- FERPA / COPPA (education) — `industry_specific/education/v1/`
- Healthcare AI safety — `industry_specific/healthcare/v1/`
- BFS — fair lending, model risk — `industry_specific/bfs/v1/`
- Legal services AI — `industry_specific/legal/v1/`
- ICAO Doc 10019, FAA Part 107/Remote ID, EASA 2019/947/SORA, RTCA DO-365, ISO 21384 — `international/icao/`, `international/faa/`, `international/easa/`, `international/standards/`
- Aviation industry-vertical policies (airworthiness, autonomous systems, data management, flight operations) — `industry_specific/aviation/v1/`

## Coming soon

Nothing implemented yet.

- UK AI principles (pro-innovation framework)
- India DPDP Act (distinct from the Digital India Policy above)
- California SB-1047 successor
- MAS / HKMA banking AI guidance

If you want to help expand coverage for a framework, open an issue or send a PR. The matrices are the best place to start — they show contributors exactly which articles, controls, or sections are still open.

## Reading a matrix

Each row is one obligation, control, or article in the source regulation. Columns:

| Column | Meaning |
|---|---|
| **Obligation** | The regulator's name for the requirement (article number, control ID, etc.) |
| **GOPAL policy** | Path to the Rego package that encodes it |
| **Status** | `Implemented` / `Scaffold` / `Planned` |
| **Notes** | What the rule checks, or what's missing |

`Implemented` rules are safe to run in CI and produce structured verdicts. `Scaffold` rules return placeholder denials — they exist so the package path is stable while the logic is fleshed out. `Planned` means there's no file yet.
