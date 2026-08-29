# RequiredMetrics:
#   - documentation.model_card.exists
#   - metrics.model_card.completeness
#   - documentation.explainability.provided
#   - documentation.limitations.documented
#   - documentation.use_cases.defined
#
# RequiredParams:
#   - model_card_completeness_threshold (default 0.8)
#
package global.v1.transparency

import data.helper_functions.declarations
import data.helper_functions.metrics
import rego.v1

# Replace comment-based metadata with proper metadata object
metadata := {
	"title": "Global Transparency Policy",
	"description": "General transparency requirements for AI systems",
	"version": "1.0.0",
	"category": "Global",
	"references": ["AICertify Transparency Standards"],
}

# Read through the canonical table rather than one hard-coded path, so a score
# supplied as metrics.model_card.completeness is seen as readily as the legacy
# spelling. resolve, not resolve_or: an absent metric must stay undefined so
# the rule body fails and `default := false` denies. A -1 sentinel is right
# where the comparison is `>=`, and silently wrong where it is `<`, because
# -1 is below every threshold and would let an unevaluated system pass.
model_card_completeness := metrics.resolve(input, "metrics.model_card.completeness")

# Default deny
default allow := false

# Allow if transparency requirements are satisfied
allow if {
	# Check if model cards exist and are complete
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)

	# Check if explainability is provided
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == true

	# Check if limitations are documented
	declarations.resolve(input, ["documentation", "limitations", "documented"]) == true

	# Check if use cases are clearly defined
	declarations.resolve(input, ["documentation", "use_cases", "defined"]) == true
}

# Non-compliant rules for reporting
non_compliant if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == false
}

non_compliant if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness < object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
}

non_compliant if {
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == false
}

non_compliant if {
	declarations.resolve(input, ["documentation", "limitations", "documented"]) == false
}

non_compliant if {
	declarations.resolve(input, ["documentation", "use_cases", "defined"]) == false
}

# What the report shows for model card completeness.
#
# `model_card_completeness` above is undefined when no score was supplied. The
# decision rules simply fail and `default allow := false` denies, which is the
# safe direction. A report has no such default: an undefined rule here makes the
# whole compliance_report object vanish rather than saying anything, so the
# finding is lost quietly instead of being reported.
#
# Until 2.0.0 this read documentation.model_card.completeness_score with a
# fallback of 0, and an unmeasured system was reported identically to one that
# scored zero. Those are different findings for different people: zero means the
# card is empty, null means nobody has looked.
#
# null rather than 0 or -1, because it is the one value no rubric can produce,
# so it cannot be mistaken for a score in either direction.
default reported_model_card_completeness := null

reported_model_card_completeness := metrics.resolve(input, "metrics.model_card.completeness")

# Define the compliance report
compliance_report := {
	"policy": "Global Transparency Policy",
	"version": "1.0.0",
	"overall_result": allow,
	"details": {
		"model_card_exists": object.get(input, ["documentation", "model_card", "exists"], false),
		"model_card_completeness": reported_model_card_completeness,
		"model_card_completeness_threshold": object.get(input, ["params", "model_card_completeness_threshold"], 0.8),
		"explainability_provided": object.get(input, ["documentation", "explainability", "provided"], false),
		"limitations_documented": object.get(input, ["documentation", "limitations", "documented"], false),
		"use_cases_defined": object.get(input, ["documentation", "use_cases", "defined"], false),
	},
	"recommendations": recommendations,
}

# Generate recommendations based on compliance issues
# Every branch below is conditional, and each one that mentions completeness is
# undefined when no score was supplied. None fires, recommendations goes
# undefined, and an undefined value inside compliance_report deletes the whole
# report. The submission with the least evidence produced no report at all.
# What to recommend when no branch above matched.
#
# Every branch is conditional, and each one that mentions completeness is
# undefined when no score was supplied. None fires, and an undefined value
# inside compliance_report deletes the whole report, so the submission with the
# least evidence produced none at all.
#
# The first fix was a fixed string naming completeness. That was wrong often
# enough to matter: a system with completeness of 0.95 and no
# documentation.model_card.exists was told to supply the completeness it had
# already supplied. This names the inputs actually missing instead.
_input_presence := {
	"documentation.model_card.exists": declarations.supplied(input, ["documentation", "model_card", "exists"]),
	"documentation.explainability.provided": declarations.supplied(input, ["documentation", "explainability", "provided"]),
	"documentation.limitations.documented": declarations.supplied(input, ["documentation", "limitations", "documented"]),
	"documentation.use_cases.defined": declarations.supplied(input, ["documentation", "use_cases", "defined"]),
	"metrics.model_card.completeness": metrics.supplied(input, "metrics.model_card.completeness"),
}

# The inputs this policy reads, and whether each arrived. Object iteration in
# Rego is ordered by key, so the list below is stable between runs.
default _unsupplied_recs := ["Every input this policy reads was supplied, but not in a form it recognises. Check the values against the inputs declared at the top of this policy."]

_unsupplied_recs := [sprintf("Supply %v, which this policy reads and did not receive", [name]) |
	some name in _unsupplied_names
] if {
	count(_unsupplied_names) > 0
}

_unsupplied_names := [name |
	some name, present in _input_presence
	not present
]

# One of the branches below matched, or none did and the input is incomplete.
# The two are mutually exclusive, so they cannot conflict.
recommendations := _matched_recommendations if {
	_matched_recommendations
}

recommendations := _unsupplied_recs if {
	not _matched_recommendations
}

_matched_recommendations := model_card_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == false
}

_matched_recommendations := model_card_completeness_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness < object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
}

_matched_recommendations := explainability_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == false
}

_matched_recommendations := limitations_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == true
	declarations.resolve(input, ["documentation", "limitations", "documented"]) == false
}

_matched_recommendations := use_cases_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == true
	declarations.resolve(input, ["documentation", "limitations", "documented"]) == true
	declarations.resolve(input, ["documentation", "use_cases", "defined"]) == false
}

_matched_recommendations := [] if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == true
	declarations.resolve(input, ["documentation", "limitations", "documented"]) == true
	declarations.resolve(input, ["documentation", "use_cases", "defined"]) == true
}

# Define recommendation values
model_card_recs := ["Create a model card documenting the AI system's properties, capabilities, and limitations"]

model_card_completeness_recs := ["Enhance the model card with more comprehensive information about the AI system"]

explainability_recs := ["Implement explainability mechanisms to help users understand the AI system's decisions"]

limitations_recs := ["Document the known limitations and constraints of the AI system"]

use_cases_recs := ["Clearly define and document the intended use cases for the AI system"]
