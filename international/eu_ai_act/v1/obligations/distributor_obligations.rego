# RequiredMetrics:
#   - system.high_risk
#   - distributor.verified_ce_marking
#   - distributor.verified_declaration_and_instructions
#   - distributor.verified_provider_and_importer_compliance
#   - distributor.storage_and_transport_conditions_adequate
#   - distributor.non_conformity_discovered
#   - distributor.corrective_action_taken
#
# RequiredParams: none
package international.eu_ai_act.v1.obligations.distributor_obligations

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Distributor Obligations (Article 24)",
	"description": "Evaluates a distributor of a high-risk AI system against Article 24. The distributor verifies CE marking, the declaration of conformity and instructions, and that the provider and importer met their own obligations, before making the system available. Article 24(4) adds a continuing duty: where a distributor discovers a system it has already made available is non-conforming, corrective action is required rather than optional.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 24 of the EU AI Act, obligations of distributors",
		"Article 24(4), corrective action after a system has been made available",
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
	"Article 24(1) CE marking verified": "verified_ce_marking",
	"Article 24(1) declaration of conformity and instructions verified": "verified_declaration_and_instructions",
	"Article 24(1) provider and importer obligations verified": "verified_provider_and_importer_compliance",
	"Article 24(3) storage and transport conditions do not jeopardise compliance": "storage_and_transport_conditions_adequate",
}

unmet contains label if {
	some label, field in verifications
	object.get(input, ["distributor", field], false) != true
}

default verifications_met := false

verifications_met if {
	count(unmet) == 0
}

# Article 24(4): the duty continues after the system has been made available.
default conformity_issue_found := false

conformity_issue_found if {
	input.distributor.non_conformity_discovered == true
}

default corrective_duty_met := false

corrective_duty_met if {
	not conformity_issue_found
}

corrective_duty_met if {
	conformity_issue_found
	input.distributor.corrective_action_taken == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	verifications_met
	corrective_duty_met
}

policy_metrics := {
	"article_24_verifications_unmet": {
		"name": "Article 24 Verifications Not Met",
		"value": sort([o | some o in unmet]),
		"control_passed": verifications_met,
	},
	"corrective_action_where_required": {
		"name": "Article 24(4) Corrective Action Taken Where Non-Conformity Was Discovered",
		"value": conformity_issue_found,
		"control_passed": corrective_duty_met,
	},
}

report := reporting.compose_report("eu_ai_act.obligations.distributor_obligations", allow, policy_metrics)
