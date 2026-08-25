# RequiredMetrics:
#   - risk_management.risk_assessment_completed
#   - risk_management.lifecycle_monitoring_in_place
#   - security.security_testing_completed
#   - robustness.performance_thresholds_defined
#   - robustness.failure_handling_documented
#
# RequiredParams: none
package international.uk.v1.safety_security_robustness

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "UK AI Principle 1 - Safety, Security and Robustness",
	"description": "Evaluates whether an AI system functions in a robust, secure and safe way throughout its lifecycle, with risks continually identified, assessed and managed. The UK's five cross-sectoral principles are non-statutory and are addressed to regulators rather than imposed directly on firms, so this policy encodes them as an assurance baseline, not as a statutory test.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"A pro-innovation approach to AI regulation, CP 815 (March 2023), principle: safety, security and robustness",
		"Implementing the UK's AI regulatory principles: initial guidance for regulators (DSIT, February 2024)",
	],
}

default allow := false

allow if {
	risk_managed
	secured
	robust
}

default risk_managed := false

risk_managed if {
	input.risk_management.risk_assessment_completed == true
	input.risk_management.lifecycle_monitoring_in_place == true
}

default secured := false

secured if {
	input.security.security_testing_completed == true
}

default robust := false

robust if {
	input.robustness.performance_thresholds_defined == true
	input.robustness.failure_handling_documented == true
}

policy_metrics := {
	"risk_managed_across_lifecycle": {
		"name": "Risk Identified, Assessed and Managed Across the Lifecycle",
		"value": risk_managed,
		"control_passed": risk_managed,
	},
	"security_tested": {
		"name": "Security Testing Completed",
		"value": secured,
		"control_passed": secured,
	},
	"robustness_evidenced": {
		"name": "Performance Thresholds and Failure Handling Documented",
		"value": robust,
		"control_passed": robust,
	},
}

report := reporting.compose_report("uk.safety_security_robustness", allow, policy_metrics)
