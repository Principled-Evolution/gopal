#!/usr/bin/env bash
#
# Assert that every hand-maintained number agrees with the generated data:
# the GOPAL version against VERSION, and the published counts against
# docs/coverage/coverage.json.
#
# v1.2.0 shipped a README telling people to run
#
#   gh release download v1.2.0 --pattern 'gopal-international-eu_ai_act-*.tar.gz'
#
# against a release that had no assets, because the bundle workflow did not
# exist when that tag was cut. The instruction was dead on arrival and nothing
# caught it. Version strings live in seven places and are bumped by hand, so
# this runs in CI and fails when one is left behind.
#
# The counts drifted the same way. The README hero banner read "96 policies"
# while the stat panel directly beneath it read 91, on the front page of the
# repository — the first thing a visitor sees, contradicting itself. Counts are
# baked into SVG text, so nothing regenerates them and nothing noticed.
#
# Usage: scripts/check-version-refs.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

VERSION="$(tr -d ' \n' <VERSION)"
if [ -z "${VERSION}" ]; then
	echo "error: VERSION is empty" >&2
	exit 1
fi

echo "VERSION is ${VERSION}. Checking every reference agrees."

failures=0

# Each entry: file:pattern-with-VERSION-placeholder:description
# %V% stands in for the version so the expected string can be printed.
check() {
	local file="$1" template="$2" what="$3"
	local expected="${template//%V%/${VERSION}}"
	if [ ! -f "${file}" ]; then
		echo "  MISSING FILE  ${file}" >&2
		failures=$((failures + 1))
		return
	fi
	if grep -qF -- "${expected}" "${file}"; then
		printf '  ok   %-42s %s\n' "${what}" "${expected}"
	else
		printf '  FAIL %-42s expected: %s\n' "${what}" "${expected}" >&2
		# Show what is actually there, to make the fix obvious.
		local prefix
		prefix="$(printf '%s' "${template}" | sed 's/%V%.*//')"
		if [ -n "${prefix}" ]; then
			grep -nF -- "${prefix}" "${file}" 2>/dev/null | head -2 | sed 's/^/         found: /' >&2 || true
		fi
		failures=$((failures + 1))
	fi
}

check pyproject.toml 'version = "%V%"' "pyproject version"
check README.md 'gh release download v%V%' "README bundle download command"
check README.md 'gopal-international-eu_ai_act-%V%.tar.gz' "README bundle filename"
check examples/github-actions/workflow.yaml "GOPAL_VERSION: '%V%'" "Actions example workflow"
check examples/github-actions/README.md "GOPAL_VERSION: '%V%'" "Actions example README, env block"
check examples/github-actions/README.md 'gopal-international-eu_ai_act-%V%.tar.gz' "Actions example README, local build"
check CITATION.cff 'version: "%V%"' "CITATION.cff version"
check README.md 'version = {%V%},' "README BibTeX version"

# Nothing outside the changelog and build output should still name an older
# version. This catches a reference in a file the list above does not know about.
echo ""
echo "Scanning for stale version strings elsewhere."
stale=0
while IFS= read -r hit; do
	# Report any x.y.z that is not the current version.
	found="$(printf '%s' "${hit}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
	[ "${found}" = "${VERSION}" ] && continue
	echo "  stale?  ${hit}" >&2
	stale=$((stale + 1))
done < <(
	grep -rn -E 'v?[0-9]+\.[0-9]+\.[0-9]+' \
		--include='*.md' --include='*.toml' --include='*.yaml' --include='*.yml' \
		README.md pyproject.toml examples/ 2>/dev/null |
		grep -vE 'CHANGELOG|COMPATIBILITY' |
		# A dependency constraint names someone else's version, not ours.
		grep -vE '(>=|<=|~=|==|\^)[[:space:]]*v?[0-9]+\.[0-9]+\.[0-9]+' |
		# A "version" field inside a sample report is policy metadata.
		grep -vE '"version"[[:space:]]*:' |
		# A pinned GitHub Action or a cited regulation number.
		grep -vE 'uses:|Regulation|Article|SS[0-9]' || true
)

if [ "${stale}" -gt 0 ]; then
	echo "" >&2
	echo "  Note: the lines above name a version other than ${VERSION}." >&2
	echo "  Some are legitimate (a cited regulation, an action pin, a tool version)." >&2
	echo "  They are reported, not failed. Only the checks above are enforced." >&2
fi

echo ""
# --- published counts -------------------------------------------------------
#
# The authority is coverage.json, which is generated from the tree and already
# checked in CI, so these can only disagree if a hand-edited file is stale.

COVERAGE="docs/coverage/coverage.json"
if [ ! -f "${COVERAGE}" ]; then
	echo "error: ${COVERAGE} not found. Run scripts/generate-coverage.sh." >&2
	exit 1
fi

POLICIES="$(jq -r '.totals.policies' "${COVERAGE}")"
FRAMEWORKS="$(jq -r '[.frameworks[] | select(.id | startswith("international"))] | length' "${COVERAGE}")"
INDUSTRIES="$(jq -r '[.frameworks[] | select(.id | startswith("industry_specific"))] | length' "${COVERAGE}")"

echo ""
echo "Coverage data says ${POLICIES} policies, ${FRAMEWORKS} frameworks, ${INDUSTRIES} industries. Checking every reference agrees."

check_count() {
	local file="$1" template="$2" what="$3"
	local expected="${template//%P%/${POLICIES}}"
	expected="${expected//%F%/${FRAMEWORKS}}"
	expected="${expected//%I%/${INDUSTRIES}}"
	if [ ! -f "${file}" ]; then
		echo "  MISSING FILE  ${file}" >&2
		failures=$((failures + 1))
		return
	fi
	if grep -qF -- "${expected}" "${file}"; then
		printf '  ok   %-42s %s\n' "${what}" "${expected}"
	else
		printf '  FAIL %-42s expected: %s\n' "${what}" "${expected}" >&2
		failures=$((failures + 1))
	fi
}

check_count docs/diagrams/hero_banner_light.svg '%P% policies · %F% frameworks · Apache 2.0' "hero banner, light"
check_count docs/diagrams/hero_banner_dark.svg '%P% policies · %F% frameworks · Apache 2.0' "hero banner, dark"
check_count README.md '**%P% policies that reach a verdict' "README policy count"
check_count README.md '%P% policies that translate published regulation' "README opening count"

# The accessible description is what a screen reader announces, and it said 96
# while the visible text beside it said 91. Numbers in alt text drift more
# easily than numbers on screen, because nobody looking at the page sees them.
check_count docs/diagrams/diagram1_hero_numbers_light.svg '<desc>%P% production Rego policies across %F% frameworks and %I% industries.</desc>' "numbers diagram desc, light"
check_count docs/diagrams/diagram1_hero_numbers_dark.svg '<desc>%P% production Rego policies across %F% frameworks and %I% industries.</desc>' "numbers diagram desc, dark"

if [ "${failures}" -gt 0 ]; then
	echo "${failures} version reference(s) disagree with VERSION (${VERSION})." >&2
	echo "Bump them, or update scripts/check-version-refs.sh if a reference moved." >&2
	exit 1
fi
echo "All enforced version references agree with ${VERSION}, and all published counts agree with the coverage data."
