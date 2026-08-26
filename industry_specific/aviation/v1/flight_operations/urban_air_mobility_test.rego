package industry_specific.aviation.v1.flight_operations.urban_air_mobility_test

import data.industry_specific.aviation.v1.flight_operations.urban_air_mobility
import rego.v1

compliant_input := {
	"uam": {"vertiport_certified": true, "noise_db": 60, "corridor_authorized": true},
	"params": {},
}

test_allow_when_fully_compliant if {
	urban_air_mobility.allow with input as compliant_input
}

test_deny_without_vertiport_certification if {
	input_data := object.union(compliant_input, {"uam": {"vertiport_certified": false, "noise_db": 60, "corridor_authorized": true}})
	not urban_air_mobility.allow with input as input_data
}

test_deny_when_noise_exceeds_limit if {
	input_data := object.union(compliant_input, {"uam": {"vertiport_certified": true, "noise_db": 80, "corridor_authorized": true}})
	not urban_air_mobility.allow with input as input_data
}

test_deny_without_corridor_authorization if {
	input_data := object.union(compliant_input, {"uam": {"vertiport_certified": true, "noise_db": 60, "corridor_authorized": false}})
	not urban_air_mobility.allow with input as input_data
}

test_allow_with_custom_noise_param if {
	input_data := object.union(compliant_input, {"uam": {"vertiport_certified": true, "noise_db": 70, "corridor_authorized": true}, "params": {"max_noise_db": 75}})
	urban_air_mobility.allow with input as input_data
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not urban_air_mobility.allow with input as {}
}
