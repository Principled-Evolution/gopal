# RequiredMetrics:
#   - assessment.ground_risk_class
#   - assessment.air_risk_class
#   - assessment.sail_determined
#   - mitigations.adequate
#
# RequiredParams: none
package international.easa.v1.sora

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EASA SORA - Specific Operations Risk Assessment",
	"description": "Evaluates whether a Specific-category UAS operation has completed a SORA risk assessment (ground risk class, air risk class, resulting SAIL) with adequate mitigations in place.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"EASA Easy Access Rules for Unmanned Aircraft Systems, SORA methodology (Annex to AMC1 Article 11 of Regulation (EU) 2019/947)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["assessment", "ground_risk_class"]) >= 1
	declarations.resolve(input, ["assessment", "ground_risk_class"]) <= 10
	declarations.resolve(input, ["assessment", "air_risk_class"]) in {"a", "b", "c", "d"}
	declarations.resolve(input, ["assessment", "sail_determined"]) == true
	declarations.resolve(input, ["mitigations", "adequate"]) == true
}

policy_metrics := {
	"ground_risk_class_assessed": {
		"name": "Ground Risk Class Assessed",
		"value": object.get(input.assessment, "ground_risk_class", null),
		"control_passed": object.get(input.assessment, "ground_risk_class", 0) >= 1,
	},
	"air_risk_class_assessed": {
		"name": "Air Risk Class Assessed",
		"value": object.get(input.assessment, "air_risk_class", null),
		"control_passed": object.get(input.assessment, "air_risk_class", "") in {"a", "b", "c", "d"},
	},
	"sail_determined": {
		"name": "SAIL Determined",
		"value": object.get(input.assessment, "sail_determined", false),
		"control_passed": object.get(input.assessment, "sail_determined", false) == true,
	},
	"mitigations_adequate": {
		"name": "Mitigations Adequate for SAIL",
		"value": object.get(input.mitigations, "adequate", false),
		"control_passed": object.get(input.mitigations, "adequate", false) == true,
	},
}

report := reporting.compose_report("easa.sora", allow, policy_metrics)
