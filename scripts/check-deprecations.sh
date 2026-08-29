#!/usr/bin/env bash
#
# Hold the deprecation timer, so it is not something anybody has to remember.
#
# Legacy metric spellings are recorded in helper_functions/metrics.rego with the
# version that deprecated them. Removing one is a breaking change, so it can only
# happen at a major version. This refuses to let a major version ship while
# matured deprecations are still in the table.
#
# That is the whole timer. It does not nag during minor releases, because there
# is nothing to decide then, and it cannot be skipped at the one moment there is.
#
# Deliberately not a calendar. GOPAL releases when there is something to release,
# so a date either falls between releases and means nothing, or ages into a
# deadline nobody chose. A consumer upgrades across versions, not across months.
#
# Worth stating: this project sends nothing anywhere, so nobody here will ever
# observe that an external input used a legacy name. `metrics.deprecated` reports
# that to the caller running the policy, not to us. The window exists so a user
# has a release in which to notice and object, not so that we can measure
# anything. Silence is the absence of evidence, not evidence of absence, and
# removing on silence is a judgement rather than a finding.
#
# Usage:
#   check-deprecations.sh            report status against VERSION
#   check-deprecations.sh --list     print the table and exit 0

set -euo pipefail

cd "$(dirname "$0")/.."

command -v opa >/dev/null || { echo "opa is required" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 2; }

VERSION="$(tr -d ' \n' <VERSION)"
MAJOR="${VERSION%%.*}"
MINOR="$(printf '%s' "$VERSION" | cut -d. -f2)"

# How many minor releases a deprecation must survive before it is eligible for
# removal. One is too few to be a window at all; two means a user who upgrades
# every other release still meets it once.
GRACE_MINORS=2

table="$(opa eval --data helper_functions --format json \
	'data.helper_functions.metrics.deprecated_since' 2>/dev/null |
	jq -r '.result[0].expressions[0].value // {}')"

count="$(jq -r 'length' <<<"$table")"

if [ "${1:-}" = "--list" ]; then
	echo "Deprecated metric spellings, and the version that deprecated each:"
	jq -r 'to_entries | sort_by(.key)[] | "  \(.key)  since \(.value)"' <<<"$table"
	exit 0
fi

if [ "$count" -eq 0 ]; then
	echo "No deprecated spellings remain."
	exit 0
fi

# Eligible means: deprecated long enough ago that a user has had a window.
eligible="$(jq -r --argjson maj "$MAJOR" --argjson min "$MINOR" --argjson grace "$GRACE_MINORS" '
	to_entries
	| map(select(
		(.value | split(".") | .[0] | tonumber) < $maj
		or ((.value | split(".") | .[0] | tonumber) == $maj
		    and (.value | split(".") | .[1] | tonumber) + $grace <= $min)
	))
	| length' <<<"$table")"

echo "Version ${VERSION}. ${count} deprecated spelling(s) in the alias table, ${eligible} matured."

if [ "$eligible" -eq 0 ]; then
	echo "None has served its window yet. Nothing to decide."
	exit 0
fi

jq -r --argjson maj "$MAJOR" --argjson min "$MINOR" --argjson grace "$GRACE_MINORS" '
	to_entries
	| map(select(
		(.value | split(".") | .[0] | tonumber) < $maj
		or ((.value | split(".") | .[0] | tonumber) == $maj
		    and (.value | split(".") | .[1] | tonumber) + $grace <= $min)
	))
	| sort_by(.key)[]
	| "  \(.key)  deprecated in \(.value)"' <<<"$table"

cat <<EOF

These have served their window and may be removed at the next major version.
Removing one is a breaking change, so it cannot happen before ${MAJOR}.0.0 is
next incremented.

This is a decision, not a finding. Nothing here observes whether anybody still
sends these names, and nothing can: GOPAL makes no outbound calls. Removing them
is a judgement that the window was fair, not a measurement that they are unused.
EOF

# Only a hard failure at the moment the question must be answered: a major
# version cannot ship while matured deprecations are still carried.
if [ "$MINOR" = "0" ] && [ "$(printf '%s' "$VERSION" | cut -d. -f3)" = "0" ]; then
	echo ""
	echo "error: ${VERSION} is a major release and ${eligible} matured deprecation(s) remain." >&2
	echo "Remove them from the alias table, or move deprecated_since forward with a reason." >&2
	exit 1
fi

exit 0
