# RequiredMetrics:
#   - fairness.bias_assessment_completed
#   - fairness.protected_characteristics_tested
#   - fairness.max_disparity
#   - fairness.legal_rights_review_completed
#
# RequiredParams: none
package international.uk.v1.fairness

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "UK AI Principle 3 - Fairness",
	"description": "Evaluates whether an AI system undermines legal rights, discriminates unfairly against individuals, or creates unfair market outcomes. Unlike the US protected-class model, this policy tests coverage against the nine protected characteristics in the Equality Act 2010. Non-statutory guidance; the underlying Equality Act duties are binding in their own right.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"A pro-innovation approach to AI regulation, CP 815 (March 2023), principle: fairness",
		"Equality Act 2010, Part 2 Chapter 1, section 4 (protected characteristics)",
	],
}

# The nine protected characteristics under Equality Act 2010 s.4.
equality_act_characteristics := {
	"age",
	"disability",
	"gender_reassignment",
	"marriage_and_civil_partnership",
	"pregnancy_and_maternity",
	"race",
	"religion_or_belief",
	"sex",
	"sexual_orientation",
}

default allow := false

allow if {
	input.fairness.bias_assessment_completed == true
	input.fairness.legal_rights_review_completed == true
	all_characteristics_tested
	disparity_within_threshold
}

tested_characteristics := {c | some c in object.get(input, ["fairness", "protected_characteristics_tested"], [])}

untested_characteristics := equality_act_characteristics - tested_characteristics

default all_characteristics_tested := false

all_characteristics_tested if {
	count(untested_characteristics) == 0
}

default disparity_within_threshold := false

disparity_within_threshold if {
	object.get(input, ["fairness", "max_disparity"], 1) <= 0.1
}

policy_metrics := {
	"bias_assessment_completed": {
		"name": "Bias Assessment Completed",
		"value": object.get(input, ["fairness", "bias_assessment_completed"], false),
		"control_passed": object.get(input, ["fairness", "bias_assessment_completed"], false) == true,
	},
	"equality_act_coverage": {
		"name": "Equality Act 2010 Protected Characteristics Tested",
		"value": sort([c | some c in untested_characteristics]),
		"control_passed": all_characteristics_tested,
	},
	"disparity_within_threshold": {
		"name": "Maximum Outcome Disparity Within Threshold",
		"value": object.get(input, ["fairness", "max_disparity"], 1),
		"control_passed": disparity_within_threshold,
	},
	"legal_rights_reviewed": {
		"name": "Effect on Legal Rights Reviewed",
		"value": object.get(input, ["fairness", "legal_rights_review_completed"], false),
		"control_passed": object.get(input, ["fairness", "legal_rights_review_completed"], false) == true,
	},
}

report := reporting.compose_report("uk.fairness", allow, policy_metrics)
