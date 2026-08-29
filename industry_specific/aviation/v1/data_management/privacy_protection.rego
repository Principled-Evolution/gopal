# RequiredMetrics:
#   - privacy.data_minimization_applied
#   - privacy.consent_or_legal_basis
#
# RequiredParams: none
package industry_specific.aviation.v1.data_management.privacy_protection

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Sensor Data Privacy Protection",
	"description": "Evaluates whether camera and sensor data collected during flight (which may capture third parties or private property) applies data minimization and has a lawful basis for collection.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"EASA Easy Access Rules for Unmanned Aircraft Systems, Article 5 (Rules for UAS operations conducted... with regard to privacy)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["privacy", "data_minimization_applied"]) == true
	declarations.resolve(input, ["privacy", "consent_or_legal_basis"]) == true
}

policy_metrics := {
	"data_minimization_applied": {
		"name": "Data Minimization Applied",
		"value": object.get(input.privacy, "data_minimization_applied", false),
		"control_passed": object.get(input.privacy, "data_minimization_applied", false) == true,
	},
	"consent_or_legal_basis": {
		"name": "Consent or Legal Basis Established",
		"value": object.get(input.privacy, "consent_or_legal_basis", false),
		"control_passed": object.get(input.privacy, "consent_or_legal_basis", false) == true,
	},
}

report := reporting.compose_report("aviation.data_management.privacy_protection", allow, policy_metrics)
