package international.eu_ai_act.v1.prohibited_practices.criminal_profiling_test

import data.international.eu_ai_act.v1.prohibited_practices.criminal_profiling as policy
import rego.v1

profiling := {"system": {
	"predicts_criminal_offence_risk": true,
	"based_solely_on_profiling": true,
	"supports_human_assessment": false,
	"grounded_in_objective_verifiable_facts": false,
}}

test_deny_prediction_based_solely_on_profiling if {
	not policy.allow with input as profiling
}

# The Article 5(1)(d) carve-out needs both halves: supporting a human
# assessment AND that assessment being grounded in objective verifiable facts.
test_allow_when_full_carve_out_applies if {
	policy.allow with input as json.patch(profiling, [
		{"op": "replace", "path": "/system/supports_human_assessment", "value": true},
		{"op": "replace", "path": "/system/grounded_in_objective_verifiable_facts", "value": true},
	])
}

test_deny_when_human_assessment_not_grounded_in_facts if {
	not policy.allow with input as json.patch(profiling, [{"op": "replace", "path": "/system/supports_human_assessment", "value": true}])
}

test_deny_when_grounded_but_not_supporting_a_human if {
	not policy.allow with input as json.patch(profiling, [{"op": "replace", "path": "/system/grounded_in_objective_verifiable_facts", "value": true}])
}

# A system that does not predict offence risk is out of scope entirely.
test_allow_when_no_offence_risk_prediction if {
	policy.allow with input as json.patch(profiling, [{"op": "replace", "path": "/system/predicts_criminal_offence_risk", "value": false}])
}

# Prediction that is not based solely on profiling is not caught by 5(1)(d).
test_allow_when_not_based_solely_on_profiling if {
	policy.allow with input as json.patch(profiling, [{"op": "replace", "path": "/system/based_solely_on_profiling", "value": false}])
}

test_deny_when_assessment_not_recorded if {
	not policy.allow with input as {"system": {"supports_human_assessment": true}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
