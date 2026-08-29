# RequiredMetrics:
#   - operation.daa_system_equipped
#   - operation.authorization_held
#   - operation.ground_risk_mitigations_in_place
#
# RequiredParams: none
package industry_specific.aviation.v1.flight_operations.bvlos_operations

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Beyond Visual Line of Sight Operations",
	"description": "Evaluates whether a BVLOS operation has detect-and-avoid capability, a governing authorization or waiver, and ground-risk mitigations in place.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"14 CFR Part 107 Subpart D - Waivers (Sec. 107.31 BVLOS)",
		"EASA SORA methodology, ground risk mitigations",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["operation", "daa_system_equipped"]) == true
	declarations.resolve(input, ["operation", "authorization_held"]) == true
	declarations.resolve(input, ["operation", "ground_risk_mitigations_in_place"]) == true
}

policy_metrics := {
	"daa_system_equipped": {
		"name": "Detect and Avoid System Equipped",
		"value": object.get(input.operation, "daa_system_equipped", false),
		"control_passed": object.get(input.operation, "daa_system_equipped", false) == true,
	},
	"authorization_held": {
		"name": "Authorization or Waiver Held",
		"value": object.get(input.operation, "authorization_held", false),
		"control_passed": object.get(input.operation, "authorization_held", false) == true,
	},
	"ground_risk_mitigations_in_place": {
		"name": "Ground Risk Mitigations in Place",
		"value": object.get(input.operation, "ground_risk_mitigations_in_place", false),
		"control_passed": object.get(input.operation, "ground_risk_mitigations_in_place", false) == true,
	},
}

report := reporting.compose_report("aviation.flight_operations.bvlos_operations", allow, policy_metrics)
