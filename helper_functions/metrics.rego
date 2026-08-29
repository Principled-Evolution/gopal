# METADATA
# description: |
#   Canonical names for measured metrics, and the legacy spellings that still
#   resolve to them.
#
#   A measured metric is one an evaluator computes: a toxicity score, a fairness
#   disparity. Policies grew up reading them under whatever path their author
#   chose, and the same number ended up with several names. Content safety had
#   six. `loan_evaluation/fair_lending` reads `evaluation.fairness.score` while
#   `industry_specific/healthcare/.../diagnostic_safety` reads
#   `evaluation.fairness_score`, for the same number from the same evaluator.
#
#   That made the library hard to supply. An evaluator author had to populate
#   every spelling to satisfy every policy, and there was no way to discover
#   which spellings existed without reading the Rego.
#
#   This file fixes the canonical name as `metrics.<domain>.<name>` and keeps
#   every historical spelling working as a fallback, so no existing input
#   breaks. Resolution is first-match in declared order, which is why the
#   candidate list is built as an array comprehension rather than iterated with
#   `some`: an unordered search over several matching paths would let OPA pick
#   any of them.
package helper_functions.metrics

import rego.v1

# METADATA
# description: |
#   Canonical metric name to the paths that may carry it, most preferred first.
#   The canonical path is always first, so an input using the new name wins over
#   one that also carries a legacy name.
aliases := {
	"metrics.content_safety.score": [
		["metrics", "content_safety", "score"],
		["evaluation", "content_safety", "score"],
		["evaluation", "content_safety_score"],
		["content_safety", "score"],
		["content_safety_score"],
	],
	"metrics.fairness.score": [
		["metrics", "fairness", "score"],
		["evaluation", "fairness", "score"],
		["evaluation", "fairness_score"],
		["fairness_score"],
	],
	"metrics.risk_management.score": [
		["metrics", "risk_management", "score"],
		["evaluation", "risk_management", "score"],
		["evaluation", "risk_management_score"],
		["risk_management_score"],
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
		["evaluation", "toxicity_score"],
		["content_safety", "toxicity_score"],
	],
	"metrics.toxicity.max_toxicity": [
		["metrics", "toxicity", "max_toxicity"],
		["summary", "toxicity_values", "max_toxicity"],
		["content_safety", "max_toxicity"],
	],
	"metrics.model_card.completeness": [
		["metrics", "model_card", "completeness"],
		["documentation", "model_card", "completeness_score"],
		["documentation", "model_card", "completeness"],
	],
	"metrics.patient_safety.score": [
		["metrics", "patient_safety", "score"],
		["evaluation", "patient_safety", "score"],
	],
	"metrics.clinical_validation.score": [
		["metrics", "clinical_validation", "score"],
		["evaluation", "clinical_validation", "score"],
	],
	"metrics.risk_assessment.score": [
		["metrics", "risk_assessment", "score"],
		["evaluation", "risk_assessment", "score"],
	],
	"metrics.audit_logging.completeness": [
		["metrics", "audit_logging", "completeness"],
		["governance", "audit_logging", "completeness_score"],
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
#   The legacy spellings an input used, mapped to what it should send instead.
#
#   The alias table exists so that inputs written before this library had a
#   shared vocabulary keep working. That is a debt, and one worth retiring: 18
#   of the 20 legacy names have no user anywhere in this repository, and the
#   policies themselves all read through `resolve` now.
#
#   Retiring them on taste would be guessing. This rule turns the question into
#   evidence: a report can say which legacy name an input actually used, and
#   after a release the ones nobody sends can go at the next major version,
#   which is what `v1/` is a boundary for.
#
#   Empty when an input uses only canonical names, which is the state this is
#   trying to reach.
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
