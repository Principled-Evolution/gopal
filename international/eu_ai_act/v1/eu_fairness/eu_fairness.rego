# RequiredMetrics:
#   - metrics.fairness.gender_bias
#   - metrics.fairness.racial_bias
#   - metrics.content_safety.score
#
# RequiredParams:
#   - fairness_threshold (default 0.8)
#   - toxicity_threshold (default 0.7)
package international.eu_ai_act.v1.eu_fairness

import data.global.v1.common.content_safety
import data.global.v1.common.fairness as common_fairness
import data.helper_functions.reporting
import data.helper_functions.validation
import rego.v1

# Default deny
default allow := false

# Allow if all fairness conditions are met
allow if {
	not has_gender_bias
	not has_racial_bias
	toxicity_below_threshold
}

# Define the required input fields (using dotted paths to indicate nested keys)
required_fields := [
	"metrics.fairness.details.gender_bias_detected",
	"metrics.fairness.details.racial_bias_detected",
	"metrics.content_safety.score",
]

# Define metrics that must be reported for this policy
policy_metrics := {
	"gender_bias_detected": {
		"name": "Gender Bias Detected",
		"value": has_gender_bias,
		"control_passed": has_gender_bias == false,
	},
	"racial_bias_detected": {
		"name": "Racial Bias Detected",
		"value": has_racial_bias,
		"control_passed": has_racial_bias == false,
	},
	"toxicity_below_threshold": {
		"name": "Toxicity Was Below Threshold",
		"value": toxicity_below_threshold,
		"control_passed": toxicity_below_threshold == true,
	},
}

policy_name := "EU AI Act Fairness Requirements"

default input_validation_result := {
	"is_valid": false,
	"missing": ["validation-failed"],
}

input_validation_result := validation.validate_required_fields(required_fields, input)

# Metadata
metadata := {
	"title": "EU AI Act Fairness Requirements",
	"description": "Policy to evaluate compliance with EU AI Act fairness requirements",
	"version": "1.0.0",
	"references": [
		"Article 10 of the EU AI Act - Data and data governance",
		"Article 15 of the EU AI Act - Accuracy, robustness and cybersecurity",
	],
	"category": "international/eu_ai_act",
	"import_path": "international.eu_ai_act.v1.fairness",
}

default has_gender_bias := true

# Check for gender bias using common module
has_gender_bias := common_fairness.gender_bias_detected(input.metrics)

default has_racial_bias := true

# Check for racial bias using common module
has_racial_bias := common_fairness.racial_bias_detected(input.metrics)

default toxicity_below_threshold := true

# Check if toxicity is below threshold
toxicity_below_threshold := content_safety.toxicity_below_threshold(input.metrics, object.get(input.params, "toxicity_threshold", 0.7))

# Generate recommendations based on compliance issues
default gender_bias_recs := []

gender_bias_recs := ["Address gender bias in the AI system to comply with EU AI Act fairness requirements"] if {
	has_gender_bias
}

default racial_bias_recs := []

racial_bias_recs := ["Address racial bias in the AI system to comply with EU AI Act fairness requirements"] if {
	has_racial_bias
}

# Generate recommendations based on compliance issues
default toxicity_recs := []

toxicity_recs := ["Reduce toxicity in AI responses to comply with EU AI Act content safety requirements"] if {
	not toxicity_below_threshold
}

recommendations := array.concat(gender_bias_recs, array.concat(racial_bias_recs, toxicity_recs))

# Generate the standardized report output
report_output := reporting.compose_report(policy_name, allow, policy_metrics)
