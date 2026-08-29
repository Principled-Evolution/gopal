# RequiredMetrics:
#   - data_sharing.agreement_in_place
#   - data_sharing.recipient_authorized
#
# RequiredParams: none
package industry_specific.aviation.v1.data_management.data_sharing

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Flight Data Sharing",
	"description": "Evaluates whether flight data shared with third parties (ATC, regulators, fleet operators) has a data-sharing agreement in place and the recipient is authorized.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"ICAO Doc 10019 - Manual on RPAS, Chapter 3 (C2 Link data)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["data_sharing", "agreement_in_place"]) == true
	declarations.resolve(input, ["data_sharing", "recipient_authorized"]) == true
}

policy_metrics := {
	"agreement_in_place": {
		"name": "Data Sharing Agreement in Place",
		"value": object.get(input.data_sharing, "agreement_in_place", false),
		"control_passed": object.get(input.data_sharing, "agreement_in_place", false) == true,
	},
	"recipient_authorized": {
		"name": "Recipient Authorized",
		"value": object.get(input.data_sharing, "recipient_authorized", false),
		"control_passed": object.get(input.data_sharing, "recipient_authorized", false) == true,
	},
}

report := reporting.compose_report("aviation.data_management.data_sharing", allow, policy_metrics)
