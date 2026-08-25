package international.eu_ai_act.v1.compliance.conformity_assessment_test

import data.international.eu_ai_act.v1.compliance.conformity_assessment as policy
import rego.v1

# Annex III points 2 to 8: internal control is the route.
non_biometric := {
	"system": {"high_risk": true, "annex_iii_category": 4},
	"assessment": {"procedure": "annex_vi_internal_control", "harmonised_standards_applied": false, "notified_body_involved": false, "completed": true},
}

# Annex III point 1: biometrics.
biometric := json.patch(non_biometric, [{"op": "replace", "path": "/system/annex_iii_category", "value": 1}])

test_allow_internal_control_for_annex_iii_points_2_to_8 if {
	policy.allow with input as non_biometric
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

# The distinction that is easy to get wrong: for Annex III point 1, internal
# control is available only where the harmonised standards were applied.
test_deny_biometric_internal_control_without_harmonised_standards if {
	not policy.allow with input as biometric
}

test_allow_biometric_internal_control_with_harmonised_standards if {
	policy.allow with input as json.patch(biometric, [{"op": "replace", "path": "/assessment/harmonised_standards_applied", "value": true}])
}

test_allow_biometric_via_notified_body if {
	policy.allow with input as json.patch(biometric, [
		{"op": "replace", "path": "/assessment/procedure", "value": "annex_vii_notified_body"},
		{"op": "replace", "path": "/assessment/notified_body_involved", "value": true},
	])
}

# Claiming the notified body route without a notified body is not that route.
test_deny_notified_body_route_without_a_notified_body if {
	not policy.allow with input as json.patch(biometric, [{"op": "replace", "path": "/assessment/procedure", "value": "annex_vii_notified_body"}])
}

# A permitted route that was never completed still fails.
test_deny_when_assessment_not_completed if {
	not policy.allow with input as json.patch(non_biometric, [{"op": "replace", "path": "/assessment/completed", "value": false}])
}

test_deny_on_unrecognised_procedure if {
	not policy.allow with input as json.patch(non_biometric, [{"op": "replace", "path": "/assessment/procedure", "value": "self_certified"}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
