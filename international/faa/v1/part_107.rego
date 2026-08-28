# RequiredMetrics:
#   - remote_pilot.certificate_held
#   - aircraft.registered
#   - operation.altitude_ft
#   - operation.visual_line_of_sight
#   - operation.daylight_or_lit
#
# RequiredParams:
#   - max_altitude_ft (default 400)
package international.faa.v1.part_107

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "FAA Part 107 - Small Unmanned Aircraft Systems",
	"description": "Evaluates small UAS operations against 14 CFR Part 107 operating rules: pilot certification, registration, altitude limit, visual line of sight, and daylight/lighting requirements.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"14 CFR Part 107 Subpart B - Operating Rules (Sec. 107.31, 107.51)",
		"14 CFR Part 107 Subpart C - Remote Pilot Certification (Sec. 107.12)",
	],
}

default allow := false

allow if {
	input.remote_pilot.certificate_held == true
	input.aircraft.registered == true
	input.operation.altitude_ft <= object.get(input, ["params", "max_altitude_ft"], 400)
	visual_conditions_met
	lighting_conditions_met
}

visual_conditions_met if {
	input.operation.visual_line_of_sight == true
}

visual_conditions_met if {
	input.operation.visual_line_of_sight == false
	input.operation.bvlos_waiver_held == true
}

lighting_conditions_met if {
	input.operation.daylight_or_lit == true
}

policy_metrics := {
	"remote_pilot_certificated": {
		"name": "Remote Pilot Certificate Held",
		"value": input.remote_pilot.certificate_held,
		"control_passed": input.remote_pilot.certificate_held == true,
	},
	"aircraft_registered": {
		"name": "Aircraft Registered",
		"value": input.aircraft.registered,
		"control_passed": input.aircraft.registered == true,
	},
	"altitude_within_limit": {
		"name": "Altitude Within 400ft Limit",
		"value": input.operation.altitude_ft,
		"control_passed": input.operation.altitude_ft <= object.get(input, ["params", "max_altitude_ft"], 400),
	},
	"visual_conditions": {
		"name": "VLOS or Waivered BVLOS",
		"value": visual_conditions_met,
		"control_passed": visual_conditions_met,
	},
	"lighting_conditions": {
		"name": "Daylight Operation or Anti-Collision Lighting",
		"value": lighting_conditions_met,
		"control_passed": lighting_conditions_met,
	},
}

report := reporting.compose_report("faa.part_107", allow, policy_metrics)
