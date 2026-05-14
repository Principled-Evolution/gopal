#!/usr/bin/env bash
# Evaluate input.json against the education responsible AI proctoring policy.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

opa eval \
  -d "$REPO_ROOT/industry_specific/education/v1/assessment_and_evaluation" \
  --input "$HERE/input.json" \
  --format pretty \
  "{
    \"compliant\": data.industry_specific.education.v1.assessment_and_evaluation.responsible_ai_proctoring_compliant,
    \"deny_reasons\": data.industry_specific.education.v1.assessment_and_evaluation.deny
  }"
