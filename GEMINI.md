# Gemini CLI: Project Context for GOPAL

> **Read [AGENTS.md](AGENTS.md) first.** This file inherits all of those instructions and adds Gemini-CLI-specific notes plus the author's general working principles.

## General Principles (carried over from the prior GEMINI.md)

1. Use **poetry** for Python package management, not pip. Prefer `poetry run python`, `poetry add`, `poetry update`.
2. **Be conservative and surgical.** Do not make more changes than are asked for.
3. **Confirm with the user** when in any doubt about the next steps. They are the senior partner.
4. You may ask the user to run commands and share outputs, or to make manual changes you can't accomplish reliably.
5. Always **critique your own design at least once** for elegance, DRY, KISS, and explainability before presenting it.
6. **Do not exceed 600 lines per file.**
7. When working across multiple repos, **always confirm you're in the correct git repo** for the current task, especially after `cd`.
8. When the session context gets too long, suggest updating memory, filing a GitHub issue, and continuing in a fresh session.
9. **When unable to authenticate** to an enabled integration (JIRA, Confluence, etc.), stop and ask the user to check authentication.

## What you're working on

**GOPAL** is an 85-policy Rego library for AI compliance covering EU AI Act, NIST RMF, aviation standards, FERPA/COPPA, fair lending, and more. See [README.md](README.md) for the full coverage table and [AGENTS.md](AGENTS.md) for the authoring conventions.

## Quick reference (Rego policy authoring)

Every new `.rego` file must include:

- **Package declaration** matching the directory path:
  ```rego
  package industry_specific.education.v1.student_data_privacy
  ```
- **Metadata annotations** (title, description, version, source):
  ```rego
  # @title Detailed FERPA Compliance
  # @description Evaluates data access requests against FERPA.
  # @version 1.1
  # @source https://www.ecfr.gov/current/title-34/subtitle-A/part-99
  ```
- **Default rule**: usually `default allow := false`.
- **Clear deny messages** via `deny[msg]` where applicable.
- A sibling **`_test.rego`** file covering both compliant and non-compliant scenarios.
- A framework-level **README.md** at each `international/<framework>/v1/` or `industry_specific/<industry>/v1/` with the source link and a "not legal advice" disclaimer.

## CI gates (must pass)

```bash
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

If Regal flags an issue, look it up in the [Regal rule catalog](https://docs.styra.com/regal/rules). Use web search for hints on fixing specific lint violations.

## Sister project

[AICertify](https://github.com/Principled-Evolution/aicertify) consumes GOPAL as its policy library. A new framework added here is automatically available there on next vendor sync.
