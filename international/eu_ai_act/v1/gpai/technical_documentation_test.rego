package international.eu_ai_act.v1.gpai.technical_documentation_test

import data.international.eu_ai_act.v1.gpai.technical_documentation as policy
import rego.v1

proprietary := {
	"model": {"general_purpose": true, "free_and_open_source": false, "parameters_publicly_available": false, "systemic_risk": false},
	"documentation": {
		"annex_xi_complete": true,
		"training_process_documented": true,
		"testing_process_documented": true,
		"evaluation_results_documented": true,
	},
}

undocumented := json.patch(proprietary, [
	{"op": "replace", "path": "/documentation/annex_xi_complete", "value": false},
	{"op": "replace", "path": "/documentation/training_process_documented", "value": false},
	{"op": "replace", "path": "/documentation/testing_process_documented", "value": false},
	{"op": "replace", "path": "/documentation/evaluation_results_documented", "value": false},
])

test_allow_documented_proprietary_model if {
	policy.allow with input as proprietary
}

test_deny_undocumented_proprietary_model if {
	not policy.allow with input as undocumented
}

test_deny_without_evaluation_results if {
	not policy.allow with input as json.patch(proprietary, [{"op": "replace", "path": "/documentation/evaluation_results_documented", "value": false}])
}

# Article 53(2): free and open-source with publicly available parameters is
# exempt from this obligation.
test_allow_open_source_model_without_documentation if {
	policy.allow with input as json.patch(undocumented, [
		{"op": "replace", "path": "/model/free_and_open_source", "value": true},
		{"op": "replace", "path": "/model/parameters_publicly_available", "value": true},
	])
}

# An open licence without published parameters does not meet Article 53(2).
test_deny_open_licence_without_public_parameters if {
	not policy.allow with input as json.patch(undocumented, [{"op": "replace", "path": "/model/free_and_open_source", "value": true}])
}

# The interaction most likely to be misread: systemic risk removes the
# exemption entirely.
test_deny_open_source_systemic_risk_model_without_documentation if {
	not policy.allow with input as json.patch(undocumented, [
		{"op": "replace", "path": "/model/free_and_open_source", "value": true},
		{"op": "replace", "path": "/model/parameters_publicly_available", "value": true},
		{"op": "replace", "path": "/model/systemic_risk", "value": true},
	])
}

test_allow_when_not_general_purpose if {
	policy.allow with input as {"model": {"general_purpose": false}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
