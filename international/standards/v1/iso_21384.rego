# RequiredMetrics:
#   - safety_management.system_established
#   - safety_management.risk_assessment_completed
#   - operations.procedures_documented
#
# RequiredParams: none
package international.standards.v1.iso_21384

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "ISO 21384 - UAS General Requirements",
	"description": "Evaluates UAS operator compliance with ISO 21384 general requirements: an established safety management system, completed risk assessment, and documented operational procedures.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"ISO 21384-1:2019 - Unmanned aircraft systems, Part 1: General requirements",
		"ISO 21384-3:2023 - Unmanned aircraft systems, Part 3: Operational procedures",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["safety_management", "system_established"]) == true
	declarations.resolve(input, ["safety_management", "risk_assessment_completed"]) == true
	declarations.resolve(input, ["operations", "procedures_documented"]) == true
}

policy_metrics := {
	"safety_management_system_established": {
		"name": "Safety Management System Established",
		"value": object.get(input.safety_management, "system_established", false),
		"control_passed": object.get(input.safety_management, "system_established", false) == true,
	},
	"risk_assessment_completed": {
		"name": "Risk Assessment Completed",
		"value": object.get(input.safety_management, "risk_assessment_completed", false),
		"control_passed": object.get(input.safety_management, "risk_assessment_completed", false) == true,
	},
	"operational_procedures_documented": {
		"name": "Operational Procedures Documented",
		"value": object.get(input.operations, "procedures_documented", false),
		"control_passed": object.get(input.operations, "procedures_documented", false) == true,
	},
}

report := reporting.compose_report("standards.iso_21384", allow, policy_metrics)
