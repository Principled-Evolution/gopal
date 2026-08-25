package international.eu_ai_act.v1.obligations.deployer_obligations_test

import data.international.eu_ai_act.v1.obligations.deployer_obligations as policy
import rego.v1

compliant := {"system": {"high_risk": true}, "deployer": {
	"uses_per_instructions": true,
	"human_oversight_assigned": true,
	"oversight_persons_trained_and_authorised": true,
	"controls_input_data": true,
	"input_data_relevant": true,
	"monitors_operation": true,
	"reports_serious_incidents": true,
	"logs_kept_six_months": true,
	"workplace_deployment": false,
	"workers_informed": false,
	"affects_natural_persons": false,
	"affected_persons_informed": false,
}}

test_allow_when_all_applicable_obligations_met if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_when_not_used_per_instructions if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/deployer/uses_per_instructions", "value": false}])
}

# Article 26(2): assigning oversight to someone untrained or unauthorised does
# not discharge the obligation.
test_deny_when_oversight_persons_untrained if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/deployer/oversight_persons_trained_and_authorised", "value": false}])
}

# Article 26(4) applies only to the extent the deployer controls the input data.
test_deny_when_controlled_input_data_not_relevant if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/deployer/input_data_relevant", "value": false}])
}

test_allow_when_deployer_does_not_control_input_data if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/deployer/controls_input_data", "value": false},
		{"op": "replace", "path": "/deployer/input_data_relevant", "value": false},
	])
}

# Article 26(7) is conditional on workplace deployment.
test_deny_workplace_deployment_without_informing_workers if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/deployer/workplace_deployment", "value": true}])
}

test_allow_workplace_deployment_with_workers_informed if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/deployer/workplace_deployment", "value": true},
		{"op": "replace", "path": "/deployer/workers_informed", "value": true},
	])
}

# Article 26(11) is conditional on the system affecting natural persons.
test_deny_when_affected_persons_not_informed if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/deployer/affects_natural_persons", "value": true}])
}

test_allow_when_affected_persons_informed if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/deployer/affects_natural_persons", "value": true},
		{"op": "replace", "path": "/deployer/affected_persons_informed", "value": true},
	])
}

test_deny_without_six_month_log_retention if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/deployer/logs_kept_six_months", "value": false}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
