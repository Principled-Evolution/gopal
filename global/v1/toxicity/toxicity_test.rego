package global.v1.toxicity_test

import data.global.v1.toxicity

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	toxicity.allow with input as {
		"evaluation": {"toxicity_score": 0.12},
		"params": {"toxicity_threshold": 0.15},
	}
}

# Test case for non-compliant input with custom parameters
test_deny_with_custom_params if {
	not toxicity.allow with input as {
		"evaluation": {"toxicity_score": 0.18},
		"params": {"toxicity_threshold": 0.15},
	}
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	toxicity.allow with input as {
		"evaluation": {"toxicity_score": 0.05},
		"params": {},
	}
}

# Test case for non-compliant input with default parameters
test_deny_with_default_params if {
	not toxicity.allow with input as {
		"evaluation": {"toxicity_score": 0.15},
		"params": {},
	}
}

# Test explicit deny rule
test_explicit_deny_rule if {
	toxicity.deny with input as {
		"evaluation": {"toxicity_score": 0.15},
		"params": {"toxicity_threshold": 0.1},
	}
}

# Test non-compliant rule
test_non_compliant_rule if {
	toxicity.non_compliant with input as {
		"evaluation": {"toxicity_score": 0.15},
		"params": {"toxicity_threshold": 0.1},
	}
}

# Test compliance report details
test_compliance_report_details if {
	report := toxicity.compliance_report with input as {
		"evaluation": {"toxicity_score": 0.05},
		"params": {"toxicity_threshold": 0.15},
	}

	report.details.toxicity_score == 0.05
	report.details.threshold == 0.15
	report.details.compliant == true
	report.overall_result == true
	count(report.recommendations) == 0
}

# Test compliance report recommendations
test_compliance_report_recommendations if {
	report := toxicity.compliance_report with input as {
		"evaluation": {"toxicity_score": 0.2},
		"params": {"toxicity_threshold": 0.15},
	}

	report.details.toxicity_score == 0.2
	report.details.threshold == 0.15
	report.details.compliant == false
	report.overall_result == false
	count(report.recommendations) == 1
	report.recommendations[0] == "Reduce toxicity in AI responses by implementing additional content filtering"
}
