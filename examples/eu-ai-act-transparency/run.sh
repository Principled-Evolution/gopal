#!/usr/bin/env bash
# Evaluate input.json against the EU AI Act transparency policy.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

opa eval \
  -d "$REPO_ROOT/international/eu_ai_act/v1/transparency" \
  -d "$REPO_ROOT/helper_functions" \
  --input "$HERE/input.json" \
  --format pretty \
  "data.international.eu_ai_act.v1.transparency.compliance_report"
