# Claude Code: Project Context for GOPAL

> **Read [AGENTS.md](AGENTS.md) first.** This file inherits all of those instructions and only adds Claude Code-specific notes.

## What you're working on

**GOPAL** is a 92-policy Rego library for AI compliance. The user evaluates inputs (model cards, AI-system metadata, eval results) against named regulations (EU AI Act, NIST RMF, aviation standards, FERPA/COPPA, etc.) and gets back structured compliance verdicts.

## Fast orientation

When the user asks about the codebase, in order:

1. **For "what frameworks are covered?"** → read the top-level `README.md` table.
2. **For "how is a policy structured?"** → look at a representative one: `international/eu_ai_act/v1/transparency.rego` (with its `_test.rego` sibling).
3. **For "what helpers exist?"** → `helper_functions/reporting.rego` and `helper_functions/validation.rego`.
4. **For "how does CI work?"** → `.github/workflows/opa-ci.yaml`: it runs `opa check` and `regal lint`.

## Conventions Claude Code should respect

- **Use TodoWrite** for multi-step tasks (the user's preferred tracking).
- **Run both gates** before claiming a change is done:
  ```bash
  opa check --ignore custom/ --ignore dist .
  regal lint --ignore-files custom/ .
  ```
- **Don't bypass Regal warnings** by adding ignores to `.regal/config.yaml`: fix the underlying issue, or document the exception in the PR.
- **Tests are mandatory**. Every new `*.rego` needs a `*_test.rego` in the same directory.
- **Metadata block** at the top of every policy is part of the spec, so don't elide it.

## Useful skills

This project ships Claude Code skills in [`docs/skills/`](docs/skills). To register them:

```bash
mkdir -p ~/.claude/skills && cp -r docs/skills/* ~/.claude/skills/
```

Available slash commands once registered:

- `/draft-rego-policy`: Scaffold a new policy with full metadata, default rule, reporting helper integration, and a sibling test file
- `/explain-framework`: Walk every policy in a framework directory (e.g. `international/eu_ai_act/v1`) and produce an audit-grade plain-English summary
- `/add-framework`: Bootstrap a brand-new regulatory framework directory (README + seed policy + test)

See [`docs/skills/README.md`](docs/skills/README.md) for details.

## What NOT to do in this repo

- Don't auto-format Rego files with anything other than what Regal recommends; it has style opinions.
- Don't add `import` statements without using the imported symbol, because Regal flags this.
- Don't introduce Python tooling beyond what's in `pyproject.toml`. The Python presence here is for packaging the Rego files as a wheel; the actual logic lives in `.rego`.
- Don't refactor the `helper_functions/` library without checking every policy that imports it.

## Session etiquette

The author prefers terse, surgical responses. Present the plan first when ambiguous; ask before introducing new abstractions.
