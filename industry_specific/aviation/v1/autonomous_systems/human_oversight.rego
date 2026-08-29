# RequiredMetrics:
#   - oversight.remote_pilot_monitoring
#   - oversight.intervention_capability
#   - oversight.handover_procedure_defined
#
# RequiredParams: none
package industry_specific.aviation.v1.autonomous_systems.human_oversight

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Human Oversight of Autonomous Operation",
	"description": "Evaluates whether an autonomous aviation system maintains active remote-pilot monitoring, a real-time intervention capability, and a defined handover procedure.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"ICAO Doc 10019 - Manual on RPAS, Chapter 3 (C2 Link and Human Factors)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["oversight", "remote_pilot_monitoring"]) == true
	declarations.resolve(input, ["oversight", "intervention_capability"]) == true
	declarations.resolve(input, ["oversight", "handover_procedure_defined"]) == true
}

policy_metrics := {
	"remote_pilot_monitoring": {
		"name": "Remote Pilot Monitoring Active",
		"value": object.get(input.oversight, "remote_pilot_monitoring", false),
		"control_passed": object.get(input.oversight, "remote_pilot_monitoring", false) == true,
	},
	"intervention_capability": {
		"name": "Intervention Capability Present",
		"value": object.get(input.oversight, "intervention_capability", false),
		"control_passed": object.get(input.oversight, "intervention_capability", false) == true,
	},
	"handover_procedure_defined": {
		"name": "Handover Procedure Defined",
		"value": object.get(input.oversight, "handover_procedure_defined", false),
		"control_passed": object.get(input.oversight, "handover_procedure_defined", false) == true,
	},
}

report := reporting.compose_report("aviation.autonomous_systems.human_oversight", allow, policy_metrics)
