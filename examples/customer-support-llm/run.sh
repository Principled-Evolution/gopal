#!/usr/bin/env bash
# Evaluate input.json against the global toxicity policy.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

opa eval \
  -d "$REPO_ROOT/global/v1/toxicity" \
  -d "$REPO_ROOT/helper_functions" \
  --input "$HERE/input.json" \
  --format pretty \
  "data.global.v1.toxicity.compliance_report"
