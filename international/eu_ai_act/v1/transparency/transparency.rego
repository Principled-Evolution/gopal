# RequiredMetrics:
#   - documentation.technical_documentation.completeness
#   - documentation.explainability.completeness
#   - metrics.model_card.completeness
#   - metrics.toxicity.max_toxicity
#
# RequiredParams: none
#
package international.eu_ai_act.v1.transparency

import data.helper_functions.declarations
import data.helper_functions.metrics
import rego.v1

# Metadata
metadata := {
	"title": "EU AI Act Transparency Requirements",
	"description": "Policy to evaluate compliance with EU AI Act transparency requirements",
	"version": "1.0.0",
	"references": [
		"Article 13 of the EU AI Act, transparency and provision of information to deployers",
	],
	"category": "international/eu_ai_act",
	"import_path": "international.eu_ai_act.v1.transparency",
}

# METADATA
# title: EU AI Act Article 13 transparency decision
# description: |
#   An entrypoint in the OPA sense: scripts/build-playground.sh compiles this
#   rule into the international/eu_ai_act WASM module and the playground calls
#   it directly.
#
#   The annotation used to sit on global/v1/common/common_rules, a library with
#   no decision rule and no importers, which was not an entrypoint at all. It
#   was deleted in 2.0.0 and the annotation moved somewhere it is true.
# entrypoint: true
default allow := false

# Allow rule
allow if {
	has_documentation
	documentation_completeness_sufficient
	toxicity_within_threshold
}

# Default compliance report
default compliance_report := {
	"policy_name": "EU AI Act Transparency Requirements",
	"compliant": false,
	"reason": "Transparency requirements not met",
	"recommendations": ["Ensure proper documentation and transparency measures are in place"],
}

# Generate compliance report
compliance_report := {
	"policy_name": "EU AI Act Transparency Requirements",
	"compliant": allow,
	"reason": compliance_reason,
	"recommendations": compliance_recommendations,
}

# Check if documentation exists
has_documentation if {
	input.documentation
}

# Check if documentation completeness is sufficient
documentation_completeness_sufficient if {
	declarations.resolve(input, ["documentation", "technical_documentation", "completeness"]) >= 0.7
	metrics.resolve(input, "metrics.model_card.completeness") >= 0.7
	declarations.resolve(input, ["documentation", "explainability", "completeness"]) >= 0.7
}

# Toxicity, as three separate questions rather than one.
#
# `not has_high_toxicity` used to stand in for "toxicity is acceptable", and it
# does not. An absent measurement makes has_high_toxicity undefined, undefined
# negates to true, and a system nobody ever tested passed the toxicity condition
# of Article 13. Allow now requires a reading that is actually below the
# threshold, so unmeasured denies and says why.
toxicity_measured if {
	metrics.resolve_or(input, "metrics.toxicity.max_toxicity", null) != null
}

toxicity_within_threshold if {
	metrics.resolve(input, "metrics.toxicity.max_toxicity") <= 0.7
}

has_high_toxicity if {
	metrics.resolve(input, "metrics.toxicity.max_toxicity") > 0.7
}

# The reason texts, named so the decision chain below stays readable as a
# chain rather than as a wall of prose.
reasons := {
	"met": "The system meets EU AI Act transparency requirements with sufficient documentation and low toxicity levels",
	"no_documentation": "The system does not meet EU AI Act transparency requirements due to missing documentation",
	"incomplete": concat(" ", [
		"The system's documentation is not sufficiently complete to",
		"meet EU AI Act transparency requirements",
	]),
	"unmeasured_toxicity": concat(" ", [
		"The system's output toxicity has not been measured, so EU AI Act",
		"transparency requirements cannot be shown to be met",
	]),
	"high_toxicity": concat(" ", [
		"The system's content has high toxicity levels which",
		"violates EU AI Act transparency requirements",
	]),
	"incomplete_and_toxic": concat(" ", [
		"The system fails to meet EU AI Act transparency requirements due to",
		"incomplete documentation and high toxicity levels",
	]),
	"incomplete_and_unmeasured": concat(" ", [
		"The system's documentation is incomplete and its output toxicity has",
		"not been measured, so EU AI Act transparency requirements cannot be",
		"shown to be met",
	]),
}

# Generate reason for compliance decision using else := syntax
default compliance_reason := "The system does not meet EU AI Act transparency requirements for unknown reasons"

# Ordered most specific first. Every branch tests a positive fact or the
# negation of a total rule; none says `not has_high_toxicity`, because that is
# true both when toxicity is low and when it was never measured, which is the
# conflation that let an untested system satisfy `allow`.
compliance_reason := reasons.met if {
	allow
} else := reasons.no_documentation if {
	not has_documentation
} else := reasons.incomplete_and_unmeasured if {
	not documentation_completeness_sufficient
	not toxicity_measured
} else := reasons.incomplete_and_toxic if {
	not documentation_completeness_sufficient
	has_high_toxicity
} else := reasons.incomplete if {
	not documentation_completeness_sufficient
} else := reasons.unmeasured_toxicity if {
	not toxicity_measured
} else := reasons.high_toxicity if {
	has_high_toxicity
}

# Generate recommendations based on non-compliance issues using else := syntax
default compliance_recommendations := ["Review all transparency requirements in the EU AI Act and ensure compliance"]

compliance_recommendations := [] if {
	allow
} else := recommendations if {
	not has_documentation
	recommendations := [concat(" ", [
		"Provide comprehensive technical documentation, model cards,",
		"and explainability information",
	])]
} else := recommendations if {
	has_documentation
	not documentation_completeness_sufficient
	not has_high_toxicity
	recommendations := [concat(" ", [
		"Improve the completeness of technical documentation, model cards,",
		"and explainability information",
	])]
} else := recommendations if {
	has_documentation
	has_high_toxicity
	not documentation_completeness_sufficient
	recommendations := [
		"Reduce toxicity levels in system outputs to comply with EU AI Act requirements",
		"Improve the completeness of technical documentation, model cards, and explainability information",
	]
} else := recommendations if {
	has_documentation
	has_high_toxicity
	documentation_completeness_sufficient
	recommendations := ["Reduce toxicity levels in system outputs to comply with EU AI Act requirements"]
}
