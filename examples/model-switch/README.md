# Example: a model change that fails the build

This example compares recorded toxicity metrics for a baseline and candidate
model while holding the prompts, scoring method, and policy fixed. The candidate
metrics cause the existing rule to fail, so CI blocks the merge.

The example runs in this repository's own CI on every push, so the badge on the
README reports the current state of the check rather than a recorded result.

## Run it

```bash
./check.sh outputs-baseline.json     # the model in production
./check.sh outputs-candidate.json    # candidate model
```

![Two runs of check.sh: the production model passes, the swapped model fails with the offending output named](../../docs/demo/model-switch.svg)

The baseline and candidate runs exit 0 and 1 respectively. In CI, those exit
codes produce a passing check and a blocked merge.

## What the example demonstrates

The enforcement mechanism is independent of the scoring implementation.
Detoxify supplies the toxicity metrics in this example; Perspective or another
evaluator can be substituted if it produces the input fields expected by the
policy.

The score is evaluated by **a rule that can be read, cited and versioned**, and
the same policy evaluation can run in each environment. The threshold is defined
in the policy rather than in this script: `params.toxicity_threshold` in
[`global/v1/toxicity`](../../global/v1/toxicity/toxicity.rego) defaults to 0.1,
so changing it requires a reviewed pull request.

**Aggregate metrics can mask individual outliers.** In this six-output example,
the aggregate toxicity score increases from 0.0056 to 0.1373 and exceeds its 0.1
threshold. The maximum toxicity score increases from 0.02 to 0.81 and exceeds
its 0.7 threshold. GOPAL keeps `metrics.toxicity.score` and
`metrics.toxicity.max_toxicity` separate because, in a larger suite, an
individual high-toxicity output may not cause the aggregate score to exceed its
threshold.

CI runs the policy evaluation automatically as a status check. A failing
evaluation therefore blocks the merge and keeps the applicable article and rule
in the pull-request review context.

## The numbers

`outputs-*.json` contain per-output toxicity scores recorded from Detoxify 0.5.2
over the same prompt suite. They are checked in so the example is deterministic
and needs no model download in CI.

This example does not execute either model. It starts after model outputs have
been generated and scored; the checked-in files represent the metrics presented
to the policy. This keeps CI deterministic while isolating the policy-enforcement
behavior. To generate equivalent metrics yourself, AICertify ships a
[Detoxify adapter](https://github.com/Principled-Evolution/aicertify/blob/main/docs/adapters.md)
that emits exactly this shape, or see
[supplying metrics](../../docs/tutorials/supplying-metrics.md) for the mapping
written as plain JSON.

## Wiring it into your own repository

`check.sh` needs `jq` and `opa` and nothing else. Point `--policy-dir` at a
GOPAL checkout or unpack a release bundle:

```bash
./check.sh scores.json --policy-dir /path/to/gopal --threshold 0.05
```

For a workflow you can copy, see
[`.github/workflows/model-switch-demo.yaml`](../../.github/workflows/model-switch-demo.yaml)
in this repository, or [`examples/github-actions`](../github-actions) for the
model-card equivalent.

## Which policies work like this

Five policies in the current library can be evaluated entirely from measured
metrics and are therefore suitable initial candidates for automated CI
enforcement:

| Policy | Reads | Supplied by |
| --- | --- | --- |
| [`global/v1/toxicity`](../../global/v1/toxicity/toxicity.rego) | `metrics.toxicity.score` | Detoxify, Perspective |
| [EU AI Act Article 11](../../international/eu_ai_act/v1/documentation/technical_documentation.rego) | `metrics.model_card.*` | a model card, scored by [`model_card_score`](../../global/v1/documentation/model_card_score.rego) |
| [`bfs` fair lending](../../industry_specific/bfs/v1/loan_evaluation/fair_lending.rego) | fairness, content safety, risk | Fairlearn |
| [`healthcare` diagnostic safety](../../industry_specific/healthcare/v1/diagnostic_safety/diagnostic_safety.rego) | the same three | Fairlearn |
| [`global/v1/fairness`](../../global/v1/fairness/fairness.rego) | toxicity, stereotype | Detoxify, LangFair |
