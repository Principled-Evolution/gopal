package global.v1.common.common_rules_test

import data.global.v1.common.common_rules

# Test fairness_gender_bias_detected function
test_fairness_gender_bias_detected_true if {
	common_rules.fairness_gender_bias_detected({"fairness": {"gender_bias": true}})
}

test_fairness_gender_bias_detected_false if {
	not common_rules.fairness_gender_bias_detected({"fairness": {"gender_bias": false}})
}

# Test fairness_racial_bias_detected function
test_fairness_racial_bias_detected_true if {
	common_rules.fairness_racial_bias_detected({"fairness": {"racial_bias": true}})
}

test_fairness_racial_bias_detected_false if {
	not common_rules.fairness_racial_bias_detected({"fairness": {"racial_bias": false}})
}

# Test content_safety_is_toxic function
test_content_safety_is_toxic_true if {
	common_rules.content_safety_is_toxic(
		{"content_safety": {"score": 0.15}},
		0.1,
	)
}

test_content_safety_is_toxic_false if {
	not common_rules.content_safety_is_toxic(
		{"content_safety": {"score": 0.05}},
		0.1,
	)
}

# Test content_safety_is_toxic_param function
test_content_safety_is_toxic_param_true if {
	common_rules.content_safety_is_toxic_param(
		{"content_safety": {"score": 0.15}},
		{"content_safety_threshold": 0.1},
	)
}

test_content_safety_is_toxic_param_false if {
	not common_rules.content_safety_is_toxic_param(
		{"content_safety": {"score": 0.05}},
		{"content_safety_threshold": 0.1},
	)
}

test_content_safety_is_toxic_param_default if {
	common_rules.content_safety_is_toxic_param(
		{"content_safety": {"score": 0.15}},
		{},
	)
}

# Test risk_management_has_high_risk function
test_risk_management_has_high_risk_true if {
	common_rules.risk_management_has_high_risk(
		{"risk_management": {"score": 0.8}},
		0.7,
	)
}

test_risk_management_has_high_risk_false if {
	not common_rules.risk_management_has_high_risk(
		{"risk_management": {"score": 0.6}},
		0.7,
	)
}

# Test risk_management_has_high_risk_param function
test_risk_management_has_high_risk_param_true if {
	common_rules.risk_management_has_high_risk_param(
		{"risk_management": {"score": 0.8}},
		{"risk_management_threshold": 0.7},
	)
}

test_risk_management_has_high_risk_param_false if {
	not common_rules.risk_management_has_high_risk_param(
		{"risk_management": {"score": 0.6}},
		{"risk_management_threshold": 0.7},
	)
}

test_risk_management_has_high_risk_param_default if {
	common_rules.risk_management_has_high_risk_param(
		{"risk_management": {"score": 0.8}},
		{},
	)
}

# Test is_toxic function
test_is_toxic_true if {
	common_rules.is_toxic(
		{"toxicity": {"score": 0.15}},
		0.1,
	)
}

test_is_toxic_false if {
	not common_rules.is_toxic(
		{"toxicity": {"score": 0.05}},
		0.1,
	)
}

# Test is_toxic_param function
test_is_toxic_param_true if {
	common_rules.is_toxic_param(
		{"toxicity": {"score": 0.15}},
		{"toxicity_threshold": 0.1},
	)
}

test_is_toxic_param_false if {
	not common_rules.is_toxic_param(
		{"toxicity": {"score": 0.05}},
		{"toxicity_threshold": 0.1},
	)
}

test_is_toxic_param_default if {
	common_rules.is_toxic_param(
		{"toxicity": {"score": 0.15}},
		{},
	)
}

# Test in_range function
test_in_range_true if {
	common_rules.in_range(5, 1, 10)
}

test_in_range_false_below if {
	not common_rules.in_range(0, 1, 10)
}

test_in_range_false_above if {
	not common_rules.in_range(11, 1, 10)
}

test_in_range_edge_min if {
	common_rules.in_range(1, 1, 10)
}

test_in_range_edge_max if {
	common_rules.in_range(10, 1, 10)
}

# Test format_result function
test_format_result if {
	result := common_rules.format_result(true, 0.8, 0.7, {"key": "value"})
	result.compliant == true
	result.score == 0.8
	result.threshold == 0.7
	result.details.key == "value"
}

# Test is_compliant function
test_is_compliant_true if {
	common_rules.is_compliant(0.8, 0.7)
}

test_is_compliant_false if {
	not common_rules.is_compliant(0.6, 0.7)
}

test_is_compliant_equal if {
	common_rules.is_compliant(0.7, 0.7)
}
