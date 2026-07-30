# RequiredMetrics:
#   - aircraft.standard_remote_id_equipped
#   - aircraft.broadcast_module_attached
#   - operation.within_fria
#
# RequiredParams: none
package international.faa.v1.remote_id

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "FAA Remote ID (14 CFR Part 89)",
	"description": "Evaluates whether a small unmanned aircraft satisfies Remote ID requirements: Standard Remote ID broadcast, a broadcast module, or operation confined to an FAA-Recognized Identification Area.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"14 CFR Part 89 - Remote Identification of Unmanned Aircraft",
	],
}

default allow := false

allow if {
	input.aircraft.standard_remote_id_equipped == true
}

allow if {
	input.aircraft.broadcast_module_attached == true
}

allow if {
	input.operation.within_fria == true
}

default compliance_method := "none"

compliance_method := "standard_remote_id" if {
	input.aircraft.standard_remote_id_equipped == true
} else := "broadcast_module" if {
	input.aircraft.broadcast_module_attached == true
} else := "fria_exempt" if {
	input.operation.within_fria == true
}

policy_metrics := {
	"remote_id_compliance_method": {
		"name": "Remote ID Compliance Method",
		"value": compliance_method,
		"control_passed": compliance_method != "none",
	},
}

report := reporting.compose_report("faa.remote_id", allow, policy_metrics)
