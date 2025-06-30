package international.nist.v1.map_test

import rego.v1

test_allow if {
	allow with input as {"map": {
		"intended_use_documented": true,
		"architecture_documented": true,
		"data_sources_documented": true,
		"data_processing_documented": true,
		"known_limitations_documented": true,
		"out_of_scope_use_cases_documented": true,
	}}
}

test_deny_system_context if {
	not allow with input as {"map": {
		"intended_use_documented": false,
		"architecture_documented": true,
		"data_sources_documented": true,
		"data_processing_documented": true,
		"known_limitations_documented": true,
		"out_of_scope_use_cases_documented": true,
	}}
}
