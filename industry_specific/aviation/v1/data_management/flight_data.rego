# RequiredMetrics:
#   - flight_data.recording_enabled
#   - flight_data.retention_days
#
# RequiredParams:
#   - min_retention_days (default 90)
package industry_specific.aviation.v1.data_management.flight_data

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Flight Data Recording and Retention",
	"description": "Evaluates whether flight data recording is enabled and retained for at least the minimum required period.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"ICAO Annex 6 - Operation of Aircraft, Chapter 4 (Flight Recorders)",
	],
}

default allow := false

allow if {
	input.flight_data.recording_enabled == true
	input.flight_data.retention_days >= object.get(input.params, "min_retention_days", 90)
}

policy_metrics := {
	"recording_enabled": {
		"name": "Flight Data Recording Enabled",
		"value": object.get(input.flight_data, "recording_enabled", false),
		"control_passed": object.get(input.flight_data, "recording_enabled", false) == true,
	},
	"retention_sufficient": {
		"name": "Retention Period Sufficient",
		"value": object.get(input.flight_data, "retention_days", 0),
		"control_passed": object.get(input.flight_data, "retention_days", 0) >= object.get(input.params, "min_retention_days", 90),
	},
}

report := reporting.compose_report("aviation.data_management.flight_data", allow, policy_metrics)
