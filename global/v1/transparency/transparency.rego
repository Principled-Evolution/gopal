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

# Define the compliance report
compliance_report := {
	"policy": "Global Transparency Policy",
	"version": "1.0.0",
	"overall_result": allow,
	"details": {
		"model_card_exists": object.get(input.documentation, ["model_card", "exists"], false),
		"model_card_completeness": object.get(input.documentation, ["model_card", "completeness_score"], 0),
		"model_card_completeness_threshold": object.get(input, ["params", "model_card_completeness_threshold"], 0.8),
		"explainability_provided": object.get(input.documentation, ["explainability", "provided"], false),
		"limitations_documented": object.get(input.documentation, ["limitations", "documented"], false),
		"use_cases_defined": object.get(input.documentation, ["use_cases", "defined"], false),
	},
	"recommendations": recommendations,
}

# Generate recommendations based on compliance issues
recommendations := model_card_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == false
}

recommendations := model_card_completeness_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness < object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
}

recommendations := explainability_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == false
}

recommendations := limitations_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == true
	declarations.resolve(input, ["documentation", "limitations", "documented"]) == false
}

recommendations := use_cases_recs if {
	declarations.resolve(input, ["documentation", "model_card", "exists"]) == true
	model_card_completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
	declarations.resolve(input, ["documentation", "explainability", "provided"]) == true
	declarations.resolve(input, ["documentation", "limitations", "documented"]) == true
	declarations.resolve(input, ["documentation", "use_cases", "defined"]) == false
}

recommendations := [] if {
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
