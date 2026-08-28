# Security Policy

## Reporting a vulnerability

If you find a security issue in GOPAL, please **do not file a public issue**. Email **security@principledevolution.ai** with:

- A description of the issue
- Steps to reproduce
- The version (commit SHA or release tag) where you observed it
- Your assessment of severity (CVSS 3.1 if you have it)

We aim to acknowledge within **5 business days**. We follow a coordinated-disclosure approach: we'll work with you on a fix and a disclosure timeline before any public announcement.

## What's in scope

- **CI / workflow vulnerabilities** in `.github/workflows/` (command injection, secret leakage, untrusted-input handling)
- **Supply-chain issues** in `pyproject.toml` (the Python distribution metadata that ships GOPAL as a package), or in the installer scripts in `CONTRIBUTING.md` / `README.md`
- **Helper-function bugs** in `helper_functions/*.rego` that could be exploited to bypass policy checks
- **Documentation issues** that would lead a reader to a less-secure configuration

## What's NOT in scope

- **Policy correctness disputes.** If you think a specific Rego rule is too strict, too lax, or misinterprets a regulation, please file a **public issue** rather than emailing security. That's a policy-design discussion, not a vulnerability, and is best done in the open with the community.
- **The regulations themselves.** GOPAL encodes published regulatory frameworks (EU AI Act, NIST AI RMF, and so on). Concerns about the underlying regulation belong with the regulator that issued it.
- **Generic OPA / Rego issues.** Please report those to [open-policy-agent/opa](https://github.com/open-policy-agent/opa) or [open-policy-agent/regal](https://github.com/open-policy-agent/regal) directly.

## Supported versions

GOPAL ships under semver (see [COMPATIBILITY.md](../docs/COMPATIBILITY.md)). Security fixes are applied to:

- The current `main` branch
- The current `vN/` directory under each framework

Older versioned policy directories (`v1/` once `v2/` ships) are treated as frozen reference artefacts and will not receive security updates. If your deployment pins to an older policy version, plan to migrate.

## Public attribution

We are happy to credit reporters in the changelog and release notes unless you ask us not to.

---

This policy will evolve as the project grows. Last reviewed: 2026-05.
