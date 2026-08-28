# GOPAL Documentation

> **Looking for an overview?** Start with the [README](../README.md): it covers what's inside, the comparison vs generic OPA bundles and vendor SaaS, and how policies are authored.

Organized along [Diátaxis](https://diataxis.fr/) lines.

## 🎓 Tutorials: your first GOPAL evaluation

- [Quick Start in the README](../README.md#quick-start): standalone `opa eval`, or via AICertify.
- [Add your first GOPAL policy](tutorials/add-your-first-policy.md): write a working policy + test + CI check in 20 minutes.
- [Runnable examples](../examples/README.md): `examples/` with input/output pairs for EU AI Act, NIST AI RMF, and customer-support LLM.
- [Add a brand-new regulatory framework](skills/add-framework/SKILL.md) (Claude Code skill): bootstraps the directory tree, framework README, and first policy.
- [FAQ](FAQ.md): comprehensive Q&A on what GOPAL is, when to use it, and how to extend it.

## 🛠️ How-To Guides: solve a specific problem

- [Author a new Rego policy](skills/draft-rego-policy/SKILL.md) (Claude Code skill): scaffolds policy + test + metadata.
- [Summarize what a framework's policies enforce](skills/explain-framework/SKILL.md) (Claude Code skill): audit-grade plain-English walkthrough.
- [Develop org-private policies in `custom/`](../README.md#custom-policies): git-ignored, CI-skipped local extensions.

## 📚 Reference: look up specific names

- [Policy coverage matrices](coverage): per-framework view of what's Implemented / Scaffold / Planned.
- [Coverage table](../README.md#whats-inside): every framework with its policy count.
- [helper_functions/reporting.rego](../helper_functions/reporting.rego): `compose_report()`, validators.
- [helper_functions/validation.rego](../helper_functions/validation.rego): `field_exists()`, `validate_required_fields()`.
- [.regal/config.yaml](../.regal/config.yaml): linter exclusions.
- [pyproject.toml](../pyproject.toml): Python packaging metadata.
- [COMPATIBILITY.md](COMPATIBILITY.md): the versioning model (`v1/`, `v2/`, …).
- [CHANGELOG](../CHANGELOG.md): release history.

## 💡 Explanation: understand the design

- [Why GOPAL?](../README.md#why-gopal): the differentiation argument.
- [AGENTS.md](../AGENTS.md): strict authoring conventions; required reading before contributing a policy.
- [Authoring a policy](../README.md#authoring-policies): the anatomy of a Rego file in this project.

## 🤝 Contributing & community

- [CONTRIBUTING.md](../.github/CONTRIBUTING.md)
- [Issues](https://github.com/Principled-Evolution/gopal/issues)
- [Consumer: AICertify](https://github.com/Principled-Evolution/aicertify): the Python framework that runs GOPAL.
