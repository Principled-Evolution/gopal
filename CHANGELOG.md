# Changelog

All notable changes to **GOPAL** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). See [COMPATIBILITY.md](docs/COMPATIBILITY.md) for the versioning model applied to individual policy directories.

## [Unreleased]

Nothing yet.

## [1.3.1]: 2026-08-28

### Fixed

- **`international/eu_ai_act/v1/transparency` cited the wrong Article.** The policy referenced "Article 52 of the EU AI Act, Transparency obligations for certain AI systems". In the adopted Regulation, Article 52 is "Procedure", the GPAI systemic-risk notification, and transparency obligations for certain systems are Article 50. The same repository cites Article 52(1) correctly for GPAI notification in `gpai/systemic_risk_classification`, so both citations sat side by side.

  The correction is not a rename. The policy scores documentation completeness and a toxicity threshold, which is not a test of Article 50 either: Article 50 governs disclosure to natural persons and deepfake marking. It now cites Article 13 alone. The coverage matrix had also claimed Article 50 as implemented on one row while listing it as not implemented on another; the false row is removed, and the Article 13 row is downgraded from a tick to a warning noting that Article 13 requires instructions for use containing specified content, and a completeness score is a proxy for that rather than a test of it. Claimed coverage goes down.

- **`industry_specific/education/v1/student_data_privacy/ferpa_compliance`: consent was a placeholder.** The rule checked a status flag and a scope list. 34 CFR §99.30 requires written consent to be signed and dated by the parent or eligible student and to specify the records, the purpose, and the party receiving them. In practice a consent permitting a transcript to go to a named university for admissions also cleared sending that transcript to a data broker for marketing, because neither purpose nor recipient was ever read. All four elements are now checked, each in its own named helper, and the function is total.

- **Two vacuous-truth fail-opens in the same file.** Both allow branches iterated `input.data_requested` with `every`, and `every` over an empty collection is true, so a request for no records at all was approved by both the consent branch and the directory-information branch. Both now require a non-empty request.

- **The README hero banner said 96 policies above a panel saying 91.** The count is 91: seven of the 98 Rego files define no decision rule and are libraries the real policies import. A previous correction pass updated the README tree and the translations but missed text baked into `diagrams/hero_banner_{light,dark}.svg` and the `<desc>` in `diagrams/diagram1_hero_numbers_{light,dark}.svg`, which is what a screen reader announces.

### Added

- **`scripts/extract-input-fields.sh`** derives the `input` fields each policy reads from its AST rather than from a hand-written comment. The comment block had drifted to the point where 22 of 98 policies read `input` and declared nothing at all, so anything asking "what does this policy need?" got an empty answer. It recognises the `object.get(input, ["a","b"], default)` form, used 284 times here, and infers each field's kind from the literal the policy measures it against. The comment block stays and the two are unioned: a field name computed in a loop cannot be recovered from the AST.

- **`scripts/check-test-coverage.sh`**, run in CI, fails the build when a policy has no sibling test or no empty-input test. Every policy has had both since v1.3.0; this makes it a gate rather than a snapshot. The gap it prevents had reached 22 of 96 policies, including both Article 5 prohibited-practice policies, and an external reviewer demonstrated it by flipping `default allow := false` to `true` in the social-scoring gate without the suite going red.

- **`scripts/model-card-coverage.sh` and `docs/model-cards-vs-compliance.md`** measure how far a standard Hugging Face model card gets you against the 184 declared inputs the shipped checks read: 5 directly, 24 partially, 155 not prompted for. The classification is data with a written reason per field, the counts are computed, and CI fails if it goes stale.

- **`CITATION.cff` and `.zenodo.json`.** GitHub now offers a "Cite this repository" button, and a published release is archived with a DOI.

### Changed

- **OPA and Regal are pinned in CI**, and now in the release workflow too. Both installed `latest`, so an upstream release could change the build with no change here, and on 2026-08-28 one did: OPA 1.20.0 panics with `illegal value` on any ordering comparison against a decimal zero, which four shared helpers in `global/v1/common` use as a score fallback. `opa test` aborted with exit code 2 across the whole suite rather than failing a test. Reported upstream as [open-policy-agent/opa#9099](https://github.com/open-policy-agent/opa/pull/9099) with a fix; raise the pin when that ships.

- **`scripts/check-version-refs.sh` also checks published counts** against the generated coverage data, covering both hero banners, both diagram descriptions, the README policy sentence, `CITATION.cff` and the README BibTeX block.

## [1.3.0]: 2026-08-27

### Fixed
- **`global/v1/common/fairness`: a biased system produced no verdict at all.** `gender_bias_detected(_) := false` and `racial_bias_detected(_) := false` were written as plain rules, so each was a third complete definition of the function rather than a fallback. Any input that satisfied one of the real rules produced both `true` and `false`, OPA raised `eval_conflict_error`, and evaluation aborted. `international/eu_ai_act/v1/eu_fairness` therefore returned nothing, not a denial, for exactly the systems it exists to catch. Both are now `default` functions. This survived because the `eu_fairness` tests mock the two helpers they depend on, so the real functions were never exercised.
- **`international/eu_ai_act/v1/eu_fairness`: closed a fail-open on unmeasured toxicity.** `default toxicity_below_threshold := true` asserted that toxicity was acceptable whenever the check did not affirmatively pass. `content_safety.toxicity_below_threshold` is a partial rule and is undefined both when `metrics.content_safety.score` is absent and when the score fails the threshold, so both cases resolved to `true`. An input of `{"metrics": {}}` was reported compliant with Articles 10 and 15, and so was a system measured at 0.9 toxicity. The default is now `false`, and the threshold is read through the nested `object.get` form so a missing `input.params` cannot make the whole call undefined.

  An empty-input test does not catch this. With no input at all the bias defaults deny first and the toxicity path is never reached; it takes a partially populated input, which is now a named test.
- **`industry_specific/bfs/v1/loan_evaluation/fair_lending`: closed the third instance of the same fail-open.** No `default is_compliant := false`, and each score compared directly rather than through a defaulted lookup. On an empty input `is_compliant` was undefined rather than false and `failed_evaluations` came back empty, so a loan model with no evidence at all reported that nothing had failed. This is the defect already fixed in `healthcare/v1/diagnostic_safety` in 1.1.0, and it is fixed the same way.
- Corrected a typo in user-facing report output: `transparency` reported "requirements withsufficient documentation".

### Added
- **Per-framework OPA bundles, attached to every release.** Consuming just the EU AI Act meant vendoring the whole tree, because `opa build -b international/eu_ai_act` does not compile: every framework imports `helper_functions` and `global/v1/common`. [`scripts/build-bundles.sh`](scripts/build-bundles.sh) stages each framework with the libraries it needs and produces a self-contained bundle that evaluates with no other GOPAL files present. 19 framework bundles plus `gopal-all`, with a sha256 checksums file. The EU AI Act bundle is 24K against 56K for the whole library.

  An import scan confirms the shared libraries are the only cross-directory dependency, so the staging is complete rather than merely sufficient for the cases tried. Each bundle is loaded back during the build and asked for a real decision, so one that has lost a file it needed fails at build time rather than in a user's CI.
- **A GitHub Actions example that fails the build on non-compliance** ([`examples/github-actions/`](examples/github-actions)). Downloads a framework bundle, verifies its checksum, evaluates a model card, and annotates the pull request with the reason and remediation. It distinguishes compliant, non-compliant, and failed-to-evaluate, because a policy that reached no verdict has told you nothing and folding that into "not a failure" is how a compliance pipeline reports green while checking nothing.
- **Generated coverage data** at [`docs/coverage/coverage.json`](docs/coverage/coverage.json), produced from the `.rego` files by [`scripts/generate-coverage.sh`](scripts/generate-coverage.sh) and checked in CI. For every policy it records the package, title, references, decision rules, the `RequiredMetrics` and `RequiredParams` it declares, and whether it has a test and an empty-input test. The hand-maintained matrices had drifted in every direction at once, and this makes that impossible.
- **A version-reference check** ([`scripts/check-version-refs.sh`](scripts/check-version-refs.sh)), also in CI. 1.2.0 shipped a README telling people to `gh release download v1.2.0 --pattern 'gopal-*.tar.gz'` against a release that had no assets, because the bundle workflow did not exist when that tag was cut. The instruction was dead on arrival and nothing caught it.

### Changed
- **Every policy now has a sibling test, and every policy that reaches a verdict is tested against empty input.** It was 75 of 98 files. All 86 top-level decision rules were probed against `{}` first and every one already denied, so that property is now held by test rather than by luck. The suite goes from 604 to 769.

  The four shared libraries in `global/v1/common` and `helper_functions` have tests for the first time. They document the fallback *direction* of each helper, which is what makes the toxicity defect above legible: `toxicity_score` returns `0.0` for input it cannot read, which is the permissive answer, while `fairness_score` and `risk_score` also return `0.0`, which is the denying one.
- **The policy count is 91, not 96.** Seven files define no boolean rule with an explicit default, so they reach no verdict; they are libraries the real policies import. Counting them as policies overstated coverage. Corrected in the README tree, the hero diagram, `pyproject.toml`, and all four translated READMEs, which had also fallen behind at 96 policies and 146 Rego files against the English 91 and 196.
- Roadmap: dropped "California SB-1047 successor", which was vetoed with no successor pending, and added EU GDPR scoped to the articles an input document can actually evidence rather than the whole regulation. Most of GDPR describes organisational practice no input can evidence, so encoding it wholesale would produce declared booleans. The evaluable intersection is Article 22 and Recital 71, Article 35 DPIA triggers, Article 9, Articles 5(1)(c) and 5(1)(e), Articles 13 and 14, and Article 25. The UK counterpart to the Article 22 regime is already implemented, and the two have diverged.
- `opa check` and `opa test` now pass `--ignore dist`, since building bundles locally left tarballs that `opa test` tried to load as data documents.

## [1.2.0]: 2026-08-25

### Changed
- **Every EU AI Act obligation is now implemented.** 22 of the 29 policies in `international/eu_ai_act/v1/` were stubs: `allow := false` with a "not yet implemented" message and no reference to `input` at all, while the headline policy count and the coverage matrix both counted them. All 22 now check concrete fields and carry sibling tests. The matrix has no ⚠️ Scaffold rows left.

  The implementations encode the conditional structure of the Articles rather than flattening it:
  - **Article 5 prohibitions** are cumulative. 5(1)(b) needs a recognised vulnerability basis *and* behavioural distortion *and* significant harm. 5(1)(d) carves out systems supporting a human assessment grounded in objective verifiable facts, and both halves are required. 5(1)(e) turns on untargeted collection, not on facial recognition. 5(1)(g) exempts dataset labelling and law enforcement. 5(1)(h) admits a closed list of objectives, and Article 5(3) still requires prior authorisation on top of one.
  - **Article 26** deployer duties are partly conditional: 26(7) on workplace deployment, 26(11) on the system affecting natural persons, and 26(4) only to the extent the deployer controls the input data.
  - **Article 43** allows internal control for Annex III point 1 systems only where the harmonised standards were applied.
  - **Article 48** requires a digitally accessible marking for a digital-only system and the notified body number where one was involved.
  - **Article 49(2)** requires a provider claiming the Article 6(3) exemption to register that assessment, which is the limb most likely to be overlooked entirely.
  - **Article 53(2)** open-source exemption reaches the technical documentation and downstream information duties only, falls away completely for a systemic risk model, and never touches the copyright policy or training content summary.
  - **Article 51(2)** systemic risk presumption at cumulative training compute above 10^25 FLOPs, with Article 52(1) notification and the four Article 55 obligations tested separately.
- **The README hero leads with domains rather than counts.** The policy and framework count badges are gone from all five READMEs, and the subtitle names the frameworks people actually search for. A user looking for FCA or SRA coverage cares whether their domain is covered, not how many policies exist in total.

### Fixed
- Test coverage: policies without a sibling test file went from 44 to 22. The remaining gap is almost entirely `industry_specific/education/v1/`.

## [1.1.0]: 2026-08-25

### Changed
- **All seven placeholder policies are now real implementations.** They were counted in the headline policy total while returning an unconditional denial and carrying `"status": "PLACEHOLDER"`, which overstated coverage. Each now checks concrete input fields, reports which controls failed, and has a sibling test file:
  - `international/eu_ai_act/v1/prohibited_practices/manipulation` now encodes the Article 5(1)(a) prohibition as the cumulative test it actually is. All three limbs (a subliminal, purposefully manipulative or deceptive technique; material distortion of behaviour; significant harm caused or reasonably likely) must be met before the practice is prohibited, so Recital 29 lawful persuasion is not caught.
  - `industry_specific/bfs/v1/model_risk` now covers the SR 11-7 and OCC 2011-12 pillars plus BCBS 239 data lineage, with review cadence scaled to the assigned risk rating. It is the US counterpart to `uk_ss1_23_model_risk`.
  - `industry_specific/healthcare/v1/patient_safety` now tests its declared score thresholds together with the clinician-in-the-loop and adverse-event-reporting controls FDA Good Machine Learning Practice expects.
  - `operational/corporate/v1/governance`, `operational/corporate/v1/infosec`, `operational/aiops/v1/scalability` and `operational/cost/v1/resource_efficiency` now check real operational controls. The infosec policy tests two AI-specific ones: secrets managed outside prompts and context windows, and prompt-injection controls where untrusted input reaches a model.
- **Line endings normalised, with a `.gitattributes`.** Eight `.rego` files were stored with CRLF, so running `opa fmt` on any of them rewrote every line and produced a whole-file diff with no content change. `opa fmt` is now a no-op across the repo.

### Fixed
- **`industry_specific/healthcare/v1/diagnostic_safety`: closed a fail-open.** `allow` returned true for an input carrying no evaluation scores at all. The threshold helpers dereferenced `input.evaluation.<score>` directly, so a missing score made both the `_eval_fails` and `_passes` rules undefined; the array builders keyed off `not _eval_fails`, which then held, and the metric dropped silently out of `failed_evaluations`. With all three absent the list was empty and a diagnostic AI system with no safety evidence evaluated to allow. Both the score and threshold lookups now use the nested `object.get` form, so an absent score fails its threshold and an absent `params` object no longer makes the comparison itself undefined.

### Added
- **UK AI governance framework** (`international/uk/v1/`, 6 policies). The five cross-sectoral principles from the pro-innovation white paper (CP 815), plus the automated decision-making regime in UK GDPR Articles 22A to 22D as substituted by section 80 of the Data (Use and Access) Act 2025, in force 5 February 2026. Two things are encoded that a naive reading would miss: the principles are non-statutory and are labelled as such, and the proportionality qualifiers in the source text ("appropriate" transparency, contestability "where appropriate") are implemented as real branches rather than flattened away. Fairness is anchored to the nine protected characteristics in the Equality Act 2010, and the report names which ones went untested.
- **UK financial services** (`industry_specific/bfs/v1/`, 2 policies). PRA SS1/23 model risk management across all five principles, with independent-validation recency proportionate to the assigned risk tier and vendor models in scope. FCA Consumer Duty (PRIN 2A) covering the three cross-cutting obligations, the four retail outcomes, plain-language explainability for customer-facing AI, and SM&CR named senior manager accountability. Neither regulator has AI-specific rules, so both policies test the existing obligations.
- **Legal services vertical** (`industry_specific/legal/v1/`, 3 policies). A new industry vertical: verification of AI-assisted citations before filing, client confidentiality and privilege in AI tools, and competence, supervision and client disclosure. Grounded in the SRA warning notice on misuse of AI, the BSB's May 2026 guidance, and the judiciary's guidance for judicial office holders.
- **[UK coverage matrix](docs/coverage/uk.md)**, including a table of where the UK regime diverges from the EU.
- READMEs for both new directories.

### Fixed
- **`international/nist/v1/ai_600_1`: closed a fail-open in the NIST AI RMF orchestrator.** `govern_compliant` used `object.get(input, "governance", {})` and then tested the result for existence. Because a defaulted `{}` is a defined value, the check succeeded even when the input carried no governance data at all, so an AI system with nothing recorded under `governance`, `transparency` or `fairness` was reported compliant. The orchestrator now delegates to the `govern`, `map`, `measure` and `manage` policies it already imported but never called, each of which carries its own `default allow := false`. This makes the four previously dead imports live and deletes the four shallow presence-only helper rules.

### Added
- **Hand-authored, theme-aware SVG diagrams** under [`diagrams/`](docs/diagrams): paired `_light.svg` + `_dark.svg` for hero banner, hero numbers, directory tree, policy anatomy, and evaluation flow. Embedded via `<picture>` so GitHub light- and dark-theme readers each see the matching variant.
- **Brand assets**: standalone `logo_{light,dark}.svg` (hexagon + `{}` curly braces, signalling policy-as-code), `og_card_{light,dark}.svg` + a 1200×630 `og_card.png` for GitHub Settings → Social preview.
- **[`diagrams/STYLE.md`](docs/diagrams/STYLE.md)**: design-system reference (palette, typography, shape language, light/dark pattern, contribution flow) shared with sister project AICertify.
- **[`CONTRIBUTING.md`](.github/CONTRIBUTING.md)**: policy-authoring conventions, local-checks recipe, PR review criteria, and a "adding a new framework" guide. Resolves the broken link the README had been carrying.
- **[`SECURITY.md`](.github/SECURITY.md)**: private vulnerability-disclosure flow at `security@principledevolution.ai`, 5-business-day acknowledgement, coordinated disclosure. Explicitly distinguishes security issues from policy-correctness disputes.
- **`AGENTS.md`**: new "Diagrams and visual assets" section pointing future agents at the SVG system and explicitly retiring the matplotlib generator.
- Previously (still in this Unreleased line): `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` operational instructions for AI coding agents; `skills/` directory with 3 Claude Code skills (`draft-rego-policy`, `explain-framework`, `add-framework`); comparison table vs generic OPA bundles and vendor governance SaaS in the README.

### Changed
- **CI now runs `opa test`.** The workflow ran `opa check` and `regal lint` but never executed the 226 policy tests in the repo, which is why the NIST fail-open above went unnoticed.
- **Top of README**: replaced the `<h1>GOPAL</h1>` + bold tagline with a hero banner SVG that bakes in the wordmark and value prop, tightening the top fold across all 5 language READMEs (en, zh-CN, ja-JP, ko-KR, hi-IN).
- README rewritten for product-page clarity: hero numbers, then quick start, then differentiation, then directory map.

### Removed
- **`diagrams/generate_diagrams.py`**: matplotlib generator retired. Hand-authored SVGs are now the source of truth; see [`diagrams/STYLE.md`](docs/diagrams/STYLE.md) for how to add new ones.
- **`diagram4_framework_grid.png`**: the markdown comparison table directly below it does the same job; the embedded image was redundant.

## [1.0.0]: 2025-07

### Added
- **Aviation industry** (17 policies, 1,635+ LOC, 71+ passing tests): detect-and-avoid, certification, design standards, maintenance, flight readiness, communication systems, AI system integration validation, AI regulatory compliance validation.
- **Aviation standards frameworks**: RTCA DO-365, RTCA DO-366, ASTM F3442, ISO 21384.
- **Aviation regulators**: FAA Part 107, FAA Remote ID, EASA Regulation 2019/947, EASA SORA, ICAO Doc 10019.
- **Education industry** (12 policies): FERPA compliance, COPPA compliance, responsible AI proctoring, human-in-the-loop grading, data minimization, student opt-out, and others.
- **Automotive industry**: vehicle safety integration policy.
- **Brazil AI Governance Bill** policy.
- **India Digital Policy** scaffold.
- **NIST AI RMF**: Govern, Map, Measure, Manage + AI 600-1.
- `helper_functions/reporting.rego`: standardized report-output composition (`compose_report`, `is_valid_report`, validators).
- `helper_functions/validation.rego`: field-presence and required-field validators.
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

[Unreleased]: https://github.com/Principled-Evolution/gopal/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/Principled-Evolution/gopal/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/Principled-Evolution/gopal/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Principled-Evolution/gopal/releases/tag/v1.0.0
