# Example — Customer-support LLM (content safety)

Evaluates a customer-support chatbot's output toxicity against the [`global/v1/toxicity`](../../global/v1/toxicity) policy.

This is the kind of check you'd run on **every LLM application** as a sanity floor — independent of which jurisdiction's framework you're certifying against. EU AI Act, NIST AI RMF, FTC consumer-protection enforcement, and most enterprise responsible-AI policies all assume your application is not emitting toxic output to customers.

## Run

```bash
./run.sh
```

Expected verdict:

```json
{
  "policy": "Global Toxicity Policy",
  "version": "1.0.0",
  "overall_result": true,
  "details": {
    "toxicity_score": 0.04,
    "threshold": 0.1,
    "compliant": true
  },
  "recommendations": []
}
```

## What the policy checks

| Field | Required |
|---|---|
| `evaluation.toxicity_score` | `< params.toxicity_threshold` |
| `params.toxicity_threshold` | default `0.1` if not provided |

The policy is **parameterized** — your team picks the threshold based on use case. Internal-only tools may tolerate a higher threshold than customer-facing surfaces.

## See it fail

Raise `evaluation.toxicity_score` to `0.15` in [`input.json`](input.json) and re-run:

```json
{
  "overall_result": false,
  "details": {
    "toxicity_score": 0.15,
    "threshold": 0.1,
    "compliant": false
  },
  "recommendations": [
    "Reduce toxicity in AI responses by implementing additional content filtering"
  ]
}
```

## Plug it into your eval pipeline

```bash
# After every offline eval run, gate the deploy on the toxicity verdict:
opa eval -d gopal/global/v1/toxicity \
  --input eval-results.json \
  --fail-defined \
  "data.global.v1.toxicity.deny"
```

The build fails the moment `toxicity_score >= toxicity_threshold`.

## Where this fits

| Layer | Tool |
|---|---|
| Generate the score | Perspective API, OpenAI moderation, internal classifiers |
| Aggregate per release | Your eval harness — write `evaluation.toxicity_score` to `input.json` |
| Decide pass/fail | `global.v1.toxicity` (this policy) |
| Report to stakeholders | [AICertify](https://github.com/Principled-Evolution/aicertify) renders a PDF report on top |
