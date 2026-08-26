package international.eu_ai_act.v1.eu_fairness_test

import data.global.v1.common.content_safety
import data.global.v1.common.fairness as common_fairness
import data.international.eu_ai_act.v1.eu_fairness

# Key change 1: Use functions (=) instead of rules (if) to return values directly
mock_gender_bias_detected(metrics) := metrics.fairness.details.gender_bias_detected

mock_racial_bias_detected(metrics) := metrics.fairness.details.racial_bias_detected

default mock_toxicity_below_threshold(_, _) := false

mock_toxicity_below_threshold(metrics, threshold) if {
	metrics.content_safety.score < threshold
}

# Key change 2: Test data uses the 'details' path, matching the common/fairness package
# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	eu_fairness.allow with input as {
		"metrics": {
			"fairness": {"details": {
				"gender_bias_detected": false,
				"racial_bias_detected": false,
			}},
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
			"fairness": {"details": {
				"gender_bias_detected": false,
				"racial_bias_detected": false,
			}},
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
			"fairness": {"details": {
				"gender_bias_detected": true,
				"racial_bias_detected": false,
			}},
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
			"fairness": {"details": {
				"gender_bias_detected": false,
				"racial_bias_detected": true,
			}},
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
			"fairness": {"details": {
				"gender_bias_detected": false,
				"racial_bias_detected": false,
			}},
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
			"fairness": {"details": {
				"gender_bias_detected": true,
				"racial_bias_detected": false,
			}},
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

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not eu_fairness.allow with input as {}
}

# Regression test for the unmeasured-toxicity fail-open.
#
# Both bias metrics are clean, but the system has never been toxicity-tested at
# all: metrics.content_safety.score is absent. content_safety.toxicity_below_threshold
# is a partial rule, so it is undefined here, and while
# `default toxicity_below_threshold := true` was in place that undefined value
# resolved to true and allow was satisfied. A system with no content-safety
# evidence whatsoever was reported compliant with Articles 10 and 15.
#
# The empty-input test above does not cover this: with no input at all the bias
# defaults deny first, so the toxicity path is never reached. It takes a
# partially-populated input to expose it.
test_allow_denies_when_toxicity_never_measured if {
	not eu_fairness.allow with input as {"metrics": {"fairness": {"details": {
		"gender_bias_detected": false,
		"racial_bias_detected": false,
	}}}}
}

# The same input plus a real content-safety score is allowed, which shows the
# test above fails for the intended reason rather than some unrelated gap.
test_allow_when_toxicity_measured_and_clean if {
	eu_fairness.allow with input as {"metrics": {
		"fairness": {"details": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"content_safety": {"score": 0.95},
	}}
}

# And a genuinely toxic system is denied.
test_deny_when_toxicity_above_threshold if {
	not eu_fairness.allow with input as {"metrics": {
		"fairness": {"details": {
			"gender_bias_detected": false,
			"racial_bias_detected": false,
		}},
		"content_safety": {"score": 0.1},
	}}
}

# The narrowest form of the same fail-open: a bare, empty metrics object.
# Pre-fix this returned true, so an AI system that submitted `{"metrics": {}}`
# was reported compliant with Articles 10 and 15. The bias helpers in
# global/v1/common/fairness.rego have a catch-all that returns false ("no bias
# detected") for input they cannot read, so the two bias checks passed, and the
# permissive toxicity default supplied the third.
test_allow_denies_on_empty_metrics_object if {
	not eu_fairness.allow with input as {"metrics": {}}
}
