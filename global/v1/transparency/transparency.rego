# RequiredMetrics:
#   - documentation.model_card.exists
#   - documentation.model_card.completeness_score
#   - documentation.explainability.provided
#   - documentation.limitations.documented
#   - documentation.use_cases.defined
#
# RequiredParams:
#   - model_card_completeness_threshold (default 0.8)
#
package global.v1.transparency

import rego.v1

# Replace comment-based metadata with proper metadata object
metadata := {
	"title": "Global Transparency Policy",
	"description": "General transparency requirements for AI systems",
	"version": "1.0.0",
	"category": "Global",
	"references": ["AICertify Transparency Standards"],
}

# Default deny
default allow := false

# Allow if transparency requirements are satisfied
allow if {
	# Check if model cards exist and are complete
	input.documentation.model_card.exists == true
	input.documentation.model_card.completeness_score >= object.get(input.params, "model_card_completeness_threshold", 0.8)

	# Check if explainability is provided
	input.documentation.explainability.provided == true

	# Check if limitations are documented
	input.documentation.limitations.documented == true

	# Check if use cases are clearly defined
	input.documentation.use_cases.defined == true
}

# Non-compliant rules for reporting
non_compliant if {
	input.documentation.model_card.exists == false
}

non_compliant if {
	input.documentation.model_card.exists == true
	input.documentation.model_card.completeness_score < object.get(input.params, "model_card_completeness_threshold", 0.8)
}

non_compliant if {
	input.documentation.explainability.provided == false
}

non_compliant if {
	input.documentation.limitations.documented == false
}

non_compliant if {
	input.documentation.use_cases.defined == false
}

# Define the compliance report
compliance_report := {
	"policy": "Global Transparency Policy",
	"version": "1.0.0",
	"overall_result": allow,
	"details": {
		"model_card_exists": object.get(input.documentation, ["model_card", "exists"], false),
		"model_card_completeness": object.get(input.documentation, ["model_card", "completeness_score"], 0),
		"model_card_completeness_threshold": object.get(input.params, "model_card_completeness_threshold", 0.8),
		"explainability_provided": object.get(input.documentation, ["explainability", "provided"], false),
		"limitations_documented": object.get(input.documentation, ["limitations", "documented"], false),
		"use_cases_defined": object.get(input.documentation, ["use_cases", "defined"], false),
	},
	"recommendations": recommendations,
}

# Generate recommendations based on compliance issues
recommendations := model_card_recs if {
	input.documentation.model_card.exists == false
}

recommendations := model_card_completeness_recs if {
	input.documentation.model_card.exists == true
	input.documentation.model_card.completeness_score < object.get(input.params, "model_card_completeness_threshold", 0.8)
}

recommendations := explainability_recs if {
	input.documentation.model_card.exists == true
	input.documentation.model_card.completeness_score >= object.get(input.params, "model_card_completeness_threshold", 0.8)
	input.documentation.explainability.provided == false
}

recommendations := limitations_recs if {
	input.documentation.model_card.exists == true
	input.documentation.model_card.completeness_score >= object.get(input.params, "model_card_completeness_threshold", 0.8)
	input.documentation.explainability.provided == true
	input.documentation.limitations.documented == false
}

recommendations := use_cases_recs if {
	input.documentation.model_card.exists == true
	input.documentation.model_card.completeness_score >= object.get(input.params, "model_card_completeness_threshold", 0.8)
	input.documentation.explainability.provided == true
	input.documentation.limitations.documented == true
	input.documentation.use_cases.defined == false
}

recommendations := [] if {
	input.documentation.model_card.exists == true
	input.documentation.model_card.completeness_score >= object.get(input.params, "model_card_completeness_threshold", 0.8)
	input.documentation.explainability.provided == true
	input.documentation.limitations.documented == true
	input.documentation.use_cases.defined == true
}

# Define recommendation values
model_card_recs := ["Create a model card documenting the AI system's properties, capabilities, and limitations"]

model_card_completeness_recs := ["Enhance the model card with more comprehensive information about the AI system"]

explainability_recs := ["Implement explainability mechanisms to help users understand the AI system's decisions"]

limitations_recs := ["Document the known limitations and constraints of the AI system"]

use_cases_recs := ["Clearly define and document the intended use cases for the AI system"]
