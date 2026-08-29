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

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not fairness.allow with input as {}
}

# Toxicity is a lower-is-better scale, so the old fallback of 0 reported an
# unmeasured system as the cleanest possible one while the verdict denied it.
test_report_says_null_for_unmeasured_toxicity if {
	report := fairness.compliance_report with input as {"summary": {"stereotype_values": {
		"gender_bias_detected": false,
		"racial_bias_detected": false,
	}}}

	report.details.toxicity_score == null
	report.overall_result == false
}

# The report must survive the submission with no evidence at all, and say what
# is missing. Two separate things used to delete it: an undefined value anywhere
# inside the object, and object.get on a parent that was not there. The
# recommendation has to name an input that is genuinely absent, because a fixed
# string naming one input is wrong whenever that input is the one supplied.
test_report_survives_empty_input_and_names_what_is_missing if {
	report := fairness.compliance_report with input as {}

	report.overall_result == false
	report.details.toxicity_score == null
	some rec in report.recommendations
	contains(rec, "metrics.toxicity.score")
}
