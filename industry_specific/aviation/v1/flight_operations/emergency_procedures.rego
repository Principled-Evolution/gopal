# RequiredMetrics:
#   - emergency_procedures.lost_link_procedure_defined
#   - emergency_procedures.contingency_landing_sites_identified
#   - emergency_procedures.crew_trained
#
# RequiredParams: none
package industry_specific.aviation.v1.flight_operations.emergency_procedures

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Emergency and Contingency Procedures",
	"description": "Evaluates whether an operation has a defined lost-link procedure, identified contingency landing sites, and trained crew for emergency response.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"ICAO Doc 10019 - Manual on RPAS, Chapter 3 (C2 Link failure contingencies)",
	],
}

default allow := false

allow if {
	input.emergency_procedures.lost_link_procedure_defined == true
	input.emergency_procedures.contingency_landing_sites_identified == true
	input.emergency_procedures.crew_trained == true
}

policy_metrics := {
	"lost_link_procedure_defined": {
		"name": "Lost Link Procedure Defined",
		"value": object.get(input.emergency_procedures, "lost_link_procedure_defined", false),
		"control_passed": object.get(input.emergency_procedures, "lost_link_procedure_defined", false) == true,
	},
	"contingency_landing_sites_identified": {
		"name": "Contingency Landing Sites Identified",
		"value": object.get(input.emergency_procedures, "contingency_landing_sites_identified", false),
		"control_passed": object.get(input.emergency_procedures, "contingency_landing_sites_identified", false) == true,
	},
	"crew_trained": {
		"name": "Crew Trained on Emergency Procedures",
		"value": object.get(input.emergency_procedures, "crew_trained", false),
		"control_passed": object.get(input.emergency_procedures, "crew_trained", false) == true,
	},
}

report := reporting.compose_report("aviation.flight_operations.emergency_procedures", allow, policy_metrics)
