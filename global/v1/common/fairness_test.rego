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

test_fairness_score_reads_the_canonical_name if {
	f.fairness_score({"metrics": {"fairness": {"score": 0.85}}}) == 0.85
}

# Undefined, not 0.0. Higher is better for fairness, so 0.0 denied and the
# direction was safe, but it denied while reporting a measurement nobody took.
# A caller now has to decide what absence means.
test_fairness_score_is_undefined_when_unmeasured if {
	not f.fairness_score({})
	not f.fairness_score({"metrics": {}})
}

# The spelling retired in 2.0.0 must not keep working through this helper after
# being removed from the alias table.
test_the_retired_evaluation_spelling_is_not_read if {
	not f.fairness_score({"evaluation": {"fairness": {"score": 0.42}}})
}
