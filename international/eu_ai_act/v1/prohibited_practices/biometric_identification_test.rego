package international.eu_ai_act.v1.prohibited_practices.biometric_identification_test

import data.international.eu_ai_act.v1.prohibited_practices.biometric_identification as policy
import rego.v1

in_scope := {
	"system": {
		"real_time_remote_biometric_identification": true,
		"publicly_accessible_space": true,
		"law_enforcement_purpose": true,
		"permitted_objective": "",
	},
	"authorisation": {"prior_authorisation_obtained": false},
}

test_deny_with_no_permitted_objective if {
	not policy.allow with input as in_scope
}

# The case most likely to be got wrong: a permitted objective is claimed but
# the Article 5(3) prior authorisation was never obtained.
test_deny_permitted_objective_without_prior_authorisation if {
	not policy.allow with input as json.patch(in_scope, [{"op": "replace", "path": "/system/permitted_objective", "value": "missing_persons"}])
}

test_allow_permitted_objective_with_prior_authorisation if {
	policy.allow with input as json.patch(in_scope, [
		{"op": "replace", "path": "/system/permitted_objective", "value": "missing_persons"},
		{"op": "replace", "path": "/authorisation/prior_authorisation_obtained", "value": true},
	])
}

# An objective outside the closed list does not become permitted by having
# authorisation attached to it.
test_deny_unlisted_objective_even_with_authorisation if {
	not policy.allow with input as json.patch(in_scope, [
		{"op": "replace", "path": "/system/permitted_objective", "value": "general_crime_prevention"},
		{"op": "replace", "path": "/authorisation/prior_authorisation_obtained", "value": true},
	])
}

test_allow_terrorist_attack_prevention_with_authorisation if {
	policy.allow with input as json.patch(in_scope, [
		{"op": "replace", "path": "/system/permitted_objective", "value": "prevention_of_terrorist_attack"},
		{"op": "replace", "path": "/authorisation/prior_authorisation_obtained", "value": true},
	])
}

# Post-remote identification, private-space use, or non-law-enforcement use all
# fall outside Article 5(1)(h).
test_allow_when_not_real_time if {
	policy.allow with input as json.patch(in_scope, [{"op": "replace", "path": "/system/real_time_remote_biometric_identification", "value": false}])
}

test_allow_when_not_a_publicly_accessible_space if {
	policy.allow with input as json.patch(in_scope, [{"op": "replace", "path": "/system/publicly_accessible_space", "value": false}])
}

test_allow_when_not_for_law_enforcement if {
	policy.allow with input as json.patch(in_scope, [{"op": "replace", "path": "/system/law_enforcement_purpose", "value": false}])
}

test_deny_when_assessment_not_recorded if {
	not policy.allow with input as {"system": {"publicly_accessible_space": true}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
