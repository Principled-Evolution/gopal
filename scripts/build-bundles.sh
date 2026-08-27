#!/usr/bin/env bash
#
# Build one OPA bundle per framework, plus a bundle of everything.
#
# Most people want a subset. Somebody enforcing the EU AI Act has no use for the
# aviation or FERPA policies, and asking them to vendor the whole tree to get 29
# files is a real adoption cost. Each framework bundle here is self-contained:
# it carries the framework's policies plus the shared libraries they import, so
# it loads and evaluates on its own with no other GOPAL files present.
#
# Usage:
#   scripts/build-bundles.sh              # build into dist/
#   scripts/build-bundles.sh --out DIR    # build somewhere else
#   scripts/build-bundles.sh --list       # print what would be built
#
# Requires: opa, jq.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

OUT_DIR="dist"
LIST_ONLY=false
while [ $# -gt 0 ]; do
	case "$1" in
		--out)
			OUT_DIR="${2:?--out needs a directory}"
			shift 2
			;;
		--list)
			LIST_ONLY=true
			shift
			;;
		*)
			echo "Unknown flag: $1" >&2
			echo "Usage: scripts/build-bundles.sh [--out DIR] [--list]" >&2
			exit 2
			;;
	esac
done

for tool in opa jq; do
	command -v "${tool}" >/dev/null 2>&1 || {
		echo "error: ${tool} is required but not on PATH" >&2
		exit 1
	}
done

COVERAGE="docs/coverage/coverage.json"
[ -f "${COVERAGE}" ] || {
	echo "error: ${COVERAGE} not found. Run scripts/generate-coverage.sh first." >&2
	exit 1
}

VERSION="$(tr -d ' \n' <VERSION 2>/dev/null || echo 0.0.0)"
REVISION="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

# Every framework imports these and nothing else outside itself, which
# scripts/generate-coverage.sh data and a scan of the import graph both confirm.
# They are copied into each bundle so it stands alone.
SHARED_ROOTS=(helper_functions global/v1/common)

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

# Frameworks worth shipping on their own. helper_functions is excluded because a
# bundle of nothing but shared libraries reaches no verdict.
mapfile -t FRAMEWORKS < <(jq -r '.frameworks[] | select(.kind != "library") | .id' "${COVERAGE}")

if [ "${LIST_ONLY}" = true ]; then
	printf '%s\n' "Would build into ${OUT_DIR}/ at version ${VERSION} (revision ${REVISION}):"
	for fw in "${FRAMEWORKS[@]}"; do
		slug="${fw//\//-}"
		count="$(jq -r --arg id "${fw}" '.frameworks[] | select(.id == $id) | .policy_count' "${COVERAGE}")"
		printf '  gopal-%s-%s.tar.gz  (%s policies)\n' "${slug}" "${VERSION}" "${count}"
	done
	printf '  gopal-all-%s.tar.gz\n' "${VERSION}"
	exit 0
fi

mkdir -p "${OUT_DIR}"

# Stage the given roots into a clean tree, preserving paths so package names
# still resolve, and dropping tests since consumers do not run them.
stage_roots() {
	local dest="$1"
	shift
	rm -rf "${dest}"
	mkdir -p "${dest}"
	local root
	for root in "$@"; do
		[ -d "${root}" ] || continue
		find "${root}" -type f -name '*.rego' -not -name '*_test.rego' -print0 |
			while IFS= read -r -d '' f; do
				mkdir -p "${dest}/$(dirname "${f}")"
				cp "${f}" "${dest}/${f}"
			done
	done
}

# Declaring roots explicitly keeps a bundle's scope visible and lets OPA reject a
# bundle that reaches outside it. Roots are data paths, so the dots in a package
# name become slashes.
write_manifest() {
	local dest="$1" revision="$2"
	shift 2
	local roots_json
	roots_json="$(printf '%s\n' "$@" | jq -R -s 'split("\n") | map(select(length > 0))')"
	jq -n \
		--arg revision "${revision}" \
		--argjson roots "${roots_json}" \
		'{revision: $revision, roots: $roots}' >"${dest}/.manifest"
}

built=0
failed=0

build_bundle() {
	local name="$1" stage="$2"
	shift 2
	local out="${OUT_DIR}/${name}"
	if ! opa build -b "${stage}" -o "${out}" >"${TMP}/build.log" 2>&1; then
		echo "  FAILED to build ${name}" >&2
		sed 's/^/    /' "${TMP}/build.log" >&2
		failed=$((failed + 1))
		return 1
	fi
	built=$((built + 1))
	return 0
}

# A bundle that builds but cannot answer a question is not much use, so each one
# is loaded back and asked for a real decision from its own framework.
smoke_test() {
	local bundle="$1" fw="$2"
	local pkg rule query
	pkg="$(jq -r --arg id "${fw}" '
		.frameworks[] | select(.id == $id) | .policies
		| map(select((.is_library | not) and (.decision_rules | length) > 0))
		| first
		| if . == null then empty else "\(.package)|\(.decision_rules[0].name)" end
	' "${COVERAGE}")"
	[ -n "${pkg}" ] || return 0
	rule="${pkg##*|}"
	pkg="${pkg%%|*}"
	query="data.${pkg}.${rule}"
	echo '{}' >"${TMP}/empty.json"
	local result
	if ! result="$(opa eval -b "${bundle}" --input "${TMP}/empty.json" "${query}" --format raw 2>"${TMP}/eval.log")"; then
		echo "  FAILED smoke test for ${fw}: ${query} did not evaluate" >&2
		sed 's/^/    /' "${TMP}/eval.log" >&2
		return 1
	fi
	# Empty input must deny. Every policy in the library is tested for this, so a
	# bundle that answers otherwise has lost files it needed.
	if [ "${result}" != "false" ]; then
		echo "  FAILED smoke test for ${fw}: ${query} returned '${result}' on empty input, expected false" >&2
		return 1
	fi
	return 0
}

echo "Building GOPAL ${VERSION} bundles (revision ${REVISION}) into ${OUT_DIR}/"

for fw in "${FRAMEWORKS[@]}"; do
	slug="${fw//\//-}"
	name="gopal-${slug}-${VERSION}.tar.gz"
	stage="${TMP}/stage-${slug}"

	roots=("${fw}")
	for shared in "${SHARED_ROOTS[@]}"; do
		# Skip a shared root the framework already contains, e.g. global.
		case "${shared}" in
			"${fw}"/*) continue ;;
		esac
		roots+=("${shared}")
	done

	stage_roots "${stage}" "${roots[@]}"
	write_manifest "${stage}" "${REVISION}" "${roots[@]}"

	if build_bundle "${name}" "${stage}"; then
		if smoke_test "${OUT_DIR}/${name}" "${fw}"; then
			policies="$(find "${stage}/${fw}" -name '*.rego' 2>/dev/null | wc -l | tr -d ' ')"
			size="$(du -h "${OUT_DIR}/${name}" | cut -f1)"
			printf '  %-46s %4s  %s policies\n' "${name}" "${size}" "${policies}"
		else
			failed=$((failed + 1))
		fi
	fi
done

# The everything bundle, for anyone who does want the whole library or needs two
# frameworks at once, since the per-framework bundles overlap on the shared roots
# and so cannot be loaded side by side.
all_stage="${TMP}/stage-all"
mapfile -t all_roots < <(jq -r '.frameworks[].id' "${COVERAGE}")
stage_roots "${all_stage}" "${all_roots[@]}"
write_manifest "${all_stage}" "${REVISION}" "${all_roots[@]}"
all_name="gopal-all-${VERSION}.tar.gz"
if build_bundle "${all_name}" "${all_stage}"; then
	size="$(du -h "${OUT_DIR}/${all_name}" | cut -f1)"
	policies="$(find "${all_stage}" -name '*.rego' | wc -l | tr -d ' ')"
	printf '  %-46s %4s  %s policies\n' "${all_name}" "${size}" "${policies}"
fi

# Checksums, so a release artifact can be verified after download.
(cd "${OUT_DIR}" && sha256sum gopal-*-"${VERSION}".tar.gz >"gopal-${VERSION}-checksums.txt")

echo ""
echo "Built ${built} bundles. Failed: ${failed}."
echo "Checksums: ${OUT_DIR}/gopal-${VERSION}-checksums.txt"
[ "${failed}" -eq 0 ] || exit 1
