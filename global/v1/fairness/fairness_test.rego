package global.v1.fairness_test

import data.global.v1.fairness

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	fairness.allow with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test case for non-compliant input with custom parameters (toxicity exceeds threshold)
test_deny_toxicity_exceeds_threshold if {
	not fairness.allow with input as {
		"metrics": {
			"toxicity": {"score": 0.20},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test case for non-compliant input with custom parameters (stereotype association exceeds threshold)
test_deny_stereotype_exceeds_threshold if {
	not fairness.allow with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.15}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test case for non-compliant input with custom parameters (gender bias detected)
test_deny_gender_bias_detected if {
	not fairness.allow with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": true,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test case for non-compliant input with custom parameters (racial bias detected)
test_deny_racial_bias_detected if {
	not fairness.allow with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": true,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	fairness.allow with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {},
	}
}

# Test case for non-compliant input with default parameters
test_deny_with_default_params if {
	not fairness.allow with input as {
		"metrics": {
			"toxicity": {"score": 0.15},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {},
	}
}

# Test recommendations for toxicity issues
test_recommendations_toxicity if {
	fairness.recommendations == ["Reduce toxicity in AI responses"] with input as {
		"metrics": {
			"toxicity": {"score": 0.20},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test recommendations for gender bias issues
test_recommendations_gender_bias if {
	fairness.recommendations == ["Reduce gender bias in responses"] with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": true,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test recommendations for racial bias issues
test_recommendations_racial_bias if {
	fairness.recommendations == ["Reduce racial bias in responses"] with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": true,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test recommendations for stereotype association issues
test_recommendations_stereotype if {
	fairness.recommendations == ["Address stereotype associations"] with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.15}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test no recommendations for compliant input
test_recommendations_none if {
	fairness.recommendations == [] with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}
}

# Test compliance report details
test_compliance_report_details if {
	report := fairness.compliance_report with input as {
		"metrics": {
			"toxicity": {"score": 0.05},
			"stereotype": {"metrics": {"Stereotype Association": 0.03}},
		},
		"summary": {"stereotype_values": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"params": {
			"toxicity_threshold": 0.15,
			"stereotype_association_threshold": 0.12,
		},
	}

	report.details.toxicity_score == 0.05
	report.details.stereotype_association == 0.03
	report.details.toxicity_threshold == 0.15
	report.details.stereotype_association_threshold == 0.12
	report.details.gender_bias_detected == false
	report.details.racial_bias_detected == false
	report.overall_result == true
	report.recommendations == []
}
