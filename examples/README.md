# GOPAL Examples

Runnable, copyable examples of evaluating an AI system against a GOPAL policy.

Each example contains:

- `input.json`: a sample AI-system payload (the thing being evaluated)
- `run.sh`: invokes `opa eval` against a GOPAL policy with that input
- `expected-output.json`: what the verdict should look like
- `README.md`: what the example shows and how to adapt it

## Prerequisites

You need [OPA](https://www.openpolicyagent.org/docs/latest/#running-opa) on your PATH:

```bash
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 \
  && chmod +x opa && sudo mv opa /usr/local/bin/
```

## Examples

| Example | Framework | Policy | Verdict |
|---|---|---|---|
| [`eu-ai-act-transparency/`](eu-ai-act-transparency/) | EU AI Act | `international.eu_ai_act.v1.transparency` | passing |
| [`nist-ai-rmf-govern/`](nist-ai-rmf-govern/) | NIST AI RMF | `international.nist.v1.govern` | passing |
| [`customer-support-llm/`](customer-support-llm/) | Global content-safety | `global.v1.toxicity` | passing |
| [`education-proctoring/`](education-proctoring/) | Education (FERPA-aligned) | `industry_specific.education.v1.assessment_and_evaluation.responsible_ai_proctoring` | passing |

Each `run.sh` is a one-liner you can copy into CI. To see a non-compliant verdict, edit `input.json` (e.g., lower a completeness score below `0.7`, flip a governance boolean to `false`) and run again.

## Want a new example?

Open an issue with the framework and use case, or send a PR following the layout above. Examples should be:

- self-contained (no external services)
- runnable with `opa eval` only
- minimal: one policy, one input, one verdict
