package international.eu_ai_act.v1.eu_fairness_test

import data.global.v1.common.content_safety
import data.global.v1.common.fairness as common_fairness
import data.international.eu_ai_act.v1.eu_fairness

# Mock the imported functions
mock_gender_bias_detected(metrics) if {
	metrics.fairness.gender_bias == true
}

mock_gender_bias_detected(metrics) if {
	metrics.gender_bias_detected == true
}

mock_racial_bias_detected(metrics) if {
	metrics.fairness.racial_bias == true
}

mock_racial_bias_detected(metrics) if {
	metrics.racial_bias_detected == true
}

mock_toxicity_below_threshold(metrics, threshold) if {
	metrics.content_safety.score < threshold
}

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	eu_fairness.allow with input as {
		"metrics": {
			"fairness": {
				"gender_bias": false,
				"racial_bias": false,
			},
			"content_safety": {"score": 0.5},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"fairness_threshold": 0.75,
			"toxicity_threshold": 0.6,
		},
	}
		with common_fairness.gender_bias_detected as mock_gender_bias_detected
		with common_fairness.racial_bias_detected as mock_racial_bias_detected
		with content_safety.toxicity_below_threshold as mock_toxicity_below_threshold
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	eu_fairness.allow with input as {
		"metrics": {
			"fairness": {
				"gender_bias": false,
				"racial_bias": false,
			},
			"content_safety": {"score": 0.5},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {},
	}
		with common_fairness.gender_bias_detected as mock_gender_bias_detected
		with common_fairness.racial_bias_detected as mock_racial_bias_detected
		with content_safety.toxicity_below_threshold as mock_toxicity_below_threshold
}

# Test case for non-compliant input (gender bias)
test_deny_gender_bias if {
	not eu_fairness.allow with input as {
		"metrics": {
			"fairness": {
				"gender_bias": true,
				"racial_bias": false,
			},
			"content_safety": {"score": 0.5},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"fairness_threshold": 0.75,
			"toxicity_threshold": 0.6,
		},
	}
		with common_fairness.gender_bias_detected as mock_gender_bias_detected
		with common_fairness.racial_bias_detected as mock_racial_bias_detected
		with content_safety.toxicity_below_threshold as mock_toxicity_below_threshold
}

# Test case for non-compliant input (racial bias)
test_deny_racial_bias if {
	not eu_fairness.allow with input as {
		"metrics": {
			"fairness": {
				"gender_bias": false,
				"racial_bias": true,
			},
			"content_safety": {"score": 0.5},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"fairness_threshold": 0.75,
			"toxicity_threshold": 0.6,
		},
	}
		with common_fairness.gender_bias_detected as mock_gender_bias_detected
		with common_fairness.racial_bias_detected as mock_racial_bias_detected
		with content_safety.toxicity_below_threshold as mock_toxicity_below_threshold
}

# Test case for non-compliant input (high toxicity)
test_deny_high_toxicity if {
	not eu_fairness.allow with input as {
		"metrics": {
			"fairness": {
				"gender_bias": false,
				"racial_bias": false,
			},
			"content_safety": {"score": 0.8},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"fairness_threshold": 0.75,
			"toxicity_threshold": 0.6,
		},
	}
		with common_fairness.gender_bias_detected as mock_gender_bias_detected
		with common_fairness.racial_bias_detected as mock_racial_bias_detected
		with content_safety.toxicity_below_threshold as mock_toxicity_below_threshold
}

# Test recommendations for gender bias
test_recommendations_gender_bias if {
	eu_fairness.recommendations == ["Address gender bias in the AI system to comply with EU AI Act fairness requirements"] with input as {
		"metrics": {
			"fairness": {
				"gender_bias": true,
				"racial_bias": false,
			},
			"content_safety": {"score": 0.5},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"fairness_threshold": 0.75,
			"toxicity_threshold": 0.6,
		},
	}
		with common_fairness.gender_bias_detected as mock_gender_bias_detected
		with common_fairness.racial_bias_detected as mock_racial_bias_detected
		with content_safety.toxicity_below_threshold as mock_toxicity_below_threshold
}
