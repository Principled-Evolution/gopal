# Example: Education AI proctoring

Evaluates a remote-proctoring AI system against the [`responsible_ai_proctoring`](../../industry_specific/education/v1/assessment_and_evaluation/responsible_ai_proctoring.rego) policy. The policy enforces a minimum due-process and privacy baseline that's broadly aligned with FERPA, COPPA, ETS guidance, and state-level AI-proctoring rules.

## Run

```bash
./run.sh
```

Expected verdict:

```json
{
  "compliant": true,
  "deny_reasons": []
}
```

## What the policy checks

The session is **compliant** only when **all** of the following are true:

| Check | Field | Required |
|---|---|---|
| Student consent | `proctoring_session.student_consent_given` | `true` |
| Data encrypted | `proctoring_session.data_handling.encryption_enabled` | `true` |
| Bounded retention | `proctoring_session.data_handling.data_retention_period_days` | `<= 30` |
| Human review of every flag | `proctoring_session.review_process.human_review_required_for_all_flags` | `true` |
| Student appeal possible | `proctoring_session.review_process.student_appeal_possible` | `true` |

## See it fail

Flip any of those fields and re-run `./run.sh`. The policy returns a `deny_reasons` array citing which check failed:

```json
{
  "compliant": false,
  "deny_reasons": [
    "AI proctoring session is not compliant. Failures: {\"Lack of human review or appeals process\"}"
  ]
}
```

The deny messages compose, so flipping multiple fields at once produces a multi-failure verdict.

## Why this matters

AI proctoring is one of the highest-scrutiny consumer-facing AI use cases. The risks are concrete:

- **Privacy**: webcam + microphone + screen capture is highly sensitive
- **Due process**: a flagged student needs a path to challenge the AI's decision
- **Bias**: facial-detection failure rates differ across demographics
- **Consent**: implicit consent in an enrollment agreement is not the same as informed consent for AI surveillance

This policy encodes the minimum signal a university or ed-tech vendor's compliance team needs to demonstrate. It's the floor, not the ceiling. Most institutions will want stricter retention windows and broader bias evaluations on top.

## Plug it into your eval pipeline

```yaml
# .github/workflows/proctoring-compliance.yaml
- name: AI proctoring compliance check
  run: |
    opa eval \
      -d gopal/industry_specific/education/v1/assessment_and_evaluation \
      --input proctoring-session.json \
      --fail-defined \
      "data.industry_specific.education.v1.assessment_and_evaluation.responsible_ai_proctoring_compliant == false"
```

The build fails if any session in your pipeline lacks consent, leaks encryption, retains too long, skips human review, or lacks an appeals process.

## Related policies

| Concern | Policy |
|---|---|
| Student data privacy (FERPA / COPPA) | [`industry_specific/education/v1/student_data_privacy/`](../../industry_specific/education/v1/student_data_privacy) |
| Academic integrity | [`industry_specific/education/v1/academic_integrity/`](../../industry_specific/education/v1/academic_integrity) |
| Fair and equitable treatment | [`industry_specific/education/v1/fairness_and_equity/`](../../industry_specific/education/v1/fairness_and_equity) |
