# Plugging your evaluator into GOPAL

GOPAL is a Rego library. It takes one JSON document and returns compliance
verdicts. Nothing about that requires a particular language, framework or
vendor: if your tool can write JSON and you can run `opa`, you can use GOPAL.

This tutorial builds that integration from scratch, with no dependencies beyond
the `opa` binary. [AICertify](https://github.com/Principled-Evolution/aicertify)
automates the same thing in Python if you would rather not hand-roll it, and
there is a note at the end on when that trade is worth making.

## The two kinds of input

Every GOPAL policy reads some mixture of:

**Declared facts.** Things a person asserts about an organisation or a system.
Was a conformity assessment completed. Can a human intervene in an automated
decision. Was the CE marking affixed. Nobody can compute these; somebody signs
them. Most obligations in the EU AI Act are of this kind.

**Measured metrics.** Things a tool computes. A toxicity score, a fairness
disparity, a model-card completeness score. You cannot assert these honestly,
and a policy that reads one you never supply can never be satisfied.

Supplying declared facts is a matter of writing them into the input document.
The rest of this tutorial is about the measured half, because that is the part
that needs a tool behind it.

## 1. Find out what a policy reads

Ask the policy, not the documentation:

```bash
scripts/extract-input-fields.sh international/eu_ai_act/v1/documentation/technical_documentation.rego
```

```
metrics.model_card.completeness
metrics.model_card.compliance_level
metrics.model_card.quality
metrics.model_card.section_scores
params
params.completeness_threshold
params.quality_threshold
```

This is derived from the parsed policy, not from its comment block, because
comment blocks drift. Pass as many files as you like.

Anything under `params.` is a threshold you may override and can otherwise
ignore. Everything else is input you are expected to supply.

## 2. Use the canonical name

The same number used to be read under several names. Content safety had six
spellings. [`helper_functions/metrics.rego`](../../helper_functions/metrics.rego)
fixes the canonical name as `metrics.<domain>.<name>` and keeps every historical
spelling working as a fallback:

```rego
"metrics.toxicity.score": [
	["metrics", "toxicity", "score"],
	["evaluation", "toxicity_score"],
	["content_safety", "toxicity_score"],
],
```

Supply the canonical name. The legacy ones still resolve, so old inputs keep
working, but new code should not add to the pile.

Two entries in that table are worth reading twice:

```rego
"metrics.toxicity.score":        # an aggregate, compared against 0.1
"metrics.toxicity.max_toxicity": # the single worst output, compared against 0.7
```

They are different statistics and are deliberately not merged. Feed a
worst-case maximum into a 0.1 threshold and almost any real system fails, which
does not make the check stricter, it makes it useless and ignored.

## 3. Write the document

Your evaluator's job is to produce JSON. Nothing more:

```json
{
  "metrics": {
    "model_card": {
      "completeness": 0.86,
      "quality": 0.81,
      "compliance_level": 0.9,
      "section_scores": {
        "intended_use": 0.9,
        "training_data": 0.85,
        "evaluation_data": 0.6
      }
    }
  }
}
```

## 4. Evaluate

```bash
opa eval -d international/eu_ai_act/v1/documentation/technical_documentation.rego \
         -d helper_functions/ \
         -i input.json \
         'data.international.eu_ai_act.v1.documentation.technical_documentation'
```

```
completeness_sufficient    = true
quality_sufficient         = true
compliance_level_acceptable = true
missing_sections           = ["evaluation_data"]
```

`missing_sections` came back populated even though the document passed, which
is the point of the library: the verdict and the reasons are separate outputs.

Two flags matter when you scale this up. Pass `-d helper_functions/` or the
canonical name lookup is not loaded. And if you point `-d` at the repository
root, add `--ignore '*.json' --ignore '*.yaml' --ignore '*.yml'`, because OPA
will otherwise try to load every data file in the tree and fail with a merge
error that looks nothing like its cause.

## 5. Fail a build with it

```yaml
- name: Compliance gate
  run: |
    ok=$(opa eval -d gopal/international/eu_ai_act/v1 \
                  -d gopal/global -d gopal/helper_functions \
                  -i metrics.json --format raw \
                  'data.international.eu_ai_act.v1.documentation.technical_documentation.completeness_sufficient')
    [ "$ok" = "true" ] || { echo "documentation completeness below threshold"; exit 1; }
```

Read the value and test it, rather than reaching for `--fail` or
`--fail-defined`. Those turn on whether a result is *defined*, and `false` is
perfectly well defined, so a policy that denies exits 0 and the gate waves the
build through. They are the right flags for a `deny` set that is empty when
compliant, and the wrong ones for a boolean.

Note the third `-d`. The EU AI Act policies import `global/v1/common`, so
omitting `-d global` fails with `undefined function
data.global.v1.common.fairness.gender_bias_detected` rather than anything about
a missing directory.

A worked repository is in
[`examples/github-actions`](../../examples/github-actions).

## Two things that will bite you

**Absent is not zero.** If your evaluator could not compute a metric, leave it
out. Do not emit `0.0`.

In Rego an undefined value is not `false` and it is not `0`. GOPAL relies on
that: `resolve` returns undefined for a metric nobody supplied, which is a
different statement from "measured, came out at zero". On a scale where lower
is better, a zero default reports an unmeasured system as perfectly clean, and
the policy will believe you.

Where a policy needs absence to be a definite failure it says so explicitly,
with a sentinel that compares below every threshold:

```rego
score(name, fallback) := metrics.resolve_or(input, sprintf("metrics.%v.score", [name]), fallback)

patient_safety_met if {
	score("patient_safety", -1) >= threshold("patient_safety_threshold", 0.95)
}
```

That `-1` is deliberate. It fails closed and stays counted, rather than
dropping out of the assessment as an undefined comparison.

**Say which direction your number points, and which statistic it is.** A safety
score where higher is better and a toxicity score where higher is worse are not
interchangeable. GOPAL's `is_toxic` once answered `true` for one of the safest
possible systems because they had been treated as if they were. An average and
a maximum are likewise different questions, which is why the two toxicity
entries above exist separately.

## Some metrics should not come from a tool

Not everything measurable is measurable by you.

`metrics.patient_safety.score` is gated at 0.95 and is meant to be a clinical
measurement. It would be easy to write something that counts how many safety
fields a document contains and publishes the result under that name. Do not: a
system with complete paperwork would score 1.0 and clear a patient-safety gate
it was never assessed against. Supply that number from the clinical evaluation
that actually produced it, or leave it absent and let the policy fail closed.

The rule of thumb is that the name has to describe what you measured. If it
does not, you are not closing a gap, you are hiding one.

## If you would rather not build this

Everything above is the manual path, and it is a supported one: a shell script
that writes JSON and calls `opa` is a complete GOPAL integration.

[AICertify](https://github.com/Principled-Evolution/aicertify) does the same
work in Python and takes the boilerplate off you: contract scaffolding
(`aicertify init-contract`), a report of which metrics your policies need and
which of your evaluators supply them, a base class with the plumbing already
written, and the merge that puts your measurements where the policies read
them. Its
[evaluator guide](https://github.com/Principled-Evolution/aicertify/blob/main/docs/writing-an-evaluator.md)
is the same story told in Python.

Use it if you want the scaffolding. Skip it if you already have an evaluation
pipeline and just need a compliance verdict out of the other end. GOPAL does
not know or care which you chose.

## See also

- [Add your first GOPAL policy](add-your-first-policy.md)
- [`helper_functions/metrics.rego`](../../helper_functions/metrics.rego)
- [Runnable examples](../../examples/README.md)
