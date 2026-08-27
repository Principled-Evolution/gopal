package industry_specific.aviation.v1.flight_operations.bvlos_operations_test

import data.industry_specific.aviation.v1.flight_operations.bvlos_operations
import rego.v1

compliant_input := {"operation": {
	"daa_system_equipped": true,
	"authorization_held": true,
	"ground_risk_mitigations_in_place": true,
}}

test_allow_when_fully_compliant if {
	bvlos_operations.allow with input as compliant_input
}

test_deny_without_daa_system if {
	input_data := object.union(compliant_input, {"operation": {"daa_system_equipped": false, "authorization_held": true, "ground_risk_mitigations_in_place": true}})
	not bvlos_operations.allow with input as input_data
}

test_deny_without_authorization if {
	input_data := object.union(compliant_input, {"operation": {"daa_system_equipped": true, "authorization_held": false, "ground_risk_mitigations_in_place": true}})
	not bvlos_operations.allow with input as input_data
}

test_deny_without_ground_risk_mitigations if {
	input_data := object.union(compliant_input, {"operation": {"daa_system_equipped": true, "authorization_held": true, "ground_risk_mitigations_in_place": false}})
	not bvlos_operations.allow with input as input_data
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not bvlos_operations.allow with input as {}
}
