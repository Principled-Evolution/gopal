#!/usr/bin/env bash
#
# Generate docs/coverage/coverage.json from the policies themselves.
#
# The per-framework coverage matrices used to be maintained by hand, and they
# drifted: the policy count, the list of implemented frameworks and the test
# coverage figures were all wrong at various points. Everything in coverage.json
# is derived from the .rego files on disk, so it cannot disagree with them.
#
# Usage:
#   scripts/generate-coverage.sh            # write docs/coverage/coverage.json
#   scripts/generate-coverage.sh --check    # exit 1 if the committed file is stale
#   scripts/generate-coverage.sh --stdout   # print the JSON, write nothing
#
# Requires: opa, jq. Both are already installed in CI.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

OUT="docs/coverage/coverage.json"
MODE="write"
case "${1:-}" in
	--check) MODE="check" ;;
	--stdout) MODE="stdout" ;;
	"") ;;
	*)
		echo "Unknown flag: $1" >&2
		echo "Usage: scripts/generate-coverage.sh [--check|--stdout]" >&2
		exit 2
		;;
esac

for tool in opa jq; do
	command -v "${tool}" >/dev/null 2>&1 || {
		echo "error: ${tool} is required but not on PATH" >&2
		exit 1
	}
done

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

OPA_IGNORES=(--ignore custom/ --ignore dist --ignore '*.yml' --ignore '*.yaml' --ignore '*.json' --ignore '.venv-diagrams')

# ---------------------------------------------------------------------------
# 1. Enumerate policy files and read what the file itself declares.
# ---------------------------------------------------------------------------
# A policy is any .rego that is not a test and not under custom/. For each one
# we record the package, the decision rules that carry an explicit default, the
# RequiredMetrics/RequiredParams comment header, and whether it has a sibling
# test that exercises empty input.

policy_files() {
	find . -type f -name '*.rego' \
		-not -name '*_test.rego' \
		-not -path './custom/*' \
		-not -path './.venv-diagrams/*' \
		-not -path './.git/*' |
		sed 's|^\./||' | LC_ALL=C sort
}

# Pull an indented "# - value" list that follows a "# Header:" line.
comment_list() {
	local file="$1" header="$2"
	awk -v hdr="${header}" '
		$0 ~ "^# *" hdr ":" { collecting = 1; next }
		collecting {
			if ($0 ~ /^# *- */) {
				line = $0
				sub(/^# *- */, "", line)
				sub(/[ \t]+$/, "", line)
				if (line != "") print line
				next
			}
			collecting = 0
		}
	' "${file}"
}

: >"${TMP}/policies.ndjson"

while IFS= read -r file; do
	pkg="$(awk '/^package /{print $2; exit}' "${file}")"
	[ -n "${pkg}" ] || continue

	# Decision rules: booleans with an explicit default. These are the rules a
	# caller asks for a verdict, and the ones the empty-input tests assert on.
	decisions="$(awk '
		/^default [a-zA-Z_][a-zA-Z0-9_]* := (false|true)$/ {
			print $2 "\t" $4
		}
	' "${file}" | jq -R -s 'split("\n")
		| map(select(length > 0) | split("\t") | {name: .[0], default: (.[1] == "true")})')"

	metrics="$(comment_list "${file}" 'RequiredMetrics' | jq -R -s 'split("\n") | map(select(length > 0))')"
	params="$(comment_list "${file}" 'RequiredParams' | jq -R -s 'split("\n") | map(select(length > 0))')"

	# A title from the `# @title` comment convention, used by the policies that
	# do not define a `metadata` rule. The metadata rule wins when both exist.
	comment_title="$(awk '/^# *@title /{sub(/^# *@title */, ""); print; exit}' "${file}")"

	test_file="${file%.rego}_test.rego"
	has_test=false
	has_empty=false
	if [ -f "${test_file}" ]; then
		has_test=true
		if grep -q 'with input as {}' "${test_file}"; then
			has_empty=true
		fi
	fi

	# Framework id is the path above the version segment, e.g.
	# international/eu_ai_act/v1/gpai/foo.rego -> international/eu_ai_act
	fw="$(printf '%s' "${file}" | awk -F/ '{
		for (i = 1; i <= NF; i++) if ($i ~ /^v[0-9]+$/) { n = i - 1; break }
		if (n == 0) n = (NF > 1 ? NF - 1 : 1)
		out = $1
		for (i = 2; i <= n; i++) out = out "/" $i
		print out
	}')"

	jq -c -n \
		--arg path "${file}" \
		--arg package "${pkg}" \
		--arg framework "${fw}" \
		--arg comment_title "${comment_title}" \
		--arg test_file "${test_file}" \
		--argjson decision_rules "${decisions}" \
		--argjson required_metrics "${metrics}" \
		--argjson required_params "${params}" \
		--argjson has_test "${has_test}" \
		--argjson has_empty_input_test "${has_empty}" \
		'{
			path: $path,
			package: $package,
			framework: $framework,
			comment_title: (if $comment_title == "" then null else $comment_title end),
			decision_rules: $decision_rules,
			required_metrics: $required_metrics,
			required_params: $required_params,
			has_test: $has_test,
			has_empty_input_test: $has_empty_input_test,
			test_file: (if $has_test then $test_file else null end)
		}' >>"${TMP}/policies.ndjson"
done < <(policy_files)

# ---------------------------------------------------------------------------
# 2. Ask OPA for each package's `metadata` rule.
# ---------------------------------------------------------------------------
# The metadata is already a queryable Rego value, so OPA is the authority on it
# rather than a regex over the source. Only packages that actually define the
# rule are probed, otherwise the query would be undefined.

probe="${TMP}/_coverage_probe.rego"
{
	echo 'package _coverage_probe'
	echo ''
	echo 'import rego.v1'
	echo ''
	echo 'metadata_by_package := {'
	while IFS= read -r file; do
		grep -qE '^metadata := ' "${file}" || continue
		pkg="$(awk '/^package /{print $2; exit}' "${file}")"
		[ -n "${pkg}" ] || continue
		printf '\t"%s": data.%s.metadata,\n' "${pkg}" "${pkg}"
	done < <(policy_files) | LC_ALL=C sort -u
	echo '}'
} >"${probe}"

cp "${probe}" ./_coverage_probe.rego
trap 'rm -rf "${TMP}"; rm -f "${REPO_ROOT}/_coverage_probe.rego"' EXIT

opa eval --data . "${OPA_IGNORES[@]}" \
	--format json 'data._coverage_probe.metadata_by_package' \
	>"${TMP}/metadata.json"

rm -f ./_coverage_probe.rego

jq '.result[0].expressions[0].value // {}' "${TMP}/metadata.json" >"${TMP}/metadata_map.json"

# ---------------------------------------------------------------------------
# 3. Framework display names, taken from each framework README's first heading.
# ---------------------------------------------------------------------------
# Deriving the name from the README keeps this list from going stale when a
# framework is added, and avoids a hand-maintained lookup table in this script.

: >"${TMP}/frameworks.ndjson"
while IFS= read -r fw; do
	name=""
	for candidate in "${fw}/README.md" "${fw}"/v*/README.md; do
		[ -f "${candidate}" ] || continue
		name="$(awk '/^# /{sub(/^# */, ""); print; exit}' "${candidate}")"
		[ -n "${name}" ] && break
	done
	if [ -z "${name}" ]; then
		# Fall back to the directory name: eu_ai_act -> Eu Ai Act
		name="$(basename "${fw}" | tr '_' ' ' | awk '{
			for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2)
			print
		}')"
	fi
	# The headings read "EU AI Act Policies"; the trailing noun is redundant here.
	name="$(printf '%s' "${name}" | sed -E 's/ (Policies|Policy)$//')"

	# Not everything under this tree is a regulatory framework. Consumers that
	# want "how many frameworks does GOPAL cover" should count regulation and
	# vertical, and leave the shared libraries out of the headline.
	case "${fw}" in
		helper_functions) kind="library" ;;
		global) kind="cross-cutting" ;;
		international/*) kind="regulation" ;;
		industry_specific/*) kind="vertical" ;;
		operational/*) kind="operational" ;;
		*) kind="other" ;;
	esac

	jq -c -n --arg id "${fw}" --arg name "${name}" --arg kind "${kind}" \
		'{id: $id, name: $name, kind: $kind}' \
		>>"${TMP}/frameworks.ndjson"
done < <(jq -r '.framework' "${TMP}/policies.ndjson" | LC_ALL=C sort -u)

# ---------------------------------------------------------------------------
# 4. Test suite size, straight from opa test.
# ---------------------------------------------------------------------------
test_total="$(opa test "${OPA_IGNORES[@]}" . 2>/dev/null |
	awk -F'[:/ ]+' '/^PASS: /{print $3; exit}')"
: "${test_total:=0}"

# ---------------------------------------------------------------------------
# 5. Assemble.
# ---------------------------------------------------------------------------
jq -n >"${TMP}/coverage.json" \
	--slurpfile policies <(jq -s '.' "${TMP}/policies.ndjson") \
	--slurpfile frameworks <(jq -s '.' "${TMP}/frameworks.ndjson") \
	--slurpfile metadata "${TMP}/metadata_map.json" \
	--argjson test_total "${test_total}" \
	'
	($policies[0]) as $pols
	| ($frameworks[0]) as $fws
	| ($metadata[0]) as $meta
	| ($pols | map(. + {
			title: (
				.comment_title
				// ($meta[.package].title // null)
			),
			description: ($meta[.package].description // null),
			references: ($meta[.package].references // []),
			version: ($meta[.package].version // null),
			# A file with no defaulted boolean rule reaches no verdict of its own;
			# it exists to be imported by the policies that do.
			is_library: ((.decision_rules | length) == 0)
		} | del(.comment_title))) as $enriched
	| {
		schema_version: 1,
		generated_by: "scripts/generate-coverage.sh",
		note: "Derived from the .rego files on disk. Do not edit by hand; run the script.",
		totals: {
			frameworks: ($fws | map(select(.kind == "regulation" or .kind == "vertical")) | length),
			groups: ($fws | length),

			# `policies` counts only files that actually reach a verdict, i.e. that
			# define at least one boolean rule with an explicit default. The rest
			# are shared function libraries. Counting libraries as policies is how
			# the old hand-written figure overstated coverage.
			policies: ($enriched | map(select(.is_library | not)) | length),
			library_files: ($enriched | map(select(.is_library)) | length),
			rego_files: ($enriched | length),

			policies_with_tests: ($enriched | map(select((.is_library | not) and .has_test)) | length),
			policies_with_empty_input_test: ($enriched | map(select((.is_library | not) and .has_empty_input_test)) | length),
			decision_rules: ($enriched | map(.decision_rules | length) | add // 0),
			tests: $test_total
		},
		frameworks: [
			$fws[]
			| . as $fw
			| ($enriched | map(select(.framework == $fw.id))) as $fp
			| {
				id: $fw.id,
				name: $fw.name,
				kind: $fw.kind,
				policy_count: ($fp | length),
				policies_with_tests: ($fp | map(select(.has_test)) | length),
				policies: ($fp | map(del(.framework)) | sort_by(.path))
			}
		] | sort_by(.id)
	}
	'

# ---------------------------------------------------------------------------
# 6. Emit.
# ---------------------------------------------------------------------------
case "${MODE}" in
	stdout)
		cat "${TMP}/coverage.json"
		;;
	check)
		if [ ! -f "${OUT}" ]; then
			echo "error: ${OUT} does not exist. Run scripts/generate-coverage.sh." >&2
			exit 1
		fi
		if ! diff -u "${OUT}" "${TMP}/coverage.json" >"${TMP}/diff.txt"; then
			echo "error: ${OUT} is out of date." >&2
			echo "Run scripts/generate-coverage.sh and commit the result." >&2
			echo "" >&2
			head -60 "${TMP}/diff.txt" >&2
			exit 1
		fi
		echo "${OUT} is up to date."
		;;
	write)
		mkdir -p "$(dirname "${OUT}")"
		cp "${TMP}/coverage.json" "${OUT}"
		jq -r '
			"Wrote \(.totals.policies) policies across \(.totals.frameworks) frameworks.",
			"  with a sibling test:      \(.totals.policies_with_tests)/\(.totals.policies)",
			"  with an empty-input test: \(.totals.policies_with_empty_input_test)/\(.totals.policies)",
			"  decision rules:           \(.totals.decision_rules)",
			"  tests in suite:           \(.totals.tests)"
		' "${OUT}"
		;;
esac
