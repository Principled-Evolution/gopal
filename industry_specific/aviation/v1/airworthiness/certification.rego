# RequiredMetrics:
#   - aircraft.type_certificate_held
#   - aircraft.airworthiness_directive_compliant
#
# RequiredParams: none
package industry_specific.aviation.v1.airworthiness.certification

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Type Certification",
	"description": "Evaluates whether an aircraft holds a valid type certificate and is compliant with all applicable airworthiness directives.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"ICAO Annex 8 - Airworthiness of Aircraft",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["aircraft", "type_certificate_held"]) == true
	declarations.resolve(input, ["aircraft", "airworthiness_directive_compliant"]) == true
}

policy_metrics := {
	"type_certificate_held": {
		"name": "Type Certificate Held",
		"value": object.get(input.aircraft, "type_certificate_held", false),
		"control_passed": object.get(input.aircraft, "type_certificate_held", false) == true,
	},
	"airworthiness_directive_compliant": {
		"name": "Airworthiness Directive Compliant",
		"value": object.get(input.aircraft, "airworthiness_directive_compliant", false),
		"control_passed": object.get(input.aircraft, "airworthiness_directive_compliant", false) == true,
	},
}

report := reporting.compose_report("aviation.airworthiness.certification", allow, policy_metrics)
