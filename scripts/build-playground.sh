#!/usr/bin/env bash
#
# Build the WebAssembly artifacts and metadata a browser playground needs.
#
# GOPAL's value is invisible until you install OPA and know which of 155 fields
# the EU AI Act wants. Compiling the policies to WASM lets a browser evaluate
# them with no server, so someone can see a real verdict in half a minute, and
# the document they paste never leaves their machine. For a compliance library
# that last part is not a cost saving, it is the reason a compliance officer will
# try it at all.
#
# Output, in dist/playground/:
#   <framework>.wasm        one module per framework, entrypoint per policy
#   manifest.json           frameworks, policies, required fields, verdict sense
#   samples/<fw>.json       curated input for each framework that has one
#
# Usage:
#   scripts/build-playground.sh              # build everything
#   scripts/build-playground.sh --verify     # also assert samples give the
#                                            # verdicts samples/expected.json claims
#   scripts/build-playground.sh --list       # show what would be built
#
# Requires: opa, jq. Node with @open-policy-agent/opa-wasm for --verify.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

OUT_DIR="dist/playground"
SAMPLE_DIR="playground/samples"
COVERAGE="docs/coverage/coverage.json"
MODE="build"

while [ $# -gt 0 ]; do
	case "$1" in
		--verify) MODE="verify"; shift ;;
		--list) MODE="list"; shift ;;
		--out) OUT_DIR="${2:?--out needs a directory}"; shift 2 ;;
		*) echo "Unknown flag: $1" >&2; exit 2 ;;
	esac
done

for tool in opa jq; do
	command -v "${tool}" >/dev/null 2>&1 || {
		echo "error: ${tool} is required but not on PATH" >&2
		exit 1
	}
done
[ -f "${COVERAGE}" ] || {
	echo "error: ${COVERAGE} missing. Run scripts/generate-coverage.sh first." >&2
	exit 1
}

VERSION="$(tr -d ' \n' <VERSION)"

# Shared libraries every framework imports. Same set the release bundles stage;
# an import scan confirms nothing else crosses directories.
SHARED=(helper_functions global/v1/common)

# Frameworks worth putting in front of a first-time visitor. Deliberately not
# every framework: a playground with a curated, verified sample for two
# frameworks is more use than six that deny everything with no explanation.
# Adding one is a matter of writing playground/samples/<slug>.json and an entry
# in expected.json, then re-running with --verify.
FRAMEWORKS=(
	international/eu_ai_act
	international/uk
)

slug_of() { printf '%s' "${1//\//-}"; }

entrypoints_for() {
	# The primary decision rule per policy, as an OPA entrypoint path. Uses
	# primary_decision rather than decision_rules[0]: `allow` exists in 78 of the
	# 91 policies but is first in only 42, so the naive pick resolves an
	# intermediate rule for more than half of them.
	jq -r --arg id "$1" '
		.frameworks[] | select(.id == $id) | .policies[]
		| select(.is_library | not)
		| select(.primary_decision != null)
		| (.package + "." + .primary_decision) | gsub("\\."; "/")
	' "${COVERAGE}"
}

if [ "${MODE}" = "list" ]; then
	echo "Would build into ${OUT_DIR}/ at version ${VERSION}:"
	for fw in "${FRAMEWORKS[@]}"; do
		n=$(entrypoints_for "${fw}" | wc -l | tr -d ' ')
		sample="${SAMPLE_DIR}/$(slug_of "${fw}").json"
		printf '  %-30s %2s policies  sample: %s\n' "${fw}" "${n}" \
			"$([ -f "${sample}" ] && echo present || echo MISSING)"
	done
	exit 0
fi

mkdir -p "${OUT_DIR}" "${OUT_DIR}/samples"

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

echo "Building playground artefacts for GOPAL ${VERSION}"

built=0
for fw in "${FRAMEWORKS[@]}"; do
	slug="$(slug_of "${fw}")"
	# shellcheck disable=SC2207
	eps=($(entrypoints_for "${fw}"))
	if [ "${#eps[@]}" -eq 0 ]; then
		echo "  skipping ${fw}: no policies with a primary decision rule" >&2
		continue
	fi

	args=()
	for e in "${eps[@]}"; do args+=(-e "${e}"); done

	# WASM compilation needs explicit entrypoints. Without them OPA tries to
	# compile every rule in the tree and fails on helper functions it cannot
	# lower, with an error that points at the helper rather than the cause.
	opa build -t wasm "${args[@]}" \
		--ignore '.github' --ignore '*.yml' --ignore '*.yaml' \
		--ignore '*.json' --ignore custom --ignore dist \
		-o "${TMP}/${slug}.tar.gz" \
		"${fw}" "${SHARED[@]}" >"${TMP}/build.log" 2>&1 || {
		echo "  FAILED to build ${fw}" >&2
		sed 's/^/    /' "${TMP}/build.log" >&2
		exit 1
	}

	# The bundle stores the module as /policy.wasm, with a leading slash, so
	# naming the member explicitly is fragile. Extract everything and locate it.
	rm -rf "${TMP}/x" && mkdir -p "${TMP}/x"
	tar -xzf "${TMP}/${slug}.tar.gz" -C "${TMP}/x" 2>/dev/null
	found="$(find "${TMP}/x" -name 'policy.wasm' -print -quit)"
	[ -n "${found}" ] || {
		echo "  FAILED: no policy.wasm in the bundle for ${fw}" >&2
		tar -tzf "${TMP}/${slug}.tar.gz" | head -5 | sed 's/^/    /' >&2
		exit 1
	}
	mv "${found}" "${OUT_DIR}/${slug}.wasm"
	# The module comes out of the archive with a 1970 mtime, which makes gzip
	# warn about a timestamp out of range and, under pipefail, abort the build.
	touch "${OUT_DIR}/${slug}.wasm"

	raw=$(wc -c <"${OUT_DIR}/${slug}.wasm")
	# -n omits the timestamp, so the reported size is stable across rebuilds.
	gz=$(gzip -9 -n -c "${OUT_DIR}/${slug}.wasm" | wc -c)
	printf '  %-30s %2d policies  %4dKB raw  %4dKB gzip\n' \
		"${fw}" "${#eps[@]}" "$((raw / 1024))" "$((gz / 1024))"

	sample="${SAMPLE_DIR}/${slug}.json"
	if [ -f "${sample}" ]; then
		cp "${sample}" "${OUT_DIR}/samples/${slug}.json"
	else
		echo "    note: no curated sample at ${sample}" >&2
	fi
	built=$((built + 1))
done

# ---------------------------------------------------------------------------
# manifest.json: everything the page needs that is not the WASM itself.
# ---------------------------------------------------------------------------
# Derived from coverage.json so it cannot describe policies that do not exist.
# decision_true_means matters: one policy is a detector where true is a concern
# raised rather than a pass, and rendering it like the other 90 would invert the
# finding.
jq -n \
	--arg version "${VERSION}" \
	--argjson frameworks "$(printf '%s\n' "${FRAMEWORKS[@]}" | jq -R -s 'split("\n") | map(select(length > 0))')" \
	--slurpfile coverage "${COVERAGE}" \
	'
	($coverage[0]) as $cov
	| {
		gopal_version: $version,
		generated_by: "scripts/build-playground.sh",
		note: "Derived from docs/coverage/coverage.json. Do not edit by hand.",
		frameworks: [
			$frameworks[] as $id
			| ($cov.frameworks[] | select(.id == $id)) as $f
			| {
				id: $f.id,
				slug: ($f.id | gsub("/"; "-")),
				name: $f.name,
				wasm: (($f.id | gsub("/"; "-")) + ".wasm"),
				policy_count: ([$f.policies[] | select(.is_library | not)] | length),
				policies: [
					$f.policies[]
					| select(.is_library | not)
					| select(.primary_decision != null)
					| {
						package: .package,
						title: .title,
						path: .path,
						entrypoint: ((.package + "/" + .primary_decision) | gsub("\\."; "/")),
						decision: .primary_decision,
						true_means: .decision_true_means,
						references: .references,
						declared_fields: [
							.required_metrics[]
							| select(
								(startswith("metrics.") or startswith("evaluation.")
								 or startswith("summary.") or startswith("results.")
								 or . == "fairness_score" or . == "content_safety_score"
								 or . == "risk_management_score") | not
							)
						],
						evaluator_fields: [
							.required_metrics[]
							| select(
								startswith("metrics.") or startswith("evaluation.")
								or startswith("summary.") or startswith("results.")
								or . == "fairness_score" or . == "content_safety_score"
								or . == "risk_management_score"
							)
						]
					}
				] | sort_by(.title // .package)
			}
		]
	}
	' >"${OUT_DIR}/manifest.json"

echo "  manifest.json: $(jq '[.frameworks[].policy_count] | add' "${OUT_DIR}/manifest.json") policies across ${built} frameworks"

# ---------------------------------------------------------------------------
# --verify: the samples must produce the verdicts we claim they do.
# ---------------------------------------------------------------------------
# Without this the samples drift from the policies, which is the failure this
# repo has already had with hand-maintained coverage figures and version strings.
if [ "${MODE}" = "verify" ]; then
	expected="${SAMPLE_DIR}/expected.json"
	if [ ! -f "${expected}" ]; then
		echo "error: --verify needs ${expected}" >&2
		exit 1
	fi
	echo ""
	echo "Verifying samples against ${expected} using the opa binary"
	failures=0
	while IFS=$'\t' read -r fw entrypoint want; do
		slug="$(slug_of "${fw}")"
		sample="${OUT_DIR}/samples/${slug}.json"
		[ -f "${sample}" ] || { echo "  MISSING sample ${sample}" >&2; failures=$((failures+1)); continue; }
		query="data.$(printf '%s' "${entrypoint}" | tr '/' '.')"
		got=$(opa eval --data "${fw}" --data helper_functions --data global/v1/common \
			--ignore '.github' --ignore '*.yml' --ignore '*.yaml' --ignore '*.json' \
			--input "${sample}" "${query}" --format json 2>/dev/null |
			jq -r 'if (.result | length) == 0 then "undefined" else (.result[0].expressions[0].value | tostring) end')
		if [ "${got}" = "${want}" ]; then
			printf '  ok   %-58s %s\n' "${entrypoint}" "${got}"
		else
			printf '  FAIL %-58s want %s, got %s\n' "${entrypoint}" "${want}" "${got}" >&2
			failures=$((failures + 1))
		fi
	done < <(jq -r '.[] | .framework as $f | .expect | to_entries[] | [$f, .key, (.value|tostring)] | @tsv' "${expected}")

	echo ""
	if [ "${failures}" -gt 0 ]; then
		echo "${failures} sample verdict(s) did not match ${expected}." >&2
		echo "Either a policy changed meaning, or the sample needs updating." >&2
		exit 1
	fi
	echo "All sample verdicts match."
fi

echo ""
echo "Wrote ${OUT_DIR}/ (${built} frameworks)."
