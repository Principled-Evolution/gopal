#!/usr/bin/env bash
#
# List every `input` field a policy reads, derived from the policy itself.
#
# The coverage data used to take this from a hand-written `# RequiredMetrics:`
# comment block, and 22 of 98 policies read `input` while declaring nothing at
# all — the comments had drifted from the code exactly the way the coverage
# figures once did. Anything downstream that asks "what does this policy need?"
# — the question form in the playground, contract scaffolding in AICertify — was
# therefore incomplete, and had no way to know it.
#
# So it is derived from the AST instead. Two forms have to be recognised, and
# missing the second is what a regex over the source would do:
#
#   input.system.high_risk                          a plain ref
#   object.get(input, ["system", "sources"], [])    a path passed as an argument
#   object.get(input.params, "threshold", 0.8)      a ref plus a literal key
#
# The second form is used 284 times in this library, precisely because it is how
# a field is read without the whole rule going undefined when it is absent. A
# ref walk alone reports almost nothing for those policies.
#
# Paths are truncated at the first non-literal segment: `input.a[x].b` yields
# `a`, since which key is read is not known statically. Callers prune those
# prefixes once they have a fuller list to prune against.
#
# This does not replace the comment block. A field name that is computed, as in
# `object.get(input, ["datasets", field], false)` where `field` is bound by a
# loop, cannot be recovered from the AST at all, and there the comment is the
# only record. Consumers union the two.
#
# Usage: extract-input-fields.sh [--types] FILE...
#   Default:   one `field.path` per line, deduplicated, `input.` prefix removed.
#   --types:   `field.path<TAB>kind`, where kind is boolean, number, string,
#              list or empty when no evidence was found.

set -euo pipefail

WITH_TYPES=false
if [ "${1:-}" = "--types" ]; then
	WITH_TYPES=true
	shift
fi

if [ "$#" -eq 0 ]; then
	echo "usage: $(basename "$0") [--types] FILE..." >&2
	exit 2
fi

# The kind is inferred from the literal a field is measured against: the default
# handed to object.get, or the constant on the other side of a comparison. Both
# are firm evidence written by the policy author, which is a better source than
# guessing from the field name and better than reading a sample document, since
# a sample can be missing the field entirely.
JQ_PROGRAM='
def literal_prefix:
	[.[] | if .type == "string" then .value else null end] as $parts
	| ($parts | index(null)) as $stop
	| if $stop then $parts[0:$stop] else $parts end;

def input_ref_path:
	if type == "object"
		and .type == "ref"
		and (.value | type) == "array"
		and (.value | length) > 0
		and .value[0].type == "var"
		and .value[0].value == "input"
	then .value[1:] | literal_prefix
	else null
	end;

def key_path:
	if type == "object" and .type == "array" and (.value | type) == "array"
	then .value | literal_prefix
	elif type == "object" and .type == "string"
	then [.value]
	else null
	end;

def literal_kind:
	if type != "object" then null
	elif .type == "boolean" then "boolean"
	elif .type == "number" then "number"
	elif .type == "string" then "string"
	elif .type == "array" then "list"
	else null
	end;

def is_object_get:
	.value[0].type == "ref"
	and (.value[0].value | length) == 2
	and .value[0].value[0].value == "object"
	and .value[0].value[1].value == "get";

# declarations.resolve(input, ["a", "b"]) and resolve_or(input, [...], fallback).
#
# Declarations used to be read as plain refs, so the ref walk above found them.
# Since they go through the helper, the path is an argument rather than a ref,
# and a walk alone reports 54 fields for the EU framework where there are 185.
# Everything downstream reads this: the coverage data, the question form in the
# playground, and aicertify explain, all of which would quietly ask for almost
# nothing.
# opa parse leaves the import alias unresolved, so the call head is the two
# terms declarations.resolve rather than the fully qualified package path.
def is_declarations_resolve:
	.value[0].type == "ref"
	and (.value[0].value | length) == 2
	and .value[0].value[0].value == "declarations"
	and (.value[0].value[1].value | IN("resolve", "resolve_or"));

def is_comparison:
	.[0].type == "ref"
	and (.[0].value | length) == 1
	and (.[0].value[0].value | IN("equal", "eq", "neq", "lt", "lte", "gt", "gte"));

[
	# A plain ref, with no type evidence of its own.
	(.. | objects | select(.type == "ref") | input_ref_path | select(. != null) | {path: ., kind: null}),

	# object.get(<input ref>, <path>, <default>) — the default gives the kind.
	(
		.. | objects
		| select(.type == "call" and (.value | type) == "array" and (.value | length) >= 3)
		| select(is_object_get)
		| (.value[1] | input_ref_path) as $base
		| (.value[2] | key_path) as $key
		| select($base != null and $key != null)
		| {path: ($base + $key), kind: (.value[3] | literal_kind)}
	),

	# declarations.resolve(input, <path>) — the path is the second argument.
	(
		.. | objects
		| select(.type == "call" and (.value | type) == "array" and (.value | length) >= 3)
		| select(is_declarations_resolve)
		| (.value[1] | input_ref_path) as $base
		| (.value[2] | key_path) as $key
		| select($base != null and $key != null)
		| {path: ($base + $key), kind: (.value[3] | literal_kind)}
	),

	# metrics.resolve(input, "metrics.a.b") — the canonical name is a string
	# rather than a path array, so it needs its own branch. These reads were
	# plain input refs before the metrics helper existed too.
	(
		.. | objects
		| select(.type == "call" and (.value | type) == "array" and (.value | length) >= 3)
		| select(
			.value[0].type == "ref"
			and (.value[0].value | length) == 2
			and .value[0].value[0].value == "metrics"
			and (.value[0].value[1].value | IN("resolve", "resolve_or"))
		)
		| select(.value[2].type == "string")
		| {path: (.value[2].value | split(".")), kind: "number"}
	),

	# A comparison against a constant, in either argument order.
	(
		.. | objects
		| select((.terms | type) == "array" and (.terms | length) == 3)
		| .terms
		| select(is_comparison)
		| (
			({path: (.[1] | input_ref_path), kind: (.[2] | literal_kind)}),
			({path: (.[2] | input_ref_path), kind: (.[1] | literal_kind)})
		)
		| select(.path != null)
	)
]
| map(select((.path | length) > 0) | {path: (.path | join(".")), kind})
| group_by(.path)
| map({
	path: .[0].path,
	# Any concrete evidence beats none. Conflicting evidence is possible in
	# principle — a field compared to both a number and a string — and the first
	# is taken rather than dropping the field, since a wrong control is more use
	# than no control.
	kind: ([.[].kind | select(. != null)] | first // "")
})
| .[]
| .path + "\t" + .kind
'

for file in "$@"; do
	# A parse failure is the caller's problem to see, not something to swallow.
	opa parse --format json "${file}" | jq -r "${JQ_PROGRAM}"
done | sort -u | awk -F'\t' '
	# One line per path. A typed line wins over an untyped one for the same path.
	{ if (!($1 in kind) || (kind[$1] == "" && $2 != "")) kind[$1] = $2 }
	END { for (p in kind) print p "\t" kind[p] }
' | sort | if [ "${WITH_TYPES}" = true ]; then cat; else cut -f1; fi
