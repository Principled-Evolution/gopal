# RequiredMetrics:
#   - system.affects_individuals
#   - redress.route_to_contest_available
#   - redress.route_communicated
#   - redress.human_review_available
#   - redress.response_timeframe_days
#
# RequiredParams: none
package international.uk.v1.contestability_redress

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "UK AI Principle 5 - Contestability and Redress",
	"description": "Evaluates whether users, impacted third parties and other actors can contest an AI decision or outcome that is harmful or creates a material risk of harm. The principle is qualified by 'where appropriate', so this policy engages the requirement only where the system affects individuals or carries material harm potential. A route that exists but is never communicated does not satisfy it. Non-statutory guidance.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"A pro-innovation approach to AI regulation, CP 815 (March 2023), principle: contestability and redress",
		"Implementing the UK's AI regulatory principles: initial guidance for regulators (DSIT, February 2024)",
	],
}

# As with the ADM policy, "the principle does not engage" has to be asserted
# rather than inferred from an empty input.
default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "affects_individuals"]))
}

default allow := false

# Where the principle does not engage, it is not a finding against the system.
allow if {
	scope_determined
	not contestability_required
}

allow if {
	contestability_required
	route_available
	route_communicated
	human_review_available
	timeframe_defined
}

default contestability_required := false

contestability_required if {
	declarations.resolve(input, ["system", "affects_individuals"]) == true
}

contestability_required if {
	declarations.resolve(input, ["system", "material_harm_potential"]) == true
}

default route_available := false

route_available if {
	declarations.resolve(input, ["redress", "route_to_contest_available"]) == true
}

default route_communicated := false

route_communicated if {
	declarations.resolve(input, ["redress", "route_communicated"]) == true
}

default human_review_available := false

human_review_available if {
	declarations.resolve(input, ["redress", "human_review_available"]) == true
}

default timeframe_defined := false

timeframe_defined if {
	object.get(input, ["redress", "response_timeframe_days"], 0) > 0
}

policy_metrics := {
	"principle_engaged": {
		"name": "Contestability Requirement Engaged",
		"value": contestability_required,
		"control_passed": true,
	},
	"route_to_contest": {
		"name": "Route to Contest Available and Communicated",
		"value": route_available,
		"control_passed": allow,
	},
	"human_review": {
		"name": "Human Review of Contested Outcomes Available",
		"value": human_review_available,
		"control_passed": allow,
	},
	"response_timeframe": {
		"name": "Defined Response Timeframe (Days)",
		"value": object.get(input, ["redress", "response_timeframe_days"], 0),
		"control_passed": allow,
	},
}

report := reporting.compose_report("uk.contestability_redress", allow, policy_metrics)
