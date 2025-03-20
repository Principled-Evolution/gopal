package international.eu_ai_act.v1.documentation.technical_documentation

import data.helper_functions.reporting
import data.helper_functions.validation
import rego.v1

# RequiredMetrics:
#   - metrics.model_card.completeness
#   - metrics.model_card.quality
#   - metrics.model_card.compliance_level
#   - metrics.model_card.section_scores
#
# RequiredParams:
#   - completeness_threshold (default 0.8)
#   - quality_threshold (default 0.8)

# Default deny
default allow := false

# Allow if documentation meets all requirements
allow if {
	completeness_sufficient
	quality_sufficient
	compliance_level_acceptable
}

# Define the required input fields
required_fields := [
	"metrics.model_card.completeness",
	"metrics.model_card.quality",
	"metrics.model_card.compliance_level",
	"metrics.model_card.section_scores",
]

# Define metrics that must be reported for this policy
policy_metrics := {
	"completeness": {
		"name": "Documentation Completeness",
		"value": completeness_sufficient,
		"control_passed": completeness_sufficient == true,
	},
	"quality": {
		"name": "Documentation Quality",
		"value": quality_sufficient,
		"control_passed": quality_sufficient == true,
	},
	"compliance_level": {
		"name": "Compliance Level Acceptable",
		"value": compliance_level_acceptable,
		"control_passed": compliance_level_acceptable == true,
	},
}

policy_name := "EU AI Act Technical Documentation Requirements"

# Input validation
default input_validation_result := {
	"is_valid": false,
	"missing": ["validation-failed"],
}

input_validation_result := validation.validate_required_fields(required_fields, input)

# Metadata
metadata := {
	"title": "EU AI Act Technical Documentation Requirements",
	"description": "Policy to evaluate compliance with EU AI Act Articles 11, 12, and 53 documentation requirements",
	"version": "1.0.0",
	"references": [
		"Article 11 of the EU AI Act - Technical documentation",
		"Article 12 of the EU AI Act - Record-keeping",
		"Article 53 of the EU AI Act - Transparency obligations",
	],
	"category": "international/eu_ai_act/documentation",
	"import_path": "international.eu_ai_act.v1.documentation.technical_documentation",
}

# Rule definitions
default completeness_sufficient := false

completeness_sufficient if {
	score := input.metrics.model_card.completeness
	threshold := object.get(input.params, "completeness_threshold", 0.8)
	score >= threshold
}

default quality_sufficient := false

quality_sufficient if {
	score := input.metrics.model_card.quality
	threshold := object.get(input.params, "quality_threshold", 0.8)
	score >= threshold
}

default compliance_level_acceptable := false

compliance_level_acceptable if {
	input.metrics.model_card.compliance_level >= 0.8
}

# Recommendations based on section scores
missing_sections := [section |
	some section, score in input.metrics.model_card.section_scores
	score < 0.8
]

default documentation_recs := []

documentation_recs := array.concat(
	["Improve documentation completeness to meet EU AI Act requirements"],
	[sprintf("Complete missing or insufficient section: %v", [section]) | some section in missing_sections],
) if {
	not completeness_sufficient
}

default quality_recs := []

quality_recs := ["Improve documentation quality to meet EU AI Act standards"] if {
	not quality_sufficient
}

recommendations := array.concat(documentation_recs, quality_recs)

# Generate the standardized report output
report_output := reporting.compose_report(policy_name, allow, policy_metrics)
