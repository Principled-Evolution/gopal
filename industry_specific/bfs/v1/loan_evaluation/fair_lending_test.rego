package industry_specific.bfs.v1.loan_evaluation.fair_lending_test

import data.industry_specific.bfs.v1.loan_evaluation.fair_lending

# Test case for compliant input with custom parameters
test_is_compliant_with_custom_params if {
	fair_lending.is_compliant with input as {
		"evaluation": {
			"fairness": {"score": 0.95},
			"content_safety": {"score": 0.90},
			"risk_management": {"score": 0.90},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.80,
			"risk_management_threshold": 0.80,
		},
	}
}

# Test case for compliant input with default parameters
test_is_compliant_with_default_params if {
	fair_lending.is_compliant with input as {
		"evaluation": {
			"fairness": {"score": 0.95},
			"content_safety": {"score": 0.90},
			"risk_management": {"score": 0.90},
		},
		"params": {},
	}
}

# Test case for non-compliant input (fairness fails)
test_not_compliant_fairness_fails if {
	not fair_lending.is_compliant with input as {
		"evaluation": {
			"fairness": {"score": 0.85},
			"content_safety": {"score": 0.90},
			"risk_management": {"score": 0.90},
		},
		"params": {
			"fairness_threshold": 0.90,
			"content_safety_threshold": 0.85,
			"risk_management_threshold": 0.85,
		},
	}
}

# Test case for non-compliant input (content safety fails)
test_not_compliant_content_safety_fails if {
	not fair_lending.is_compliant with input as {
		"evaluation": {
			"fairness": {"score": 0.95},
			"content_safety": {"score": 0.80},
			"risk_management": {"score": 0.90},
		},
		"params": {
			"fairness_threshold": 0.90,
			"content_safety_threshold": 0.85,
			"risk_management_threshold": 0.85,
		},
	}
}

# Test case for non-compliant input (risk management fails)
test_not_compliant_risk_management_fails if {
	not fair_lending.is_compliant with input as {
		"evaluation": {
			"fairness": {"score": 0.95},
			"content_safety": {"score": 0.90},
			"risk_management": {"score": 0.80},
		},
		"params": {
			"fairness_threshold": 0.90,
			"content_safety_threshold": 0.85,
			"risk_management_threshold": 0.85,
		},
	}
}

# Test fairness_eval_fails function
test_fairness_eval_fails_true if {
	fair_lending.fairness_eval_fails with input as {
		"evaluation": {"fairness": {"score": 0.85}},
		"params": {"fairness_threshold": 0.90},
	}
}

test_fairness_eval_fails_false if {
	not fair_lending.fairness_eval_fails with input as {
		"evaluation": {"fairness": {"score": 0.95}},
		"params": {"fairness_threshold": 0.90},
	}
}

# Test content_safety_eval_fails function
test_content_safety_eval_fails_true if {
	fair_lending.content_safety_eval_fails with input as {
		"evaluation": {"content_safety": {"score": 0.80}},
		"params": {"content_safety_threshold": 0.85},
	}
}

test_content_safety_eval_fails_false if {
	not fair_lending.content_safety_eval_fails with input as {
		"evaluation": {"content_safety": {"score": 0.90}},
		"params": {"content_safety_threshold": 0.85},
	}
}

# Test risk_management_eval_fails function
test_risk_management_eval_fails_true if {
	fair_lending.risk_management_eval_fails with input as {
		"evaluation": {"risk_management": {"score": 0.80}},
		"params": {"risk_management_threshold": 0.85},
	}
}

test_risk_management_eval_fails_false if {
	not fair_lending.risk_management_eval_fails with input as {
		"evaluation": {"risk_management": {"score": 0.90}},
		"params": {"risk_management_threshold": 0.85},
	}
}

# Test compliance report thresholds
test_compliance_report_thresholds if {
	report := fair_lending.compliance_report with input as {
		"evaluation": {
			"fairness": {"score": 0.95},
			"content_safety": {"score": 0.90},
			"risk_management": {"score": 0.90},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.80,
			"risk_management_threshold": 0.80,
		},
	}

	report.thresholds.fairness == 0.85
	report.thresholds.content_safety == 0.80
	report.thresholds.risk_management == 0.80
}
