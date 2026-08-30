# Example: a model change that fails the build

This example changes the model behind a support assistant while holding the
prompts, the classifier and the policy fixed. Under those conditions one rule
reaches a different verdict and the merge stops.

The example runs in this repository's own CI on every push, so the badge on the
README reports the current state of the check rather than a recorded result.

## Run it

```bash
./check.sh outputs-baseline.json     # the model in production
./check.sh outputs-candidate.json    # after the swap
```

![Two runs of check.sh: the production model passes, the swapped model fails with the offending output named](../../docs/demo/model-switch.svg)

The two runs exit 0 and 1 respectively, which in CI is a passing check and a
blocked merge.

## What the example demonstrates

The classifier is incidental. Detoxify scoring text is routine, and substituting
Perspective or another model changes nothing here.

The score is judged by **a rule that can be read, cited and versioned**, and the
same evaluation runs in every environment. The threshold lives in the policy
rather than in this script: `params.toxicity_threshold` in
[`global/v1/toxicity`](../../global/v1/toxicity/toxicity.rego) defaults to 0.1,
so changing it requires a reviewed pull request.

**One bad answer among many is invisible in an average.** The regression here is
a single output out of six. The aggregate moves from 0.0056 to 0.1373, which is
enough to cross 0.1, but the worst output moves from 0.02 to 0.81. GOPAL keeps
`metrics.toxicity.score` and `metrics.toxicity.max_toxicity` apart and compares
them against 0.1 and 0.7 for exactly this reason. Reporting only the mean over a
larger suite conceals that output entirely.

**The check does not depend on anyone remembering to run it.** The gate is a
status check, so the review happens on the pull request, with the article and
the rule attached.

## The numbers

`outputs-*.json` carry per-output toxicity scores recorded from Detoxify 0.5.2
over the same prompt suite. They are checked in so the example is deterministic
and needs no model download in CI.

This is a limitation worth stating: the example does not run a model. It begins
after a model has been run and scored, which is the state a policy actually
observes. To produce the numbers yourself, AICertify ships a
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

Most of the EU AI Act is declarations a person signs, and no tool can measure
whether a conformity assessment happened. Five policies in the library run
entirely on measured metrics, and these are the ones worth automating first:

| Policy | Reads | Supplied by |
| --- | --- | --- |
| [`global/v1/toxicity`](../../global/v1/toxicity/toxicity.rego) | `metrics.toxicity.score` | Detoxify, Perspective |
| [EU AI Act Article 11](../../international/eu_ai_act/v1/documentation/technical_documentation.rego) | `metrics.model_card.*` | a model card, scored by [`model_card_score`](../../global/v1/documentation/model_card_score.rego) |
| [`bfs` fair lending](../../industry_specific/bfs/v1/loan_evaluation/fair_lending.rego) | fairness, content safety, risk | Fairlearn |
| [`healthcare` diagnostic safety](../../industry_specific/healthcare/v1/diagnostic_safety/diagnostic_safety.rego) | the same three | Fairlearn |
| [`global/v1/fairness`](../../global/v1/fairness/fairness.rego) | toxicity, stereotype | Detoxify, LangFair |
