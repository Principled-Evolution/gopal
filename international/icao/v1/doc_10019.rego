# RequiredMetrics:
#   - system.c2_link.lost_link_procedure_defined
#   - system.detect_and_avoid.equipped
#   - system.remote_pilot.qualified
#
# RequiredParams: none
package international.icao.v1.doc_10019

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "ICAO Doc 10019 - Manual on RPAS",
	"description": "Evaluates command and control link resilience, detect-and-avoid capability, and remote pilot qualification for remotely piloted aircraft systems.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"ICAO Doc 10019 - Manual on Remotely Piloted Aircraft Systems, Chapter 3 (C2 Link) and Chapter 9 (Detect and Avoid)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["system", "c2_link", "lost_link_procedure_defined"]) == true
	declarations.resolve(input, ["system", "detect_and_avoid", "equipped"]) == true
	declarations.resolve(input, ["system", "remote_pilot", "qualified"]) == true
}

policy_metrics := {
	"lost_link_procedure_defined": {
		"name": "Lost Link Procedure Defined",
		"value": object.get(declarations.resolve(input, ["system", "c2_link"]), "lost_link_procedure_defined", false),
		"control_passed": object.get(declarations.resolve(input, ["system", "c2_link"]), "lost_link_procedure_defined", false) == true,
	},
	"detect_and_avoid_equipped": {
		"name": "Detect and Avoid Equipped",
		"value": object.get(declarations.resolve(input, ["system", "detect_and_avoid"]), "equipped", false),
		"control_passed": object.get(declarations.resolve(input, ["system", "detect_and_avoid"]), "equipped", false) == true,
	},
	"remote_pilot_qualified": {
		"name": "Remote Pilot Qualified",
		"value": object.get(declarations.resolve(input, ["system", "remote_pilot"]), "qualified", false),
		"control_passed": object.get(declarations.resolve(input, ["system", "remote_pilot"]), "qualified", false) == true,
	},
}

report := reporting.compose_report("icao.doc_10019", allow, policy_metrics)
