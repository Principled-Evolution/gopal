# Policy coverage matrices

This directory documents, per framework, **which obligations are encoded in GOPAL** and **which are not yet**.

The matrices record status conservatively. A policy is only marked **Implemented** when the Rego rule actually validates input fields against the regulation's requirement. Many directories ship a **Scaffold** that establishes the package path and a `default allow := false` placeholder, useful as a starting point for contributors but not yet enforceable.

## Test coverage

Every policy has a sibling test file and asserts that its decision denies an empty input, as [CONTRIBUTING.md](../../.github/CONTRIBUTING.md) requires. That is now a CI gate rather than a convention: [`scripts/check-test-coverage.sh`](../../scripts/check-test-coverage.sh) fails the build if a policy has no test, or has one without an empty-input assertion. The seven libraries under `global/v1/common/` and `helper_functions/` are exempt, since they define helpers rather than decisions and have no `allow` to hand an empty input to.

The CI gate exists because the convention alone was insufficient. When it was introduced, 22 of the 96 files counted as policies had no test, including both Article 5 prohibited-practice policies. An external review demonstrated the consequence: changing `default allow := false` to `default allow := true` in the untested social-scoring policy still left the aggregate suite reporting 604/604. The aggregate test count therefore did not establish per-policy coverage.

The exact figures live in [`coverage.json`](coverage.json) under `totals`. They are regenerated from the `.rego` files and verified in CI, keeping the reported totals synchronized with the policy tree:

```bash
jq .totals docs/coverage/coverage.json
```

Writing a test that does not yet exist for a *case* rather than a file is still one of the most useful contributions available, and it needs no new Rego logic. Two patterns are worth copying:

- **Empty input.** `not policy.allow with input as {}`. In Rego an undefined value is not `false`, so a missing `default` or an undefined intermediate rule can let a system with no evidence pass.
- **One required metric absent at a time.** This is stronger than an empty-input test because it exercises partial-input paths. The most recent fail-open occurred on such a path: a policy whose bias defaults correctly denied an empty input still approved a system whose toxicity had never been measured because that metric defaulted to a permissive answer.

A policy without a test is not necessarily wrong. It is unverified, which is a different claim from the ✅ marks below.

## Available matrices

- [EU AI Act](eu-ai-act.md): Regulation (EU) 2024/1689
- [NIST AI RMF](nist-ai-rmf.md): NIST Special Publication 1270 + AI 600-1
- [UK AI governance](uk.md): the five pro-innovation principles, UK GDPR Articles 22A-22D, and UK financial services (PRA SS1/23, FCA Consumer Duty)

## Implemented, matrix not yet written

These frameworks already have real policies in the repo rather than scaffolds; the per-obligation matrix for them has not been written yet. Writing one is a good first contribution and requires no Rego.

- India Digital Policy: `international/india/v1/`
- Brazil AI Governance Bill: `international/brazil/v1/`
- FERPA / COPPA (education): `industry_specific/education/v1/`
- Healthcare AI safety: `industry_specific/healthcare/v1/`
- BFS fair lending and model risk: `industry_specific/bfs/v1/`
- Legal services AI: `industry_specific/legal/v1/`
- ICAO Doc 10019, FAA Part 107/Remote ID, EASA 2019/947/SORA, RTCA DO-365, ISO 21384: `international/icao/`, `international/faa/`, `international/easa/`, `international/standards/`
- Aviation industry-vertical policies (airworthiness, autonomous systems, data management, flight operations): `industry_specific/aviation/v1/`

## Coming soon

Nothing in this section is implemented yet. The UK pro-innovation principles were previously listed here; they now have six policies and a [matrix](uk.md).

- India DPDP Act (distinct from the Digital India Policy above)
- MAS / HKMA banking AI guidance
- ICO statutory code of practice on AI and automated decision-making
- EU GDPR, scoped to the articles that bear on an AI system rather than the whole regulation. Most of GDPR describes organisational practice that no input document can evidence, so encoding it wholesale would produce declared booleans rather than checks. The evaluable intersection is Article 22 and Recital 71, Article 35 DPIA triggers, Article 9 special category data, Articles 5(1)(c) and 5(1)(e), Articles 13 and 14, and Article 25. The UK equivalent of the Article 22 regime is already implemented, and the two have diverged.

If you want to help expand coverage for a framework, open an issue or send a PR. The matrices are the best place to start, because they show contributors exactly which articles, controls, or sections are still open.

## coverage.json

[`coverage.json`](coverage.json) is generated by [`scripts/generate-coverage.sh`](../../scripts/generate-coverage.sh) and holds, for every policy: its package, title, references, decision rules, the `RequiredMetrics` and `RequiredParams` it declares, and whether it has a test and an empty-input test. CI fails if it is out of date, providing a mechanical consistency check against the policy tree.

It exists because the coverage matrices were previously hand-maintained and had drifted from the policy tree. The generated file makes that relationship mechanically checkable. Use it to answer questions the prose cannot:

```bash
# Which policies need a metric I do not yet collect?
jq -r '.frameworks[].policies[] | select(.required_metrics | index("metrics.content_safety.score")) | .path' docs/coverage/coverage.json

# Everything GOPAL encodes for one framework, with the articles it cites
jq -r '.frameworks[] | select(.id == "international/eu_ai_act") | .policies[] | "\(.title): \(.references | join("; "))"' docs/coverage/coverage.json
```

## Reading a matrix

Each row is one obligation, control, or article in the source regulation. Columns:

| Column | Meaning |
|---|---|
| **Obligation** | The regulator's name for the requirement (article number, control ID, etc.) |
| **GOPAL policy** | Path to the Rego package that encodes it |
| **Status** | `Implemented` / `Scaffold` / `Planned` |
| **Notes** | What the rule checks, or what's missing |

`Implemented` rules contain executable validation logic and produce structured verdicts suitable for CI evaluation. `Scaffold` rules return placeholder denials; they exist so the package path is stable while the logic is fleshed out. `Planned` means there's no file yet.
