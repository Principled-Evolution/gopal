# RequiredMetrics:
#   - firm.retail_customers_affected
#   - cross_cutting.good_faith_assessment_completed
#   - cross_cutting.foreseeable_harm_assessment_completed
#   - outcomes.target_market_defined
#   - ai.customer_facing
#   - ai.decision_explainable_in_plain_language
#   - accountability.smf_owner_assigned
#
# RequiredParams: none
package industry_specific.bfs.v1.uk_fca_consumer_duty

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "FCA Consumer Duty for AI-Affected Retail Outcomes (PRIN 2A)",
	"description": "Evaluates an AI system that touches a retail customer journey against the FCA Consumer Duty. The FCA has introduced no AI-specific rules, so AI is supervised through the existing Consumer Duty, SM&CR and governance expectations. This policy tests the three cross-cutting obligations, the four retail customer outcomes, and the AI-specific consequence the FCA has been clearest about: a firm must be able to explain a customer-affecting decision in terms that customer can understand.",
	"version": "1.0.0",
	"category": "Industry Specific",
	"references": [
		"FCA Handbook PRIN 2A, the Consumer Duty",
		"FCA Handbook PRIN 2A.2, cross-cutting obligations (good faith, avoid foreseeable harm, support customer objectives)",
		"FCA Handbook PRIN 2A.3 to PRIN 2A.6, the four retail customer outcomes",
		"FCA FS25/5, AI Live Testing feedback statement",
		"FCA Senior Managers and Certification Regime (SM&CR)",
	],
}

# The Duty engages where retail customers are affected. This must be asserted
# rather than inferred from an absent field.
default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["firm", "retail_customers_affected"]))
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["firm", "retail_customers_affected"]) == true
}

# PRIN 2A.2: act in good faith, avoid foreseeable harm, and enable and support
# customers to pursue their financial objectives.
default cross_cutting_met := false

cross_cutting_met if {
	declarations.resolve(input, ["cross_cutting", "good_faith_assessment_completed"]) == true
	declarations.resolve(input, ["cross_cutting", "foreseeable_harm_assessment_completed"]) == true
	declarations.resolve(input, ["cross_cutting", "supports_customer_objectives"]) == true
}

# PRIN 2A.3 to 2A.6: the four retail customer outcomes.
default outcomes_met := false

outcomes_met if {
	declarations.resolve(input, ["outcomes", "target_market_defined"]) == true
	declarations.resolve(input, ["outcomes", "fair_value_assessment_completed"]) == true
	declarations.resolve(input, ["outcomes", "communications_tested_for_understanding"]) == true
	declarations.resolve(input, ["outcomes", "support_channels_free_of_unreasonable_barriers"]) == true
}

# A firm that cannot articulate why a decision was reached, in terms the
# customer can follow, cannot evidence the consumer understanding outcome.
default customer_facing := false

customer_facing if {
	declarations.resolve(input, ["ai", "customer_facing"]) == true
}

default ai_explainability_met := false

ai_explainability_met if {
	not customer_facing
}

ai_explainability_met if {
	customer_facing
	declarations.resolve(input, ["ai", "decision_explainable_in_plain_language"]) == true
	declarations.resolve(input, ["ai", "vulnerable_customer_handling_documented"]) == true
	declarations.resolve(input, ["ai", "outcomes_monitoring_data_collected"]) == true
}

# SM&CR attaches individual accountability for the system to a named person.
default accountability_met := false

accountability_met if {
	declarations.resolve(input, ["accountability", "smf_owner_assigned"]) == true
}

default allow := false

# Out of scope: no retail customers are affected.
allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	cross_cutting_met
	outcomes_met
	ai_explainability_met
	accountability_met
}

failed_requirements := [name |
	some name, satisfied in {
		"PRIN 2A.2 cross-cutting obligations": cross_cutting_met,
		"PRIN 2A.3-2A.6 retail customer outcomes": outcomes_met,
		"customer-facing AI explainability and vulnerable customer handling": ai_explainability_met,
		"SM&CR named senior manager accountability": accountability_met,
	}
	satisfied == false
]

policy_metrics := {
	"consumer_duty_requirements_failed": {
		"name": "Consumer Duty Requirements Not Satisfied",
		"value": sort(failed_requirements),
		"control_passed": count(failed_requirements) == 0,
	},
	"explainable_to_the_customer": {
		"name": "Customer-Affecting Decision Explainable in Plain Language",
		"value": object.get(input, ["ai", "decision_explainable_in_plain_language"], false),
		"control_passed": ai_explainability_met,
	},
	"named_senior_manager": {
		"name": "SM&CR Senior Manager Assigned to the AI System",
		"value": object.get(input, ["accountability", "smf_owner_assigned"], false),
		"control_passed": accountability_met,
	},
}

report := reporting.compose_report("bfs.uk_fca_consumer_duty", allow, policy_metrics)
