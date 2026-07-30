# RequiredMetrics:
#   - daa_system.surveillance_volume_nm
#   - daa_system.alert_timeliness_compliant
#   - daa_system.equipped
#
# RequiredParams:
#   - min_surveillance_volume_nm (default 1.0)
package international.standards.v1.rtca_do_365

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "RTCA DO-365 - Detect and Avoid MOPS",
	"description": "Evaluates whether a UAS detect-and-avoid system meets the surveillance volume and alert-timeliness requirements of RTCA DO-365 Minimum Operational Performance Standards.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"RTCA DO-365 - Minimum Operational Performance Standards (MOPS) for Detect and Avoid Systems",
	],
}

default allow := false

allow if {
	input.daa_system.equipped == true
	input.daa_system.surveillance_volume_nm >= object.get(input.params, "min_surveillance_volume_nm", 1.0)
	input.daa_system.alert_timeliness_compliant == true
}

policy_metrics := {
	"daa_equipped": {
		"name": "Detect and Avoid System Equipped",
		"value": object.get(input.daa_system, "equipped", false),
		"control_passed": object.get(input.daa_system, "equipped", false) == true,
	},
	"surveillance_volume_sufficient": {
		"name": "Surveillance Volume Meets Minimum",
		"value": object.get(input.daa_system, "surveillance_volume_nm", 0),
		"control_passed": object.get(input.daa_system, "surveillance_volume_nm", 0) >= object.get(input.params, "min_surveillance_volume_nm", 1.0),
	},
	"alert_timeliness_compliant": {
		"name": "Alert Timeliness Compliant",
		"value": object.get(input.daa_system, "alert_timeliness_compliant", false),
		"control_passed": object.get(input.daa_system, "alert_timeliness_compliant", false) == true,
	},
}

report := reporting.compose_report("standards.rtca_do_365", allow, policy_metrics)
