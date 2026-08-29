# RequiredMetrics:
#   - maintenance.program_established
#   - maintenance.inspection_current
#   - maintenance.records_retained
#
# RequiredParams: none
package industry_specific.aviation.v1.airworthiness.maintenance

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Continued Airworthiness Maintenance",
	"description": "Evaluates whether an aircraft has an established maintenance program, current inspections, and retained maintenance records for continued airworthiness.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"ICAO Annex 6 - Operation of Aircraft, Part I, Chapter 8 (Aeroplane Maintenance)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["maintenance", "program_established"]) == true
	declarations.resolve(input, ["maintenance", "inspection_current"]) == true
	declarations.resolve(input, ["maintenance", "records_retained"]) == true
}

policy_metrics := {
	"maintenance_program_established": {
		"name": "Maintenance Program Established",
		"value": object.get(input.maintenance, "program_established", false),
		"control_passed": object.get(input.maintenance, "program_established", false) == true,
	},
	"inspection_current": {
		"name": "Inspection Current",
		"value": object.get(input.maintenance, "inspection_current", false),
		"control_passed": object.get(input.maintenance, "inspection_current", false) == true,
	},
	"records_retained": {
		"name": "Maintenance Records Retained",
		"value": object.get(input.maintenance, "records_retained", false),
		"control_passed": object.get(input.maintenance, "records_retained", false) == true,
	},
}

report := reporting.compose_report("aviation.airworthiness.maintenance", allow, policy_metrics)
