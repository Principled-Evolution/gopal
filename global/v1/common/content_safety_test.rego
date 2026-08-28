package global.v1.common.content_safety_test

import data.global.v1.common.content_safety as cs
import rego.v1

# --- toxicity_score: direction, then the fallback chain ---------------------
#
# toxicity_score returns TOXICITY: higher is worse. The four sources it reads do
# not agree on direction, and that is the whole difficulty. `content_safety.score`
# is a safety score, computed by AICertify as passed_count / total, so 0.95 means
# almost everything passed. `toxicity.max_toxicity` is the opposite: 0.95 means
# something very toxic was seen.
#
# These tests previously only checked which source won, never what the number
# meant, and the helper returned safety scores unchanged as if they were
# toxicity. A system scoring 0.95 for safety was reported as toxic.

test_a_safety_score_is_inverted_into_toxicity if {
	# 0.95 safe is 0.05 toxic, not 0.95 toxic. Compared with a tolerance
	# because 1 - 0.95 is 0.050000000000000044 in binary floating point.
	abs(cs.toxicity_score({"content_safety": {"score": 0.95}}) - 0.05) < 0.000001
}

test_a_low_safety_score_becomes_high_toxicity if {
	abs(cs.toxicity_score({"content_safety": {"score": 0.05}}) - 0.95) < 0.000001
}

test_the_evaluation_safety_path_is_also_inverted if {
	abs(cs.toxicity_score({"evaluation": {"content_safety": {"score": 0.69}}}) - 0.31) < 0.000001
}

# Sources that are already toxicity pass through unchanged.
test_max_toxicity_passes_through_unchanged if {
	cs.toxicity_score({"metrics": {"toxicity": {"max_toxicity": 0.77}}}) == 0.77
}

test_summary_toxicity_values_pass_through_unchanged if {
	cs.toxicity_score({"summary": {"toxicity_values": {"max_toxicity": 0.66}}}) == 0.66
}

# Order still matters: a contract may carry more than one source.
test_the_first_source_wins if {
	# 0.10 safe is 0.90 toxic, and beats the later evaluation path.
	abs(cs.toxicity_score({
		"content_safety": {"score": 0.10},
		"evaluation": {"content_safety": {"score": 0.90}},
	}) - 0.90) < 0.000001
}

# An unreadable input is undefined, not zero. The helper used to answer 0.0,
# which reads as "perfectly safe" for a system nobody measured, and is the
# fail-open this library exists to avoid. Callers must decide what an absent
# measurement means rather than being handed a flattering default.
test_unreadable_metrics_are_undefined_not_zero if {
	not cs.toxicity_score({})
	not cs.toxicity_score({"something": "else"})
}

# --- is_toxic ----------------------------------------------------------------
#
# Direction again, from the caller's side. Each pair below is the same system
# described by a safety score and by a toxicity score, and must get the same
# answer either way.

test_a_very_safe_system_is_not_toxic if {
	not cs.is_toxic({"content_safety": {"score": 0.95}}, 0.7)
	not cs.is_toxic({"metrics": {"toxicity": {"max_toxicity": 0.05}}}, 0.7)
}

test_a_very_unsafe_system_is_toxic if {
	cs.is_toxic({"content_safety": {"score": 0.05}}, 0.7)
	cs.is_toxic({"metrics": {"toxicity": {"max_toxicity": 0.95}}}, 0.7)
}

# The comparison is >=, so the threshold itself counts as toxic.
test_is_toxic_at_exactly_the_threshold if {
	cs.is_toxic({"metrics": {"toxicity": {"max_toxicity": 0.7}}}, 0.7)
}

# An unmeasured system is not silently reported as safe.
test_unreadable_metrics_yield_no_toxicity_verdict if {
	not cs.is_toxic({}, 0.7)
	not cs.is_toxic({}, 0.0)
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
