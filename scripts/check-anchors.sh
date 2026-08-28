#!/usr/bin/env bash
#
# Verify that every in-document anchor link resolves to a real heading.
#
# The README carries a "Jump to" nav, and a nav whose targets have been renamed
# is worse than no nav: it looks maintained and lands the reader nowhere. This
# repo has form here. A release once shipped with the banner claiming 96
# policies and the panel directly beneath it saying 91, because nothing checked
# that the two agreed.
#
# GitHub derives a heading's anchor by lowercasing it, dropping everything that
# is not a letter, digit, space or hyphen, then replacing spaces with hyphens.
# "For OPA / Rego users" becomes "for-opa--rego-users": the slash vanishes and
# the two spaces around it each become a hyphen. Getting that wrong in either
# direction is the whole reason this is a script and not a careful reading.
#
# Usage: check-anchors.sh [FILE...]   (defaults to README.md and docs/**/*.md)

set -euo pipefail

if [ $# -gt 0 ]; then
	files=("$@")
else
	mapfile -t files < <(printf '%s\n' README.md; find docs -name '*.md' | sort)
fi

status=0

for file in "${files[@]}"; do
	[ -f "$file" ] || continue

	# Anchors GitHub will generate for this file's headings.
	anchors=$(grep -E '^#{1,6} ' "$file" 2>/dev/null | sed -E 's/^#+ +//' |
		tr '[:upper:]' '[:lower:]' |
		sed -E 's/`//g; s/<[^>]*>//g' |
		sed -E 's/[^a-z0-9 -]//g' |
		sed -E 's/ /-/g' || true)

	# Same-document links, from both markdown and inline HTML.
	targets=$( {
		grep -oE '\]\(#[^)]+\)' "$file" 2>/dev/null | sed -E 's/^\]\(#//; s/\)$//'
		grep -oE 'href="#[^"]+"' "$file" 2>/dev/null | sed -E 's/^href="#//; s/"$//'
	} | sort -u || true)

	[ -n "$targets" ] || continue

	while IFS= read -r target; do
		[ -n "$target" ] || continue
		if ! printf '%s\n' "$anchors" | grep -qxF "$target"; then
			echo "$file: #$target does not match any heading" >&2
			status=1
		fi
	done <<<"$targets"
done

if [ "$status" -eq 0 ]; then
	echo "All in-document anchors resolve."
else
	echo "" >&2
	echo "A heading was renamed without its links, or a link was mistyped." >&2
fi

exit "$status"
