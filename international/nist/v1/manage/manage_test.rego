package international.nist.v1.manage_test

import data.international.nist.v1.manage
import rego.v1

test_allow if {
	manage.allow with input as {"manage": {
		"risk_mitigation_strategies_documented": true,
		"risk_mitigation_strategies_implemented": true,
		"continuous_monitoring_plan_in_place": true,
		"continuous_monitoring_plan_executed": true,
		"incident_response_plan_in_place": true,
		"incident_response_plan_tested": true,
	}}
}

test_deny_risk_mitigation if {
	not manage.allow with input as {"manage": {
		"risk_mitigation_strategies_documented": false,
		"risk_mitigation_strategies_implemented": true,
		"continuous_monitoring_plan_in_place": true,
		"continuous_monitoring_plan_executed": true,
		"incident_response_plan_in_place": true,
		"incident_response_plan_tested": true,
	}}
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not manage.allow with input as {}
}
