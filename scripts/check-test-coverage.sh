#!/usr/bin/env bash
#
# Fail if any policy lacks a sibling test file or an empty-input test.
#
# CONTRIBUTING.md has always required both. Nothing enforced it, and the gap
# grew to 22 of 96 policies with no test at all — including both Article 5
# prohibited-practice policies, the two that gate the practices the EU AI Act
# bans outright.
#
# An external reviewer demonstrated what that meant. In
# `prohibited_practices/social_scoring.rego` he changed
#
#     default allow := false   ->   default allow := true
#
# turning the Article 5 social-scoring gate into a default allow, and `opa test`
# still reported 604/604. A green suite and a per-file count were disagreeing,
# and the files sitting uncovered were the prohibitions rather than the
# paperwork.
#
# Both conditions are checked because they fail differently. A missing test file
# means nothing is verified. A test file with no empty-input assertion usually
# means the fail-open case specifically is unverified, which is the one that
# matters most here: in Rego an undefined value is not `false`, so a policy that
# reaches no conclusion returns no decision, and at a gate that reads as a
# policy which has quietly stopped saying no.
#
# Libraries are exempt. They define helpers rather than decisions, so there is
# no `allow` to hand an empty input to. The distinction is `is_library` in the
# coverage data, which is derived from whether the file declares decision rules.
#
# Usage: check-test-coverage.sh

set -euo pipefail

cd "$(dirname "$0")/.."

COVERAGE="docs/coverage/coverage.json"

if [ ! -f "${COVERAGE}" ]; then
	echo "error: ${COVERAGE} not found. Run scripts/generate-coverage.sh first." >&2
	exit 1
fi

# The coverage data is generated from the .rego files and CI already fails when
# it is stale, so it is the right place to read from rather than walking the
# tree again with different rules.
missing_test="$(jq -r '
	[.. | objects | select(has("package") and has("path"))]
	| map(select(.is_library | not))
	| map(select(.has_test | not))
	| .[].path
' "${COVERAGE}")"

missing_empty="$(jq -r '
	[.. | objects | select(has("package") and has("path"))]
	| map(select(.is_library | not))
	| map(select(.has_test and (.has_empty_input_test | not)))
	| .[].path
' "${COVERAGE}")"

status=0

if [ -n "${missing_test}" ]; then
	status=1
	echo "error: policies with no sibling test file:" >&2
	printf '  %s\n' ${missing_test} >&2
	echo "" >&2
	echo "Every policy needs a <name>_test.rego beside it. See CONTRIBUTING.md." >&2
	echo "" >&2
fi

if [ -n "${missing_empty}" ]; then
	status=1
	echo "error: policies with a test file but no empty-input test:" >&2
	printf '  %s\n' ${missing_empty} >&2
	echo "" >&2
	echo "Add an assertion that the decision denies an empty input, e.g." >&2
	echo "" >&2
	echo "  test_allow_denies_on_empty_input if {" >&2
	echo "  	not policy.allow with input as {}" >&2
	echo "  }" >&2
	echo "" >&2
	echo "This is the single test that catches the fail-open class: in Rego an" >&2
	echo "undefined value is not false, so a policy missing a default returns no" >&2
	echo "decision rather than a denial." >&2
	echo "" >&2
fi

if [ "${status}" -eq 0 ]; then
	total="$(jq '[.. | objects | select(has("package") and has("path")) | select(.is_library | not)] | length' "${COVERAGE}")"
	libs="$(jq '[.. | objects | select(has("package") and has("path")) | select(.is_library)] | length' "${COVERAGE}")"
	echo "All ${total} policies have a test and an empty-input test (${libs} libraries exempt)."
fi

exit "${status}"
