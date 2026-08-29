# RequiredMetrics:
#   - system.high_risk
#   - system.annex_iii_category
#   - assessment.procedure
#   - assessment.harmonised_standards_applied
#   - assessment.notified_body_involved
#   - assessment.completed
#
# RequiredParams: none
package international.eu_ai_act.v1.compliance.conformity_assessment

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Conformity Assessment (Article 43)",
	"description": "Evaluates which conformity assessment route a high-risk AI system must follow. The distinction Article 43 draws is easy to get wrong: for the biometric systems in Annex III point 1 a provider may use internal control under Annex VI only where it has applied the harmonised standards, and otherwise must involve a notified body under Annex VII. For Annex III points 2 to 8, internal control is the route.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 43(1) of the EU AI Act, conformity assessment for Annex III point 1 systems",
		"Article 43(2) of the EU AI Act, conformity assessment for Annex III points 2 to 8",
		"Annex VI, conformity assessment based on internal control",
		"Annex VII, conformity based on assessment of the quality management system and technical documentation",
	],
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "high_risk"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "high_risk"]))
}

default biometric_category := false

biometric_category if {
	declarations.resolve(input, ["system", "annex_iii_category"]) == 1
}

default internal_control_route := false

internal_control_route if {
	declarations.resolve(input, ["assessment", "procedure"]) == "annex_vi_internal_control"
}

default notified_body_route := false

notified_body_route if {
	declarations.resolve(input, ["assessment", "procedure"]) == "annex_vii_notified_body"
	declarations.resolve(input, ["assessment", "notified_body_involved"]) == true
}

# Annex III point 1: internal control is available only where the harmonised
# standards were applied.
default route_permitted := false

route_permitted if {
	not biometric_category
	internal_control_route
}

route_permitted if {
	not biometric_category
	notified_body_route
}

route_permitted if {
	biometric_category
	internal_control_route
	declarations.resolve(input, ["assessment", "harmonised_standards_applied"]) == true
}

route_permitted if {
	biometric_category
	notified_body_route
}

default assessment_completed := false

assessment_completed if {
	declarations.resolve(input, ["assessment", "completed"]) == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	route_permitted
	assessment_completed
}

policy_metrics := {
	"assessment_route": {
		"name": "Conformity Assessment Route Used",
		"value": object.get(input, ["assessment", "procedure"], "none"),
		"control_passed": route_permitted,
	},
	"route_permitted_for_category": {
		"name": "Route Permitted for the Annex III Category",
		"value": route_permitted,
		"control_passed": route_permitted,
	},
	"assessment_completed": {
		"name": "Conformity Assessment Completed",
		"value": assessment_completed,
		"control_passed": assessment_completed,
	},
}

report := reporting.compose_report("eu_ai_act.compliance.conformity_assessment", allow, policy_metrics)
