# GOPAL Claude Code Skills

This directory ships [Claude Code](https://docs.claude.com/en/docs/claude-code/) skills for working with GOPAL. Each subdirectory contains a `SKILL.md` file that Claude Code can invoke as a slash command.

## Available skills

| Skill | What it does |
|---|---|
| [`draft-rego-policy`](draft-rego-policy/SKILL.md) | Scaffold a new Rego policy with full metadata, default rule, reporting helper integration, and a sibling test file |
| [`explain-framework`](explain-framework/SKILL.md) | Walk every policy in a framework directory and produce an audit-grade plain-English summary |
| [`add-framework`](add-framework/SKILL.md) | Bootstrap a brand-new regulatory framework directory (README + seed policy + test) |

## Installation

```bash
# From the repo root
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

Restart Claude Code. The skills appear as slash commands:

```
/draft-rego-policy international eu_ai_act new_transparency_rule
/explain-framework international/eu_ai_act/v1
/add-framework international uk_ai_principles https://www.gov.uk/...
```
