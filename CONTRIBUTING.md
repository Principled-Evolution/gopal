# Contributing to GOPAL

Thanks for considering a contribution. GOPAL is an open, community-curated library of [OPA](https://www.openpolicyagent.org/) Rego policies encoding AI-governance requirements; the more eyes on each rule, the better the policies get.

## What we welcome

- **New policies** for an existing framework (e.g. an additional EU AI Act article)
- **New frameworks** (e.g. UK AI Principles, California SB-1047 successor, MAS banking AI guidance)
- **New industry verticals** (e.g. media, energy, defence)
- **Fixes** for bugs in existing policy logic
- **Tests.** Every policy should have a sibling `*_test.rego`. Missing tests on existing policies are open invitations.
- **Translations.** The README ships in 5 languages, and a native speaker's review of any of them helps a lot.
- **Documentation** improvements (CONTRIBUTING, README, AGENTS, STYLE)

## Before you open a PR

1. **Open or check an issue first.** For new frameworks or larger additions, a quick "I'm planning to add X" comment avoids duplicate work.
2. **Run the same checks CI runs.** See [Development](#development) below.
3. **Match the existing policy shape.** Every policy file follows the same structure (package, imports, METADATA, default deny, allow rule, report). See [diagrams/diagram3_policy_anatomy_light.svg](diagrams/diagram3_policy_anatomy_light.svg) and any existing `.rego` for the canonical pattern.
4. **Add a test sibling.** A new `foo.rego` needs a `foo_test.rego` covering both allow and deny cases.
5. **Update [CHANGELOG.md](CHANGELOG.md)** under `[Unreleased]` with a one-line entry describing your change.

## Development

```bash
# One-time setup
pip install pre-commit
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 \
  && chmod +x opa && sudo mv opa /usr/local/bin/
curl -L -o regal https://github.com/StyraInc/regal/releases/latest/download/regal_Linux_x86_64 \
  && chmod +x regal && sudo mv regal /usr/local/bin/
pre-commit install

# Run the checks CI runs
opa check --ignore custom/ --ignore dist .
regal lint --ignore-files custom/ .

# Run tests for a specific package
opa test international/eu_ai_act/v1/
```

If `opa check` fails it usually means a typo in a package path or an undeclared rule. If `regal lint` fails, run with `--format pretty` for human-readable advice on the issue.

## Policy authoring conventions

- **Package path mirrors the directory.** `international/eu_ai_act/v1/transparency.rego` declares `package international.eu_ai_act.v1.transparency`.
- **Default deny.** Every policy starts with `default allow := false` so a missing rule produces a safe (deny) result, never an accidental allow.
- **Metadata comments.** Use `# METADATA` followed by `# title:` and `# description:` so the rule is human-readable in audit reports.
- **Report composition.** Use `data.helper_functions.reporting.compose_report(...)` to produce the standardized output shape rather than rolling your own report dict. The helper guarantees the field names auditors expect.
- **Versioning.** New frameworks go under `<framework>/v1/`. When a regulation amends, the old `v1/` stays put and a new `v2/` ships alongside. See [COMPATIBILITY.md](COMPATIBILITY.md).
- **Reference data needed?** Add it as a constant inside the policy or under a sibling `_data.rego`. Avoid runtime dependencies on external services.

## Adding a new framework

The fastest path:

1. Decide where it goes: `international/`, `industry_specific/`, `global/`, or `operational/`.
2. `mkdir <category>/<framework>/v1/`
3. Drop in a first policy that follows the standard shape. The [`draft-rego-policy`](skills/draft-rego-policy/SKILL.md) skill scaffolds this for you under Claude Code.
4. Add a test sibling.
5. Update the README count + add a row under "What's Inside".
6. Open a PR.

## PR review

PRs are reviewed for:

1. **Correctness.** Does the policy logic accurately encode the regulation?
2. **Test coverage.** Does the test cover both allow and deny? Any edge cases?
3. **Style.** Are `opa check` and `regal lint` clean? Does it match existing patterns?
4. **Scope.** One concern per PR, which makes it easier to revert.

We aim to respond within 5 business days. Larger framework additions may take longer if the regulator's text needs verification.

## Custom policies

The `custom/` directory is `.gitignore`d and skipped by CI. That is where your organization's proprietary rules go. They evaluate alongside the public set without ever being pushed to this repo. See the [README's Custom Policies section](README.md#custom-policies).

## Community

- **Questions and integration help.** Use the [integration help form](https://github.com/Principled-Evolution/gopal/issues/new?template=integration_help.yml), open a [Q&A discussion](https://github.com/Principled-Evolution/gopal/discussions/new?category=q-a), or email **gopal@principledevolution.ai**. We don't assume any Rego or OPA experience.
- **Requesting coverage.** Open a [new framework](https://github.com/Principled-Evolution/gopal/issues/new?template=new_framework.yml) or [new policy](https://github.com/Principled-Evolution/gopal/issues/new?template=new_policy.yml) request. You don't have to write the Rego to ask for it.
- **Security disclosures.** See [SECURITY.md](SECURITY.md). Please don't file public issues for vulnerabilities.
- **Code of conduct.** Participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). The short version: argue about the policy rather than the person, cite the regulation you're relying on, and assume good faith across jurisdictions and languages. Report concerns to **conduct@principledevolution.ai**.

## License

By contributing, you agree your contributions will be licensed under the [Apache License 2.0](LICENSE), the same license as GOPAL itself.
