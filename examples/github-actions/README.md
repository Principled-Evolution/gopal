# Example: AI compliance as a GitHub status check

Runs a GOPAL policy against a model card on every pull request and fails the build when the system is non-compliant.

This is the piece that makes "AI compliance checks that run in CI" concrete: a required status check that a non-compliant change cannot merge past.

## Files

| File | What it is |
| --- | --- |
| [`workflow.yaml`](workflow.yaml) | The GitHub Actions workflow. Copy to `.github/workflows/ai-compliance.yaml` in your repo |
| [`check-compliance.sh`](check-compliance.sh) | Runs the evaluation and sets the exit code. Copy alongside it |
| [`model-card.json`](model-card.json) | A compliant example document |
| [`model-card-failing.json`](model-card-failing.json) | The same document with documentation completeness dropped below the threshold |

## Try it locally

Build the bundles first, or download one from a release:

```bash
../../scripts/build-bundles.sh
BUNDLE=../../dist/gopal-international-eu_ai_act-1.2.0.tar.gz

./check-compliance.sh --bundle "$BUNDLE" \
  --package international.eu_ai_act.v1.transparency \
  --input model-card.json
```

```
COMPLIANT: data.international.eu_ai_act.v1.transparency.allow against model-card.json
{
  "compliant": true,
  "policy_name": "EU AI Act Transparency Requirements",
  "reason": "The system meets EU AI Act transparency requirements with sufficient documentation and low toxicity levels",
  "recommendations": []
}
```

Exit code `0`, so the step passes and the check goes green.

Now the failing document:

```bash
./check-compliance.sh --bundle "$BUNDLE" \
  --package international.eu_ai_act.v1.transparency \
  --input model-card-failing.json
```

```
::error::NON-COMPLIANT: data.international.eu_ai_act.v1.transparency.allow returned false for model-card-failing.json
{
  "compliant": false,
  "policy_name": "EU AI Act Transparency Requirements",
  "reason": "The system's documentation is not sufficiently complete to meet EU AI Act transparency requirements",
  "recommendations": [
    "Improve the completeness of technical documentation, model cards, and explainability information"
  ]
}

Reason: The system's documentation is not sufficiently complete to meet EU AI Act transparency requirements

Recommendations:
  1. Improve the completeness of technical documentation, model cards, and explainability information
```

Exit code `1`. In Actions the `::error::` line becomes an annotation on the pull request, so the reviewer sees the reason and the remediation inline on the **Files changed** tab rather than having to open the log.

## Dropping it into your own repo

1. Copy `workflow.yaml` to `.github/workflows/ai-compliance.yaml` and `check-compliance.sh` next to it, or anywhere the workflow can reach.
2. Point it at your own document. The four values at the top of the workflow are the only ones you normally change:

   ```yaml
   env:
     GOPAL_VERSION: '1.2.0'
     GOPAL_FRAMEWORK: 'international-eu_ai_act'
     POLICY_PACKAGE: 'international.eu_ai_act.v1.transparency'
     INPUT_FILE: 'model-card.json'
   ```

   `GOPAL_FRAMEWORK` is a bundle name from the [releases page](https://github.com/Principled-Evolution/gopal/releases), for example `international-uk`, `industry_specific-bfs`, or `industry_specific-legal`. `POLICY_PACKAGE` must be a package inside that bundle.

3. Make it a required check: **Settings → Branches → Branch protection rules → Require status checks to pass**, then select **AI Compliance**.

To find the package and the fields a policy expects:

```bash
jq -r '.frameworks[] | select(.id == "international/eu_ai_act") | .policies[]
       | "\(.package)\n  needs: \(.required_metrics | join(", "))"' \
  ../../docs/coverage/coverage.json
```

## Checking several policies

Call the script once per policy. Each sets its own exit code, and `set -e` in the step stops at the first failure. To report all of them instead:

```yaml
- name: Evaluate all EU AI Act policies
  run: |
    failed=0
    for pkg in \
      international.eu_ai_act.v1.transparency \
      international.eu_ai_act.v1.human_oversight \
      international.eu_ai_act.v1.technical_robustness
    do
      ./check-compliance.sh --bundle policy-bundle.tar.gz \
        --package "$pkg" --input model-card.json || failed=1
    done
    exit $failed
```

## Notes on the design

**The bundle checksum is verified before use.** This bundle decides whether a release can ship, so the workflow downloads the release's `checksums.txt` and compares before evaluating.

**Undefined is not a pass.** The script distinguishes three outcomes: compliant (exit 0), non-compliant (exit 1), and failed-to-evaluate (exit 2). In Rego an undefined value is not `false`, so a policy that reached no verdict has told you nothing. Collapsing that into "not a failure" is how a compliance pipeline starts reporting green while checking nothing.

**The report is uploaded even when the build fails**, via `if: always()`. The artifact is the evidence that the check ran and what it decided, which is the thing an auditor asks for.
