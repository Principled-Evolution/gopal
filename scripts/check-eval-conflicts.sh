#!/usr/bin/env bash
#
# Evaluate every policy package as a whole and fail on an evaluation-time error.
#
# opa check and opa test both passed while three education policies delivered no
# verdict at all. equitable_admissions_systems.rego and
# unbiased_automated_grading.rego share the package
# industry_specific.education.v1.fairness_and_equity, and each defined a complete
# rule named `thresholds` with a different value. OPA raises
#
#   eval_conflict_error: complete rules must not produce multiple outputs
#
# which fails the whole package, so all three policies in it returned nothing.
#
# Neither existing gate could see it. `opa check` is static and the conflict is
# an evaluation-time condition. `opa test` queries individual rules, and the
# conflict only arises when both definitions are evaluated together, which is
# what happens when the package itself is queried. A consumer queries
# `data.<package>`, so the gap between how this library tests itself and how it
# is actually used is where the defect lived.
#
# This closes that gap: it asks each package the same question a consumer asks.
#
# Usage: scripts/check-eval-conflicts.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

COVERAGE="docs/coverage/coverage.json"
[ -f "${COVERAGE}" ] || { echo "error: ${COVERAGE} not found. Run scripts/generate-coverage.sh." >&2; exit 1; }

EMPTY="$(mktemp)"
trap 'rm -f "${EMPTY}"' EXIT
echo '{}' >"${EMPTY}"

# Empty input, deliberately. A conflict between two complete rules is a property
# of the rules, not of the input, and empty input keeps this fast and stable.
# It is also the input under which a policy must still reach a defined default.
DATA_DIRS=(-d global -d international -d industry_specific -d operational -d helper_functions)

packages="$(jq -r '.frameworks[].policies[]? | select(.is_library | not) | .package' "${COVERAGE}" | sort -u)"
total="$(printf '%s\n' "${packages}" | wc -l | tr -d ' ')"
echo "Evaluating ${total} policy packages for evaluation-time errors."

failures=0
while IFS= read -r pkg; do
	[ -n "${pkg}" ] || continue
	if ! out="$(opa eval -f pretty "${DATA_DIRS[@]}" -i "${EMPTY}" "data.${pkg}" 2>&1)"; then
		echo "  FAIL ${pkg}" >&2
		printf '%s\n' "${out}" | head -3 | sed 's/^/         /' >&2
		failures=$((failures + 1))
		continue
	fi
	# opa eval reports some evaluation errors on stdout with a zero exit status.
	if printf '%s' "${out}" | grep -qE 'eval_conflict_error|eval_type_error|rego_type_error'; then
		echo "  FAIL ${pkg}" >&2
		printf '%s\n' "${out}" | grep -E 'eval_conflict_error|eval_type_error|rego_type_error' | head -2 | sed 's/^/         /' >&2
		failures=$((failures + 1))
	fi
done <<<"${packages}"

if [ "${failures}" -gt 0 ]; then
	echo "" >&2
	echo "${failures} package(s) raise an error when the package is queried as a whole." >&2
	echo "A consumer querying data.<package> receives nothing for these, and a tool that" >&2
	echo "treats a missing package as 'no verdict' reports success while delivering none." >&2
	echo "Usually two files in one package define the same complete rule with different" >&2
	echo "values; give each a name of its own." >&2
	exit 1
fi

echo "All ${total} packages evaluate without error when queried as a whole."
