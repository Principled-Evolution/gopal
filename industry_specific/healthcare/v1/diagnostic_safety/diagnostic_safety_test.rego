package industry_specific.healthcare.v1.diagnostic_safety_test

import data.industry_specific.healthcare.v1.diagnostic_safety

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	diagnostic_safety.allow with input as {
		"metrics": {
			"fairness": {"score": 0.90},
			"content_safety": {"score": 0.95},
			"risk_management": {"score": 0.95},
		},
		"params": {
			"fairness_threshold": 0.80,
			"content_safety_threshold": 0.85,
			"risk_management_threshold": 0.85,
		},
	}
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	diagnostic_safety.allow with input as {
		"metrics": {
			"fairness": {"score": 0.90},
			"content_safety": {"score": 0.95},
			"risk_management": {"score": 0.95},
		},
		"params": {},
	}
}

# Test case for non-compliant input (fairness fails)
test_deny_fairness_fails if {
	not diagnostic_safety.allow with input as {
		"metrics": {
			"fairness": {"score": 0.80},
			"content_safety": {"score": 0.95},
			"risk_management": {"score": 0.95},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
}

# Test case for non-compliant input (content safety fails)
test_deny_content_safety_fails if {
	not diagnostic_safety.allow with input as {
		"metrics": {
			"fairness": {"score": 0.90},
			"content_safety": {"score": 0.85},
			"risk_management": {"score": 0.95},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
}

# Test case for non-compliant input (risk management fails)
test_deny_risk_management_fails if {
	not diagnostic_safety.allow with input as {
		"metrics": {
			"fairness": {"score": 0.90},
			"content_safety": {"score": 0.95},
			"risk_management": {"score": 0.85},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
}

# Test case for non-compliant input (multiple failures)
test_deny_multiple_failures if {
	not diagnostic_safety.allow with input as {
		"metrics": {
			"fairness": {"score": 0.80},
			"content_safety": {"score": 0.85},
			"risk_management": {"score": 0.85},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
}

# Test recommendations for fairness issues
test_recommendations_fairness if {
	diagnostic_safety.recommendations == ["Improve fairness in diagnostic algorithms to ensure equitable treatment across patient demographics"] with input as {
		"metrics": {
			"fairness": {"score": 0.80},
			"content_safety": {"score": 0.95},
			"risk_management": {"score": 0.95},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
}

# Test recommendations for content safety issues
test_recommendations_content_safety if {
	diagnostic_safety.recommendations == ["Enhance content safety measures to ensure medical information is accurate and safe"] with input as {
		"metrics": {
			"fairness": {"score": 0.90},
			"content_safety": {"score": 0.85},
			"risk_management": {"score": 0.95},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}
}

# Test compliance report details
test_compliance_report_details if {
	report := diagnostic_safety.compliance_report with input as {
		"metrics": {
			"fairness": {"score": 0.90},
			"content_safety": {"score": 0.95},
			"risk_management": {"score": 0.95},
		},
		"params": {
			"fairness_threshold": 0.85,
			"content_safety_threshold": 0.90,
			"risk_management_threshold": 0.90,
		},
	}

	report.details.fairness_score == 0.90
	report.details.fairness_threshold == 0.85
	report.details.content_safety_score == 0.95
	report.details.content_safety_threshold == 0.90
	report.details.risk_management_score == 0.95
	report.details.risk_management_threshold == 0.90
	report.overall_result == true
	count(report.details.failed_evaluations) == 0
}

# A missing score used to make both the _eval_fails and _passes helpers
# undefined, so `not _eval_fails` held and the metric dropped silently out of
# failed_evaluations. An input carrying no scores at all therefore evaluated to
# allow. Absence must fail, not disappear.
test_deny_when_no_scores_supplied if {
	not diagnostic_safety.allow with input as {"evaluation": {}, "params": {}}
}

test_all_three_metrics_reported_missing if {
	diagnostic_safety.failed_evaluations == ["fairness", "content safety", "risk management"] with input as {"evaluation": {}, "params": {}}
}

test_deny_when_one_score_absent if {
	not diagnostic_safety.allow with input as {"evaluation": {
		"content_safety_score": 0.99,
		"risk_management_score": 0.99,
	}}
}

# A wholly empty input is the strongest form of the same problem: with no
# evaluation or params object at all, the threshold lookups were themselves
# undefined.
test_deny_on_wholly_empty_input if {
	not diagnostic_safety.allow with input as {}
}

# The decision uses a -1 sentinel so an unmeasured score fails every threshold.
# -1 is right for a comparison and wrong for a report, where it reads as a score
# no rubric can produce. The report says null instead.
test_report_says_null_for_unmeasured_scores if {
	report := diagnostic_safety.compliance_report with input as {"params": {}}

	report.details.fairness_score == null
	report.details.content_safety_score == null
	report.details.risk_management_score == null
	report.overall_result == false
}
