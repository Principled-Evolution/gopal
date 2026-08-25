# RequiredMetrics:
#   - transparency.ai_use_disclosed
#   - transparency.system_purpose_documented
#   - explainability.decision_rationale_available
#   - explainability.method_documented
#   - system.impact_level
#
# RequiredParams: none
package international.uk.v1.transparency_explainability

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "UK AI Principle 2 - Appropriate Transparency and Explainability",
	"description": "Evaluates whether an AI system is appropriately transparent and explainable. The UK principle is explicitly proportionate: what counts as appropriate scales with the impact of the system, so a high-impact system must additionally document the explainability method it relies on. Non-statutory guidance, not a statutory test.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"A pro-innovation approach to AI regulation, CP 815 (March 2023), principle: appropriate transparency and explainability",
		"Implementing the UK's AI regulatory principles: initial guidance for regulators (DSIT, February 2024)",
	],
}

default allow := false

allow if {
	baseline_transparency
	not high_impact
}

allow if {
	baseline_transparency
	high_impact
	explainability_method_documented
}

default baseline_transparency := false

baseline_transparency if {
	input.transparency.ai_use_disclosed == true
	input.transparency.system_purpose_documented == true
	input.explainability.decision_rationale_available == true
}

default high_impact := false

high_impact if {
	input.system.impact_level == "high"
}

default explainability_method_documented := false

explainability_method_documented if {
	input.explainability.method_documented == true
}

policy_metrics := {
	"baseline_transparency": {
		"name": "AI Use Disclosed, Purpose Documented and Rationale Available",
		"value": baseline_transparency,
		"control_passed": baseline_transparency,
	},
	"proportionate_to_impact": {
		"name": "Explainability Proportionate to System Impact",
		"value": object.get(input, ["system", "impact_level"], "unknown"),
		"control_passed": allow,
	},
}

report := reporting.compose_report("uk.transparency_explainability", allow, policy_metrics)
