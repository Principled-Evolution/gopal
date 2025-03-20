package industry_specific.healthcare.v1.patient_safety_test

import data.industry_specific.healthcare.v1.patient_safety

# Test that the policy is correctly marked as a placeholder
test_implementation_pending if {
	patient_safety.implementation_pending
}

test_non_compliant if {
	patient_safety.non_compliant
}

# Test that the thresholds are correctly parameterized
test_compliance_report_thresholds if {
	report := patient_safety.compliance_report with input as {"params": {
		"patient_safety_threshold": 0.90,
		"clinical_validation_threshold": 0.85,
		"risk_assessment_threshold": 0.85,
	}}

	report.details.thresholds.patient_safety == 0.90
	report.details.thresholds.clinical_validation == 0.85
	report.details.thresholds.risk_assessment == 0.85
}

# Test that the thresholds use default values when params are not provided
test_compliance_report_default_thresholds if {
	report := patient_safety.compliance_report with input as {"params": {}}

	report.details.thresholds.patient_safety == 0.95
	report.details.thresholds.clinical_validation == 0.90
	report.details.thresholds.risk_assessment == 0.90
}
