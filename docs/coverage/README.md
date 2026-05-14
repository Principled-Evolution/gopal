# Policy coverage matrices

This directory documents, per framework, **which obligations are encoded in GOPAL** and **which are not yet**.

The matrices are deliberately honest. A policy is only marked **Implemented** when the Rego rule actually validates input fields against the regulation's requirement. Many directories ship a **Scaffold** that establishes the package path and a `default allow := false` placeholder — useful as a starting point for contributors, not yet enforceable.

## Available matrices

- [EU AI Act](eu-ai-act.md) — Regulation (EU) 2024/1689
- [NIST AI RMF](nist-ai-rmf.md) — NIST Special Publication 1270 + AI 600-1

## Coming soon

- UK AI principles (pro-innovation framework)
- India / DPDP Act
- Brazil AI Governance Bill
- ICAO Doc 10019 (aviation)
- FERPA / COPPA (education)
- Healthcare AI safety
- BFS — fair lending, model risk

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
