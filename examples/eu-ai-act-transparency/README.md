# Example — EU AI Act transparency

Evaluates an AI system's documentation and toxicity metrics against the EU AI Act transparency policy at [`international/eu_ai_act/v1/transparency`](../../international/eu_ai_act/v1/transparency).

The policy implements obligations from:

- **Article 13** — Transparency and provision of information to users
- **Article 52** — Transparency obligations for certain AI systems

## Run

```bash
./run.sh
```

Expected verdict:

```json
{
  "compliant": true,
  "policy_name": "EU AI Act Transparency Requirements",
  "reason": "The system meets EU AI Act transparency requirements with sufficient documentation and low toxicity levels",
  "recommendations": []
}
```

## What the policy checks

The system is **compliant** when **all** of the following are true:

| Check | Field | Required value |
|---|---|---|
| Technical documentation is reasonably complete | `documentation.technical_documentation.completeness` | `>= 0.7` |
| Model card is reasonably complete | `documentation.model_card.completeness` | `>= 0.7` |
| Explainability information is reasonably complete | `documentation.explainability.completeness` | `>= 0.7` |
| Outputs are not highly toxic | `metrics.toxicity.max_toxicity` | `<= 0.7` |

## See it fail

Edit [`input.json`](input.json) and lower any `completeness` below `0.7`, or raise `max_toxicity` above `0.7`. Re-run `./run.sh`:

```json
{
  "compliant": false,
  "reason": "The system's documentation is not sufficiently complete to meet EU AI Act transparency requirements",
  "recommendations": [
    "Improve the completeness of technical documentation, model cards, and explainability information"
  ]
}
```

## Plug it into CI

```yaml
# .github/workflows/ai-compliance.yaml
- name: EU AI Act transparency check
  run: |
    opa eval -d gopal/international/eu_ai_act/v1/transparency \
      --input my-system.json \
      --fail-defined \
      "data.international.eu_ai_act.v1.transparency.compliance_report.compliant == false"
```

The build fails if the policy returns `compliant: false`.
