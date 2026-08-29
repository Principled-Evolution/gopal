# RequiredMetrics:
#   - system.high_risk
#   - system.annex_iii_exempt_under_article_6_3
#   - registration.provider_registered
#   - registration.system_registered
#   - registration.registered_before_placing_on_market
#   - registration.annex_viii_information_complete
#   - registration.exemption_assessment_registered
#
# RequiredParams: none
package international.eu_ai_act.v1.compliance.registration

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act EU Database Registration (Article 49)",
	"description": "Evaluates registration of a high-risk AI system in the EU database. Article 49(1) requires the provider and the system to be registered before the system is placed on the market or put into service, with the Annex VIII information. Article 49(2) covers the case a provider is most likely to overlook: where a provider concludes its Annex III system is not high-risk under Article 6(3), that assessment must itself be registered.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 49(1) of the EU AI Act, registration before placing on the market",
		"Article 49(2) of the EU AI Act, registration of an Article 6(3) non-high-risk assessment",
		"Annex VIII, information to be submitted upon registration",
	],
}

# Article 49(2): a provider claiming the Article 6(3) exemption still registers
# that assessment, so this policy engages for that case too.
default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "high_risk"]) == true
}

in_scope if {
	declarations.resolve(input, ["system", "annex_iii_exempt_under_article_6_3"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "high_risk"]))
}

default claims_exemption := false

claims_exemption if {
	declarations.resolve(input, ["system", "annex_iii_exempt_under_article_6_3"]) == true
}

# Article 49(2) route: register the assessment.
default exemption_registered := false

exemption_registered if {
	declarations.resolve(input, ["registration", "exemption_assessment_registered"]) == true
}

# Article 49(1) route: full registration before placing on the market.
default fully_registered := false

fully_registered if {
	declarations.resolve(input, ["registration", "provider_registered"]) == true
	declarations.resolve(input, ["registration", "system_registered"]) == true
	declarations.resolve(input, ["registration", "registered_before_placing_on_market"]) == true
	declarations.resolve(input, ["registration", "annex_viii_information_complete"]) == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	claims_exemption
	exemption_registered
}

allow if {
	scope_determined
	in_scope
	not claims_exemption
	fully_registered
}

policy_metrics := {
	"registered_before_market": {
		"name": "Article 49(1) Registered Before Placing on the Market",
		"value": object.get(input, ["registration", "registered_before_placing_on_market"], false),
		"control_passed": fully_registered,
	},
	"annex_viii_complete": {
		"name": "Annex VIII Registration Information Complete",
		"value": object.get(input, ["registration", "annex_viii_information_complete"], false),
		"control_passed": fully_registered,
	},
	"article_6_3_exemption_registered": {
		"name": "Article 49(2) Non-High-Risk Assessment Registered Where Claimed",
		"value": claims_exemption,
		"control_passed": allow,
	},
}

report := reporting.compose_report("eu_ai_act.compliance.registration", allow, policy_metrics)
