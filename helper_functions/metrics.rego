# METADATA
# description: |
#   The canonical name for every measured metric.
#
#   A measured metric is one an evaluator computes: a toxicity score, a fairness
#   disparity. Policies grew up reading them under whatever path their author
#   chose, and the same number ended up with several names. Content safety had
#   six. `loan_evaluation/fair_lending` read one spelling while
#   `industry_specific/healthcare/.../diagnostic_safety` read another, for the
#   same number from the same evaluator.
#
#   That made the library hard to supply. An evaluator author had to populate
#   every spelling to satisfy every policy, and there was no way to discover
#   which spellings existed without reading the Rego.
#
#   This file fixes the canonical name as `metrics.<domain>.<name>`. Until
#   2.0.0 it also carried 20 legacy spellings as fallbacks; those are gone, and
#   `CHANGELOG.md` lists what to send instead. A retired name now reads as
#   absent, and a policy that requires the metric denies, so a missed rename
#   shows up as a system that stops passing rather than one that wrongly passes.
#
#   Resolution is still first-match in declared order, which is why the
#   candidate list is built as an array comprehension rather than iterated with
#   `some`: an unordered search over several matching paths would let OPA pick
#   any of them. That ordering is what a future deprecation will need, and
#   `deprecated` and `deprecated_since` below are the mechanism for one.
package helper_functions.metrics

import rego.v1

# METADATA
# description: |
#   Canonical metric name to the paths that may carry it, most preferred first.
#   Every entry names only itself since 2.0.0. The list stays a list because
#   that is the shape a deprecation needs: a new spelling is added ahead of the
#   old one, and `deprecated_since` dates the old one.
aliases := {
	"metrics.content_safety.score": [
		["metrics", "content_safety", "score"],
	],
	"metrics.fairness.score": [
		["metrics", "fairness", "score"],
	],
	"metrics.risk_management.score": [
		["metrics", "risk_management", "score"],
	],
	# Two different statistics, deliberately not merged.
	#
	# `score` is an aggregate over many outputs and is compared against a 0.1
	# default threshold throughout global/. `max_toxicity` is the single worst
	# output observed and is compared against 0.7 in the EU transparency
	# policy. A 0.1 threshold only makes sense for an aggregate: feed a
	# worst-case maximum into it and almost any real system fails, which does
	# not make the check safely stricter, it makes it useless and ignored.
	#
	# An earlier version of this table listed max_toxicity as a spelling of
	# score. It is not. They answer different questions.
	"metrics.toxicity.score": [
		["metrics", "toxicity", "score"],
	],
	"metrics.toxicity.max_toxicity": [
		["metrics", "toxicity", "max_toxicity"],
	],
	"metrics.model_card.completeness": [
		["metrics", "model_card", "completeness"],
	],
	"metrics.patient_safety.score": [
		["metrics", "patient_safety", "score"],
	],
	"metrics.clinical_validation.score": [
		["metrics", "clinical_validation", "score"],
	],
	"metrics.risk_assessment.score": [
		["metrics", "risk_assessment", "score"],
	],
	"metrics.audit_logging.completeness": [
		["metrics", "audit_logging", "completeness"],
	],
}

# METADATA
# description: |
#   The value of a canonical metric, or undefined when no spelling carries it.
#
#   Undefined rather than a zero default, deliberately. In Rego an undefined
#   value is not `false` and it is not `0`: it means the evaluator did not
#   supply this metric, which is a different statement from "the metric was
#   measured and came out at zero". A policy that treats an absent toxicity
#   score as 0.0 reports an unmeasured system as safe.
resolve(doc, canonical) := value if {
	found := [v |
		some path in aliases[canonical]
		v := object.get(doc, path, null)
		v != null
	]
	count(found) > 0
	value := found[0]
}

# METADATA
# description: |
#   The value of a canonical metric, or an explicit fallback when no spelling
#   carries it.
#
#   For callers that already treat absence as a definite outcome. Several
#   policies read a score with `object.get(..., -1)` so that a missing metric
#   compares below every threshold and is therefore counted as a failure.
#   Migrating those to `resolve` alone would turn a deliberate fail-closed
#   sentinel into an undefined comparison, and the failure would stop being
#   counted at all. Keep the sentinel, and pass it here.
resolve_or(doc, canonical, fallback) := value if {
	value := resolve(doc, canonical)
} else := fallback

# METADATA
# description: |
#   When each legacy spelling was deprecated, as a version rather than a date.
#
#   The timer lives here, in data, because a deprecation recorded only in a
#   changelog is a deprecation somebody has to remember. scripts/check-deprecations.sh
#   reads this and refuses to let a major version ship while matured entries
#   remain, which is the one moment the question actually has to be answered.
#
#   Dates were the obvious alternative and are worse. This library releases when
#   there is something to release, so a calendar deadline either arrives between
#   releases and means nothing, or ages into a date nobody chose. Releases are
#   what a consumer actually upgrades across.
#
#   A caveat worth stating plainly: GOPAL sends nothing anywhere, so we will
#   never observe that somebody uses one of these. `deprecated` reports to the
#   caller, not to us. Silence here is not evidence of disuse, it is the absence
#   of evidence, and the window exists so that a user has a release in which to
#   notice and object rather than so that we can measure anything.
deprecated_since[name] := "1.4.0" if {
	some canonical, paths in aliases
	some path in paths
	name := concat(".", path)
	name != canonical
}

# METADATA
# description: |
#   The legacy spellings an input used, mapped to what it should send instead.
#
#   Empty now, because the table carries no legacy spellings: 2.0.0 removed the
#   20 it had. The rule stays because it is the mechanism for the next
#   deprecation, and because a caller can keep asking the question without
#   knowing whether the answer is currently always empty.
#
#   It reports to the caller running the policy, never back to us. GOPAL makes
#   no outbound calls and collects nothing, so the absence of complaints about a
#   retired spelling is the absence of evidence and not evidence of absence.
#   `docs/COMPATIBILITY.md` sets out what follows from that.
deprecated(doc) := {legacy: canonical |
	some canonical, paths in aliases
	some path in paths
	concat(".", path) != canonical
	object.get(doc, path, null) != null
	legacy := concat(".", path)
}

# METADATA
# description: |
#   True when some spelling of the metric is present. Useful where a policy
#   needs to distinguish "not supplied" from a supplied value, without
#   inspecting the value itself.
# scope: document
default supplied(_, _) := false

supplied(doc, canonical) if resolve(doc, canonical) != null
