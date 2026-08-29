# RequiredMetrics:
#   - uam.vertiport_certified
#   - uam.noise_compliant
#   - uam.corridor_authorized
#
# RequiredParams:
#   - max_noise_db (default 65)
package industry_specific.aviation.v1.flight_operations.urban_air_mobility

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Urban Air Mobility Operations",
	"description": "Evaluates Advanced/Urban Air Mobility operations against vertiport certification, community noise limits, and authorized-corridor requirements.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"FAA Urban Air Mobility (UAM) Concept of Operations v2.0",
		"EASA Special Condition VTOL (SC-VTOL-01)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["uam", "vertiport_certified"]) == true
	declarations.resolve(input, ["uam", "noise_db"]) <= object.get(input, ["params", "max_noise_db"], 65)
	declarations.resolve(input, ["uam", "corridor_authorized"]) == true
}

policy_metrics := {
	"vertiport_certified": {
		"name": "Vertiport Certified",
		"value": object.get(input.uam, "vertiport_certified", false),
		"control_passed": object.get(input.uam, "vertiport_certified", false) == true,
	},
	"noise_within_limit": {
		"name": "Noise Within Community Limit",
		"value": object.get(input.uam, "noise_db", null),
		"control_passed": object.get(input.uam, "noise_db", 999) <= object.get(input, ["params", "max_noise_db"], 65),
	},
	"corridor_authorized": {
		"name": "Flight Corridor Authorized",
		"value": object.get(input.uam, "corridor_authorized", false),
		"control_passed": object.get(input.uam, "corridor_authorized", false) == true,
	},
}

report := reporting.compose_report("aviation.flight_operations.urban_air_mobility", allow, policy_metrics)
