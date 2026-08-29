#!/usr/bin/env bash
# Evaluate input.json against the NIST AI RMF Govern function.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"

opa eval \
  -d "$REPO_ROOT/international/nist/v1/govern" \
  -d "$REPO_ROOT/helper_functions" \
  --input "$HERE/input.json" \
  --format pretty \
  "data.international.nist.v1.govern"
