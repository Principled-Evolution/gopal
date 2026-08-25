# RequiredMetrics:
#   - system.high_risk
#   - importer.verified_conformity_assessment
#   - importer.verified_technical_documentation
#   - importer.verified_ce_marking_and_declaration
#   - importer.verified_authorised_representative
#   - importer.identification_provided
#   - importer.storage_and_transport_conditions_adequate
#   - importer.documentation_retained_ten_years
#
# RequiredParams: none
package international.eu_ai_act.v1.obligations.importer_obligations

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Importer Obligations (Article 23)",
	"description": "Evaluates an importer of a high-risk AI system against Article 23. The importer's role is verification before placing on the market: that the provider carried out the conformity assessment, drew up the technical documentation, affixed CE marking with a declaration of conformity and instructions, and appointed an authorised representative. Article 23(5) then requires the certificate, declaration and instructions to be kept for ten years.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 23 of the EU AI Act, obligations of importers",
		"Article 23(5), ten-year retention of the certificate, declaration and instructions",
	],
}

default in_scope := false

in_scope if {
	input.system.high_risk == true
}

default scope_determined := false

scope_determined if {
	is_boolean(input.system.high_risk)
}

verifications := {
	"Article 23(1)(a) conformity assessment carried out by the provider": "verified_conformity_assessment",
	"Article 23(1)(b) technical documentation drawn up": "verified_technical_documentation",
	"Article 23(1)(c) CE marking, declaration of conformity and instructions": "verified_ce_marking_and_declaration",
	"Article 23(1)(d) authorised representative appointed": "verified_authorised_representative",
	"Article 23(3) importer identification provided": "identification_provided",
	"Article 23(4) storage and transport conditions do not jeopardise compliance": "storage_and_transport_conditions_adequate",
	"Article 23(5) documentation retained for ten years": "documentation_retained_ten_years",
}

unmet contains label if {
	some label, field in verifications
	object.get(input, ["importer", field], false) != true
}

default all_met := false

all_met if {
	count(unmet) == 0
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	all_met
}

policy_metrics := {
	"article_23_obligations_unmet": {
		"name": "Article 23 Importer Obligations Not Met",
		"value": sort([o | some o in unmet]),
		"control_passed": all_met,
	},
	"pre_market_verification_complete": {
		"name": "Pre-Market Verification Complete",
		"value": all_met,
		"control_passed": all_met,
	},
}

report := reporting.compose_report("eu_ai_act.obligations.importer_obligations", allow, policy_metrics)
