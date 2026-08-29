# RequiredMetrics:
#   - governance.ai_policy_approved
#   - governance.system_in_inventory
#   - governance.accountable_owner_named
#   - governance.review_cadence_days
#   - governance.staff_training_completed
#   - third_party.vendor_in_use
#   - third_party.due_diligence_completed
#
# RequiredParams: none
package operational.corporate.v1.governance

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Corporate AI Governance Requirements",
	"description": "Evaluates the organisational scaffolding around an AI system: an approved AI policy, the system recorded in an inventory, a named accountable owner, a defined review cadence, staff training, and due diligence where a third-party vendor supplies the system. These are the controls an ISO/IEC 42001 management system and the NIST AI RMF Govern function both expect, expressed as checks rather than prose.",
	"version": "1.0.0",
	"category": "Operational",
	"references": [
		"ISO/IEC 42001:2023, AI management systems",
		"NIST AI RMF 1.0, Govern function",
		"OECD AI Principles, accountability",
	],
}

default policy_approved := false

policy_approved if {
	declarations.resolve(input, ["governance", "ai_policy_approved"]) == true
}

# An AI system nobody has recorded cannot be governed.
default inventoried := false

inventoried if {
	declarations.resolve(input, ["governance", "system_in_inventory"]) == true
}

default owner_named := false

owner_named if {
	declarations.resolve(input, ["governance", "accountable_owner_named"]) == true
}

# A review cadence of zero or an absent cadence is not a cadence.
default review_cadence_defined := false

review_cadence_defined if {
	cadence := object.get(input, ["governance", "review_cadence_days"], 0)
	cadence > 0
	cadence <= 365
}

default staff_trained := false

staff_trained if {
	declarations.resolve(input, ["governance", "staff_training_completed"]) == true
}

default vendor_in_use := false

vendor_in_use if {
	declarations.resolve(input, ["third_party", "vendor_in_use"]) == true
}

default third_party_cleared := false

third_party_cleared if {
	not vendor_in_use
}

third_party_cleared if {
	vendor_in_use
	declarations.resolve(input, ["third_party", "due_diligence_completed"]) == true
}

default allow := false

allow if {
	policy_approved
	inventoried
	owner_named
	review_cadence_defined
	staff_trained
	third_party_cleared
}

failed_controls := [name |
	some name, satisfied in {
		"approved AI policy": policy_approved,
		"system recorded in an AI inventory": inventoried,
		"named accountable owner": owner_named,
		"review cadence defined and no longer than annual": review_cadence_defined,
		"staff training completed": staff_trained,
		"third-party due diligence where a vendor supplies the system": third_party_cleared,
	}
	satisfied == false
]

policy_metrics := {
	"governance_controls_failed": {
		"name": "Corporate AI Governance Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"review_cadence_days": {
		"name": "Review Cadence (Days)",
		"value": object.get(input, ["governance", "review_cadence_days"], 0),
		"control_passed": review_cadence_defined,
	},
	"third_party_supply": {
		"name": "Third-Party Vendor Supplies This System",
		"value": vendor_in_use,
		"control_passed": third_party_cleared,
	},
}

report := reporting.compose_report("corporate.governance", allow, policy_metrics)
