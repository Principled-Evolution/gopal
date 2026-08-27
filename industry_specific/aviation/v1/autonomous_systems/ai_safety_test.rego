package industry_specific.aviation.v1.autonomous_systems.ai_safety_test

import data.industry_specific.aviation.v1.autonomous_systems.ai_safety
import rego.v1

compliant_input := {"ai_system": {
	"safety_validation_completed": true,
	"fail_safe_mechanism_present": true,
	"performance_monitoring_enabled": true,
}}

test_allow_when_fully_compliant if {
	ai_safety.allow with input as compliant_input
}

test_deny_without_safety_validation if {
	input_data := object.union(compliant_input, {"ai_system": {"safety_validation_completed": false, "fail_safe_mechanism_present": true, "performance_monitoring_enabled": true}})
	not ai_safety.allow with input as input_data
}

test_deny_without_fail_safe_mechanism if {
	input_data := object.union(compliant_input, {"ai_system": {"safety_validation_completed": true, "fail_safe_mechanism_present": false, "performance_monitoring_enabled": true}})
	not ai_safety.allow with input as input_data
}

test_deny_without_performance_monitoring if {
	input_data := object.union(compliant_input, {"ai_system": {"safety_validation_completed": true, "fail_safe_mechanism_present": true, "performance_monitoring_enabled": false}})
	not ai_safety.allow with input as input_data
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not ai_safety.allow with input as {}
}
