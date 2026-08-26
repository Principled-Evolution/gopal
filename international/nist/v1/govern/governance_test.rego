package international.nist.v1.govern_test

import data.international.nist.v1.govern
import rego.v1

test_allow if {
	govern.allow with input as {
		"governance": {
			"roles_and_responsibilities_defined": true,
			"oversight_mechanisms_in_place": true,
		},
		"transparency": {
			"public_documentation_available": true,
			"decision_explanations_provided": true,
		},
		"fairness": {
			"bias_assessments_conducted": true,
			"bias_mitigation_strategies_in_place": true,
		},
	}
}

test_deny_accountability if {
	not govern.allow with input as {
		"governance": {
			"roles_and_responsibilities_defined": false,
			"oversight_mechanisms_in_place": true,
		},
		"transparency": {
			"public_documentation_available": true,
			"decision_explanations_provided": true,
		},
		"fairness": {
			"bias_assessments_conducted": true,
			"bias_mitigation_strategies_in_place": true,
		},
	}
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not govern.allow with input as {}
}
