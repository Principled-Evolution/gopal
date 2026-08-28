# Example: NIST AI RMF (Govern function)

Evaluates an AI system's governance posture against the **Govern** function of the [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework).

Policy: [`international/nist/v1/govern`](../../international/nist/v1/govern).

## Run

```bash
./run.sh
```

Expected verdict, `allow: true` with all three sub-functions passing:

```json
{
  "allow": true,
  "accountability": { "allow": true, "msg": "Accountability requirements met." },
  "transparency":   { "allow": true, "msg": "Transparency requirements met." },
  "fairness":       { "allow": true, "msg": "Fairness requirements met." }
}
```

## What the policy checks

The Govern function in this policy composes three checks. **All three must pass**:

### Accountability
| Field | Required |
|---|---|
| `governance.roles_and_responsibilities_defined` | `true` |
| `governance.oversight_mechanisms_in_place` | `true` |

### Transparency
| Field | Required |
|---|---|
| `transparency.public_documentation_available` | `true` |
| `transparency.decision_explanations_provided` | `true` |

### Fairness
| Field | Required |
|---|---|
| `fairness.bias_assessments_conducted` | `true` |
| `fairness.bias_mitigation_strategies_in_place` | `true` |

## See it fail

Flip any of those booleans to `false` in [`input.json`](input.json) and re-run. The corresponding sub-function will return `{"allow": false, "msg": "... requirements not met."}` and the top-level `allow` will be `false`.

## Why this matters

The NIST AI RMF is the de-facto AI risk baseline for US federal procurement and increasingly for state and enterprise programs. The Govern function is the foundation. Without it, the Map / Measure / Manage functions cannot be relied on.

This example shows the minimum signal a governance team needs to encode: documented roles, documented oversight, documented transparency commitments, and documented bias-mitigation activities.

For Map / Measure / Manage functions, see [`international/nist/v1/`](../../international/nist/v1).
