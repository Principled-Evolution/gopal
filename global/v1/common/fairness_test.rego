package global.v1.common.fairness_test

import data.global.v1.common.fairness as f
import rego.v1

# --- gender_bias_detected ----------------------------------------------------

test_gender_bias_detected_via_fairness_details if {
	f.gender_bias_detected({"fairness": {"details": {"gender_bias_detected": true}}})
}

test_gender_bias_detected_via_summary_stereotype_values if {
	f.gender_bias_detected({"summary": {"stereotype_values": {"gender_bias_detected": true}}})
}

test_gender_bias_not_detected_when_explicitly_false if {
	f.gender_bias_detected({"fairness": {"details": {"gender_bias_detected": false}}}) == false
}

# The catch-all returns false for metrics this helper cannot read, which reads as
# "no bias detected". That is a permissive answer derived from absence of
# evidence, so a policy must not treat a false here as a clean bill of health
# without separately confirming the metric was actually reported. This is the
# behaviour that, combined with a permissive toxicity default, let
# `{"metrics": {}}` pass the EU AI Act fairness policy.
test_gender_bias_returns_false_for_unreadable_metrics if {
	f.gender_bias_detected({}) == false
}

test_gender_bias_returns_false_for_unrelated_shape if {
	f.gender_bias_detected({"something": "else"}) == false
}

# A non-boolean value does not satisfy the `== true` comparisons, so it lands on
# the catch-all rather than being coerced.
test_gender_bias_returns_false_for_non_boolean_value if {
	f.gender_bias_detected({"fairness": {"details": {"gender_bias_detected": "yes"}}}) == false
}

# --- racial_bias_detected ----------------------------------------------------
#
# This one accepts three shapes, including a top-level key that the gender
# equivalent does not support.

test_racial_bias_detected_via_fairness_details if {
	f.racial_bias_detected({"fairness": {"details": {"racial_bias_detected": true}}})
}

test_racial_bias_detected_via_top_level_key if {
	f.racial_bias_detected({"racial_bias_detected": true})
}

test_racial_bias_detected_via_summary_stereotype_values if {
	f.racial_bias_detected({"summary": {"stereotype_values": {"racial_bias_detected": true}}})
}

test_racial_bias_returns_false_for_unreadable_metrics if {
	f.racial_bias_detected({}) == false
}

# The asymmetry between the two helpers is intentional to record: a top-level
# gender_bias_detected key is NOT recognised, so a contract using that shape
# would silently report no gender bias.
test_top_level_gender_bias_key_is_not_recognised if {
	f.gender_bias_detected({"gender_bias_detected": true}) == false
}

# --- fairness_score ----------------------------------------------------------

test_fairness_score_prefers_fairness_score if {
	f.fairness_score({"fairness": {"score": 0.88}}) == 0.88
}

test_fairness_score_falls_back_to_evaluation_path if {
	f.fairness_score({"evaluation": {"fairness": {"score": 0.55}}}) == 0.55
}

test_fairness_score_first_shape_wins if {
	f.fairness_score({
		"fairness": {"score": 0.10},
		"evaluation": {"fairness": {"score": 0.90}},
	}) == 0.10
}

# Here the 0.0 fallback is the *denying* direction, since higher is better for
# fairness. Absence of evidence therefore fails, which is the safe outcome.
test_fairness_score_defaults_to_zero if {
	f.fairness_score({}) == 0.0
}

# --- passes_fairness_threshold ----------------------------------------------

test_passes_fairness_threshold_above if {
	f.passes_fairness_threshold({"fairness_score": 0.95}, 0.8)
}

test_passes_fairness_threshold_at_boundary if {
	f.passes_fairness_threshold({"fairness_score": 0.8}, 0.8)
}

test_fails_fairness_threshold_below if {
	not f.passes_fairness_threshold({"fairness_score": 0.5}, 0.8)
}

test_fails_fairness_threshold_when_score_absent if {
	not f.passes_fairness_threshold({}, 0.8)
}
