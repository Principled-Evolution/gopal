package industry_specific.bfs.v1.model_risk_test

import data.industry_specific.bfs.v1.model_risk

# Test that the policy is correctly marked as a placeholder
test_implementation_pending if {
	model_risk.implementation_pending
}

test_non_compliant if {
	model_risk.non_compliant
}

# Test that the thresholds are correctly parameterized
test_compliance_report_thresholds if {
	report := model_risk.compliance_report with input as {"params": {
		"model_risk_threshold": 0.80,
		"documentation_threshold": 0.85,
		"validation_threshold": 0.80,
	}}

	report.thresholds.model_risk == 0.80
	report.thresholds.documentation == 0.85
	report.thresholds.validation == 0.80
}

# Test that the thresholds use default values when params are not provided
test_compliance_report_default_thresholds if {
	report := model_risk.compliance_report with input as {"params": {}}

	report.thresholds.model_risk == 0.85
	report.thresholds.documentation == 0.90
	report.thresholds.validation == 0.85
}
