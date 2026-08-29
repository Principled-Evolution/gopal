# RequiredMetrics:
#   - ai_system.safety_validation_completed
#   - ai_system.fail_safe_mechanism_present
#   - ai_system.performance_monitoring_enabled
#
# RequiredParams: none
package industry_specific.aviation.v1.autonomous_systems.ai_safety

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation AI Safety Requirements",
	"description": "Evaluates AI safety validation, fail-safe mechanisms, and performance monitoring for autonomous aviation systems.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"EASA Concept Paper: First usable guidance for Level 1 & 2 machine learning applications, Issue 2",
		"ICAO Doc 10019 - Manual on RPAS, Chapter 3",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["ai_system", "safety_validation_completed"]) == true
	declarations.resolve(input, ["ai_system", "fail_safe_mechanism_present"]) == true
	declarations.resolve(input, ["ai_system", "performance_monitoring_enabled"]) == true
}

policy_metrics := {
	"safety_validation_completed": {
		"name": "Safety Validation Completed",
		"value": object.get(input.ai_system, "safety_validation_completed", false),
		"control_passed": object.get(input.ai_system, "safety_validation_completed", false) == true,
	},
	"fail_safe_mechanism_present": {
		"name": "Fail-Safe Mechanism Present",
		"value": object.get(input.ai_system, "fail_safe_mechanism_present", false),
		"control_passed": object.get(input.ai_system, "fail_safe_mechanism_present", false) == true,
	},
	"performance_monitoring_enabled": {
		"name": "Performance Monitoring Enabled",
		"value": object.get(input.ai_system, "performance_monitoring_enabled", false),
		"control_passed": object.get(input.ai_system, "performance_monitoring_enabled", false) == true,
	},
}

report := reporting.compose_report("aviation.autonomous_systems.ai_safety", allow, policy_metrics)
