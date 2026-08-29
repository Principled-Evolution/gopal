# RequiredMetrics:
#   - decision_system.decision_logging_enabled
#   - decision_system.explainable
#   - decision_system.override_capability
#
# RequiredParams: none
package industry_specific.aviation.v1.autonomous_systems.decision_making

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Autonomous Decision-Making Transparency",
	"description": "Evaluates whether an autonomous flight decision system logs its decisions, can explain them, and can be overridden.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"EASA Concept Paper: First usable guidance for Level 1 & 2 machine learning applications, Issue 2",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["decision_system", "decision_logging_enabled"]) == true
	declarations.resolve(input, ["decision_system", "explainable"]) == true
	declarations.resolve(input, ["decision_system", "override_capability"]) == true
}

policy_metrics := {
	"decision_logging_enabled": {
		"name": "Decision Logging Enabled",
		"value": object.get(input.decision_system, "decision_logging_enabled", false),
		"control_passed": object.get(input.decision_system, "decision_logging_enabled", false) == true,
	},
	"decision_explainable": {
		"name": "Decisions Explainable",
		"value": object.get(input.decision_system, "explainable", false),
		"control_passed": object.get(input.decision_system, "explainable", false) == true,
	},
	"override_capability": {
		"name": "Human Override Capability",
		"value": object.get(input.decision_system, "override_capability", false),
		"control_passed": object.get(input.decision_system, "override_capability", false) == true,
	},
}

report := reporting.compose_report("aviation.autonomous_systems.decision_making", allow, policy_metrics)
