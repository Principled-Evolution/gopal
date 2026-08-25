# RequiredMetrics:
#   - governance.accountable_person_named
#   - governance.oversight_body_in_place
#   - governance.lifecycle_roles_defined
#   - governance.supply_chain_accountability_documented
#
# RequiredParams: none
package international.uk.v1.accountability_governance

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "UK AI Principle 4 - Accountability and Governance",
	"description": "Evaluates whether governance measures provide effective oversight of the supply and use of an AI system, with clear lines of accountability across the lifecycle. Where a third-party or vendor model is in use, accountability for that supply must be documented rather than assumed to sit with the vendor. Non-statutory guidance.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"A pro-innovation approach to AI regulation, CP 815 (March 2023), principle: accountability and governance",
		"Implementing the UK's AI regulatory principles: initial guidance for regulators (DSIT, February 2024)",
	],
}

default allow := false

allow if {
	named_accountability
	oversight_in_place
	not third_party_supply
}

allow if {
	named_accountability
	oversight_in_place
	third_party_supply
	supply_chain_documented
}

default named_accountability := false

named_accountability if {
	input.governance.accountable_person_named == true
	input.governance.lifecycle_roles_defined == true
}

default oversight_in_place := false

oversight_in_place if {
	input.governance.oversight_body_in_place == true
}

default third_party_supply := false

third_party_supply if {
	input.governance.third_party_model_in_use == true
}

default supply_chain_documented := false

supply_chain_documented if {
	input.governance.supply_chain_accountability_documented == true
}

policy_metrics := {
	"named_accountability": {
		"name": "Named Accountable Person and Defined Lifecycle Roles",
		"value": named_accountability,
		"control_passed": named_accountability,
	},
	"oversight_body": {
		"name": "Oversight Body In Place",
		"value": oversight_in_place,
		"control_passed": oversight_in_place,
	},
	"supply_chain_accountability": {
		"name": "Third-Party Supply Accountability Documented Where Applicable",
		"value": object.get(input, ["governance", "third_party_model_in_use"], false),
		"control_passed": allow,
	},
}

report := reporting.compose_report("uk.accountability_governance", allow, policy_metrics)
