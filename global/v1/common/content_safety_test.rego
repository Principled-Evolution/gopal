package global.v1.common.content_safety_test

import data.global.v1.common.content_safety as cs
import rego.v1

# --- toxicity_score: the fallback chain -------------------------------------
#
# toxicity_score tries four shapes in order and then falls back to 0.0. The
# order matters, because a contract may legitimately carry more than one of
# them and callers need to know which wins.

test_toxicity_score_prefers_content_safety_score if {
	cs.toxicity_score({"content_safety": {"score": 0.42}}) == 0.42
}

test_toxicity_score_falls_back_to_evaluation_path if {
	cs.toxicity_score({"evaluation": {"content_safety": {"score": 0.31}}}) == 0.31
}

test_toxicity_score_falls_back_to_metrics_max_toxicity if {
	cs.toxicity_score({"metrics": {"toxicity": {"max_toxicity": 0.77}}}) == 0.77
}

test_toxicity_score_falls_back_to_summary_toxicity_values if {
	cs.toxicity_score({"summary": {"toxicity_values": {"max_toxicity": 0.66}}}) == 0.66
}

test_toxicity_score_first_shape_wins_over_later_ones if {
	cs.toxicity_score({
		"content_safety": {"score": 0.10},
		"evaluation": {"content_safety": {"score": 0.90}},
	}) == 0.10
}

# The default is 0.0, which reads as "perfectly safe" for input the helper
# cannot interpret. This is a permissive fallback and it is deliberate here, but
# it means a caller must not treat a low score as evidence of a measurement
# having happened. Policies that need that guarantee should assert the field is
# present, the way international/eu_ai_act/v1/eu_fairness does with its
# `default toxicity_below_threshold := false`.
test_toxicity_score_defaults_to_zero_for_unreadable_metrics if {
	cs.toxicity_score({}) == 0.0
}

test_toxicity_score_defaults_to_zero_for_unrelated_shape if {
	cs.toxicity_score({"something": "else"}) == 0.0
}

# --- is_toxic ----------------------------------------------------------------

test_is_toxic_when_score_exceeds_threshold if {
	cs.is_toxic({"content_safety": {"score": 0.95}}, 0.7)
}

# The comparison is >=, so the threshold itself counts as toxic.
test_is_toxic_at_exactly_the_threshold if {
	cs.is_toxic({"content_safety": {"score": 0.7}}, 0.7)
}

test_not_toxic_below_threshold if {
	not cs.is_toxic({"content_safety": {"score": 0.2}}, 0.7)
}

# Consequence of the 0.0 fallback above: unreadable metrics are reported as not
# toxic. Asserted here so the behaviour is visible rather than surprising.
test_not_toxic_for_unreadable_metrics if {
	not cs.is_toxic({}, 0.7)
}

# --- passes_content_safety_threshold -----------------------------------------

test_passes_content_safety_threshold_above if {
	cs.passes_content_safety_threshold({"content_safety_score": 0.95}, 0.9)
}

test_passes_content_safety_threshold_at_boundary if {
	cs.passes_content_safety_threshold({"content_safety_score": 0.9}, 0.9)
}

test_fails_content_safety_threshold_below if {
	not cs.passes_content_safety_threshold({"content_safety_score": 0.5}, 0.9)
}

# A missing score leaves the comparison undefined, so this one denies. That is
# the safe direction and the opposite of the toxicity_score fallback.
test_fails_content_safety_threshold_when_score_absent if {
	not cs.passes_content_safety_threshold({}, 0.9)
}

# --- toxicity_below_threshold ------------------------------------------------
#
# This one reads metrics.content_safety.score as a *safety* score and derives
# toxicity as 1 - score, unlike toxicity_score above which treats the same field
# as toxicity directly. Both conventions live in this file, so the tests pin
# each one down.

test_toxicity_below_threshold_for_a_safe_system if {
	cs.toxicity_below_threshold({"content_safety": {"score": 0.95}}, 0.7)
}

test_toxicity_not_below_threshold_for_a_toxic_system if {
	not cs.toxicity_below_threshold({"content_safety": {"score": 0.1}}, 0.7)
}

# It is a partial rule with no fallback, so an absent score makes it undefined.
# Callers must supply their own default, and it must be the denying one.
test_toxicity_below_threshold_is_undefined_when_score_absent if {
	not cs.toxicity_below_threshold({}, 0.7)
}

test_toxicity_below_threshold_is_undefined_for_empty_metrics if {
	not cs.toxicity_below_threshold({"content_safety": {}}, 0.7)
}
