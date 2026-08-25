package international.uk.v1.safety_security_robustness_test

import data.international.uk.v1.safety_security_robustness as policy
import rego.v1

compliant_input := {
	"risk_management": {"risk_assessment_completed": true, "lifecycle_monitoring_in_place": true},
	"security": {"security_testing_completed": true},
	"robustness": {"performance_thresholds_defined": true, "failure_handling_documented": true},
}

test_allow_when_all_controls_present if {
	policy.allow with input as compliant_input
}

test_deny_without_risk_assessment if {
	not policy.allow with input as json.patch(compliant_input, [{
		"op": "replace",
		"path": "/risk_management/risk_assessment_completed",
		"value": false,
	}])
}

# A one-off assessment is not enough: the principle requires risks to be
# managed continually across the lifecycle.
test_deny_without_lifecycle_monitoring if {
	not policy.allow with input as json.patch(compliant_input, [{
		"op": "replace",
		"path": "/risk_management/lifecycle_monitoring_in_place",
		"value": false,
	}])
}

test_deny_without_security_testing if {
	not policy.allow with input as json.patch(compliant_input, [{
		"op": "replace",
		"path": "/security/security_testing_completed",
		"value": false,
	}])
}

test_deny_without_failure_handling if {
	not policy.allow with input as json.patch(compliant_input, [{
		"op": "replace",
		"path": "/robustness/failure_handling_documented",
		"value": false,
	}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}

test_report_is_well_formed if {
	report := policy.report with input as compliant_input
	report.policy == "uk.safety_security_robustness"
	report.result == true
}
