package international.nist.v1.govern

import rego.v1

test_allow if {
	allow with input as {
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
	not allow with input as {
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
