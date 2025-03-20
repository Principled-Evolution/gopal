package industry_specific.healthcare.v1.diagnostic_safety_test

import data.global.v1.common.content_safety
import data.global.v1.common.fairness as common_fairness
import data.global.v1.common.risk_management
import data.industry_specific.healthcare.v1.diagnostic_safety

# Mock the imported functions
mock_passes_fairness_threshold(eval, threshold) if {
	eval.fairness_score >= threshold
}

mock_passes_fairness_threshold(eval, threshold) := false if {
	eval.fairness_score < threshold
}

mock_passes_content_safety_threshold(eval, threshold) if {
	eval.content_safety_score >= threshold
}

mock_passes_content_safety_threshold(eval, threshold) := false if {
	eval.content_safety_score < threshold
}

mock_passes_risk_threshold(eval, threshold) if {
	eval.risk_management_score >= threshold
}

mock_passes_risk_threshold(eval, threshold) := false if {
	eval.risk_management_score < threshold
}

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	diagnostic_safety.allow with input as {
		"evaluation": {
			"fairness_score": 0.90,
			"content_safety_score": 0.95,
			"risk_management_score": 0.95,
		},
		"params": {
			"fairness_threshold": 0.80,
			"content_safety_threshold": 0.85,
			"risk_management_threshold": 0.85,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	diagnostic_safety.allow with input as {
		"evaluation": {
			"fairness_score": 0.90,
			"content_safety_score": 0.95,
			"risk_management_score": 0.95,
		},
		"params": {},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test case for non-compliant input (fairness fails)
test_deny_fairness_fails if {
	not diagnostic_safety.allow with input as {
		"evaluation": {
			"fairness_score": 0.80,
			"content_safety_score": 0.95,
			"risk_management_score": 0.95,
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test case for non-compliant input (content safety fails)
test_deny_content_safety_fails if {
	not diagnostic_safety.allow with input as {
		"evaluation": {
			"fairness_score": 0.90,
			"content_safety_score": 0.85,
			"risk_management_score": 0.95,
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test case for non-compliant input (risk management fails)
test_deny_risk_management_fails if {
	not diagnostic_safety.allow with input as {
		"evaluation": {
			"fairness_score": 0.90,
			"content_safety_score": 0.95,
			"risk_management_score": 0.85,
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test case for non-compliant input (multiple failures)
test_deny_multiple_failures if {
	not diagnostic_safety.allow with input as {
		"evaluation": {
			"fairness_score": 0.80,
			"content_safety_score": 0.85,
			"risk_management_score": 0.85,
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test recommendations for fairness issues
test_recommendations_fairness if {
	diagnostic_safety.recommendations == ["Improve fairness in diagnostic algorithms to ensure equitable treatment across patient demographics"] with input as {
		"evaluation": {
			"fairness_score": 0.80,
			"content_safety_score": 0.95,
			"risk_management_score": 0.95,
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test recommendations for content safety issues
test_recommendations_content_safety if {
	diagnostic_safety.recommendations == ["Enhance content safety measures to ensure medical information is accurate and safe"] with input as {
		"evaluation": {
			"fairness_score": 0.90,
			"content_safety_score": 0.85,
			"risk_management_score": 0.95,
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold
}

# Test compliance report details
test_compliance_report_details if {
	report := diagnostic_safety.compliance_report with input as {
		"evaluation": {
			"fairness_score": 0.90,
			"content_safety_score": 0.95,
			"risk_management_score": 0.95,
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
		with common_fairness.passes_fairness_threshold as mock_passes_fairness_threshold
		with content_safety.passes_content_safety_threshold as mock_passes_content_safety_threshold
		with risk_management.passes_risk_threshold as mock_passes_risk_threshold

	report.details.fairness_score == 0.90
	report.details.fairness_threshold == 0.85
	report.details.content_safety_score == 0.95
	report.details.content_safety_threshold == 0.90
	report.details.risk_management_score == 0.95
	report.details.risk_management_threshold == 0.90
	report.overall_result == true
	count(report.details.failed_evaluations) == 0
}
