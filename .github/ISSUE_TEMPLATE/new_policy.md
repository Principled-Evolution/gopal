---
name: New policy request
about: Propose adding a specific policy within an existing GOPAL framework
title: "[policy] "
labels: enhancement, new-policy
---

## Existing framework

Which directory does the new policy belong in? (e.g. `international/eu_ai_act/v1/`)

## What the policy should check

**Source article/section**: <!-- specific reference, e.g. "EU AI Act Article 13(2)" -->

**Plain-English rule**: <!-- describe what the policy must enforce -->

**Input shape it expects**: <!-- which `input.system.*` or `input.metrics[*]` fields drive the decision -->

```json
{
  "system": {
    "// example": "the structure your policy reads"
  }
}
```

## Test scenarios

At minimum:
- [ ] **Allow case**: when the input is compliant, the policy returns `allow == true`.
- [ ] **Deny case**: when a required field is missing or invalid, `allow == false`.

Any edge cases worth covering?

## Would you contribute?

- [ ] Yes — I'll open a PR.
- [ ] No — I'm flagging the gap.
