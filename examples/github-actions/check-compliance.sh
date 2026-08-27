#!/usr/bin/env bash
#
# Evaluate an input document against one GOPAL policy and set the build result.
#
# Copy this into your own repository alongside the workflow. It is deliberately
# a script rather than an inline `run:` block, so you can run exactly what CI
# runs before you push.
#
# Usage:
#   check-compliance.sh --bundle FILE --package PKG [--input FILE] [--rule NAME]
#
#   --bundle   an OPA bundle, e.g. gopal-international-eu_ai_act-1.2.0.tar.gz
#   --package  the policy package, e.g. international.eu_ai_act.v1.transparency
#   --input    the document to evaluate  (default: model-card.json)
#   --rule     the decision rule to read (default: allow)
#
# Exits 0 when the verdict is compliant, 1 when it is not, and 2 on a usage or
# evaluation error. The three are kept distinct on purpose: a policy that failed
# to evaluate is not the same as a system that failed the policy, and treating
# them alike is how a broken pipeline starts reporting green.

set -euo pipefail

BUNDLE=""
PACKAGE=""
INPUT="model-card.json"
RULE="allow"

while [ $# -gt 0 ]; do
	case "$1" in
		--bundle) BUNDLE="${2:?--bundle needs a file}"; shift 2 ;;
		--package) PACKAGE="${2:?--package needs a package path}"; shift 2 ;;
		--input) INPUT="${2:?--input needs a file}"; shift 2 ;;
		--rule) RULE="${2:?--rule needs a rule name}"; shift 2 ;;
		-h | --help) sed -n '2,22p' "$0"; exit 0 ;;
		*) echo "Unknown flag: $1" >&2; exit 2 ;;
	esac
done

[ -n "${BUNDLE}" ] || { echo "error: --bundle is required" >&2; exit 2; }
[ -n "${PACKAGE}" ] || { echo "error: --package is required" >&2; exit 2; }
[ -f "${BUNDLE}" ] || { echo "error: bundle not found: ${BUNDLE}" >&2; exit 2; }
[ -f "${INPUT}" ] || { echo "error: input not found: ${INPUT}" >&2; exit 2; }
command -v opa >/dev/null 2>&1 || { echo "error: opa is not on PATH" >&2; exit 2; }

QUERY="data.${PACKAGE}.${RULE}"

# --format json rather than raw, so an undefined result is distinguishable from
# a false one. In Rego an undefined value is not false, and a policy that went
# undefined has told you nothing, which must not read as a pass.
if ! RAW="$(opa eval -b "${BUNDLE}" --input "${INPUT}" "${QUERY}" --format json 2>"${TMPDIR:-/tmp}/opa-err.$$")"; then
	echo "::error::${QUERY} failed to evaluate against ${INPUT}"
	sed 's/^/  /' "${TMPDIR:-/tmp}/opa-err.$$" >&2
	rm -f "${TMPDIR:-/tmp}/opa-err.$$"
	exit 2
fi
rm -f "${TMPDIR:-/tmp}/opa-err.$$"

if [ "$(printf '%s' "${RAW}" | jq '.result | length')" -eq 0 ]; then
	echo "::error::${QUERY} is undefined for ${INPUT}. The policy reached no verdict, which is not a pass."
	exit 2
fi

VERDICT="$(printf '%s' "${RAW}" | jq -r '.result[0].expressions[0].value')"

# Print the full report when the policy publishes one, since "false" on its own
# does not tell a reviewer what to fix.
REPORT="$(opa eval -b "${BUNDLE}" --input "${INPUT}" \
	"data.${PACKAGE}.compliance_report" --format json 2>/dev/null |
	jq -c '.result[0].expressions[0].value // empty' || true)"

if [ "${VERDICT}" = "true" ]; then
	echo "COMPLIANT: ${QUERY} against ${INPUT}"
	[ -n "${REPORT}" ] && printf '%s\n' "${REPORT}" | jq .
	exit 0
fi

echo "::error::NON-COMPLIANT: ${QUERY} returned ${VERDICT} for ${INPUT}"
if [ -n "${REPORT}" ]; then
	printf '%s\n' "${REPORT}" | jq .
	printf '%s\n' "${REPORT}" | jq -r '
		"",
		"Reason: \(.reason // "not reported")",
		"",
		"Recommendations:",
		(.recommendations // [] | to_entries[] | "  \(.key + 1). \(.value)")
	'
fi
exit 1
