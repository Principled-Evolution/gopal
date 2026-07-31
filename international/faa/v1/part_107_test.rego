package international.faa.v1.part_107_test

import data.international.faa.v1.part_107
import rego.v1

compliant_input := {
	"remote_pilot": {"certificate_held": true},
	"aircraft": {"registered": true},
	"operation": {"altitude_ft": 350, "visual_line_of_sight": true, "daylight_or_lit": true},
	"params": {},
}

test_allow_when_fully_compliant if {
	part_107.allow with input as compliant_input
}

test_allow_with_bvlos_waiver if {
	input_data := object.union(compliant_input, {"operation": {
		"altitude_ft": 350,
		"visual_line_of_sight": false,
		"bvlos_waiver_held": true,
		"daylight_or_lit": true,
	}})
	part_107.allow with input as input_data
}

test_deny_without_remote_pilot_certificate if {
	input_data := object.union(compliant_input, {"remote_pilot": {"certificate_held": false}})
	not part_107.allow with input as input_data
}

test_deny_without_registration if {
	input_data := object.union(compliant_input, {"aircraft": {"registered": false}})
	not part_107.allow with input as input_data
}

test_deny_above_altitude_limit if {
	input_data := object.union(compliant_input, {"operation": {
		"altitude_ft": 500,
		"visual_line_of_sight": true,
		"daylight_or_lit": true,
	}})
	not part_107.allow with input as input_data
}

test_deny_bvlos_without_waiver if {
	input_data := object.union(compliant_input, {"operation": {
		"altitude_ft": 350,
		"visual_line_of_sight": false,
		"daylight_or_lit": true,
	}})
	not part_107.allow with input as input_data
}

test_deny_night_operation_without_lighting if {
	input_data := object.union(compliant_input, {"operation": {
		"altitude_ft": 350,
		"visual_line_of_sight": true,
		"daylight_or_lit": false,
	}})
	not part_107.allow with input as input_data
}

test_allow_with_custom_max_altitude_param if {
	input_data := object.union(compliant_input, {
		"operation": {"altitude_ft": 500, "visual_line_of_sight": true, "daylight_or_lit": true},
		"params": {"max_altitude_ft": 500},
	})
	part_107.allow with input as input_data
}
