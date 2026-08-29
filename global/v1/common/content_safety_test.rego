package global.v1.common.content_safety_test

import data.global.v1.common.content_safety as cs
import rego.v1

# --- toxicity_score: direction first, then precedence ------------------------
#
# toxicity_score returns TOXICITY: higher is worse. The two sources it reads do
# not agree on direction, and that is the whole difficulty.
# metrics.content_safety.score is a safety score, computed by AICertify as
# passed_count / total, so 0.95 means almost everything passed.
# metrics.toxicity.max_toxicity is the opposite: 0.95 means something very
# toxic was seen.
#
# These tests once only checked which source won, never what the number meant,
# and the helper returned safety scores unchanged as if they were toxicity. A
# system scoring 0.95 for safety was reported as toxic.

test_a_safety_score_is_inverted_into_toxicity if {
	# 0.95 safe is 0.05 toxic, not 0.95 toxic. Compared with a tolerance
	# because 1 - 0.95 is 0.050000000000000044 in binary floating point.
	abs(cs.toxicity_score({"metrics": {"content_safety": {"score": 0.95}}}) - 0.05) < 0.000001
}

test_a_low_safety_score_becomes_high_toxicity if {
	abs(cs.toxicity_score({"metrics": {"content_safety": {"score": 0.05}}}) - 0.95) < 0.000001
}

# A source that is already toxicity passes through unchanged.
test_max_toxicity_passes_through_unchanged if {
	cs.toxicity_score({"metrics": {"toxicity": {"max_toxicity": 0.77}}}) == 0.77
}

# When a document carries both, the higher reading wins in either direction.
#
# The first version of this preferred the worst-case source outright, on the
# assumption that a maximum is always the stricter reading. It is not: a
# max_toxicity of 0.20 beside a safety score of 0.10, which inverts to a
# toxicity of 0.90, is the more flattering number, and preferring it let a
# system where nine checks in ten failed read as untoxic. Both directions are
# pinned here because only one of them was wrong, and a source-ordering
# regression would still pass the other.
test_the_higher_reading_wins_when_the_aggregate_is_worse if {
	both := {"metrics": {
		"content_safety": {"score": 0.10},
		"toxicity": {"max_toxicity": 0.20},
	}}
	abs(cs.toxicity_score(both) - 0.90) < 0.000001
	cs.is_toxic(both, 0.7)
}

test_the_higher_reading_wins_when_the_worst_case_is_worse if {
	both := {"metrics": {
		"content_safety": {"score": 0.90},
		"toxicity": {"max_toxicity": 0.40},
	}}
	cs.toxicity_score(both) == 0.40
	not cs.is_toxic(both, 0.7)
}

# An unreadable input is undefined, not zero. The helper used to answer 0.0,
# which reads as "perfectly safe" for a system nobody measured, and is the
# fail-open this library exists to avoid. Callers must decide what an absent
# measurement means rather than being handed a flattering default.
test_unreadable_metrics_are_undefined_not_zero if {
	not cs.toxicity_score({})
	not cs.toxicity_score({"something": "else"})
	not cs.toxicity_score({"metrics": {}})
}

# The spellings retired in 2.0.0 read through this helper too, and must not
# quietly keep working here after being removed from the alias table.
test_retired_spellings_are_not_read if {
	not cs.toxicity_score({"content_safety": {"score": 0.95}})
	not cs.toxicity_score({"evaluation": {"content_safety": {"score": 0.69}}})
	not cs.toxicity_score({"summary": {"toxicity_values": {"max_toxicity": 0.66}}})
}

# --- is_toxic ----------------------------------------------------------------
#
# Direction again, from the caller's side. Each pair below is the same system
# described by a safety score and by a toxicity score, and must get the same
# answer either way.

test_a_very_safe_system_is_not_toxic if {
	not cs.is_toxic({"metrics": {"content_safety": {"score": 0.95}}}, 0.7)
	not cs.is_toxic({"metrics": {"toxicity": {"max_toxicity": 0.05}}}, 0.7)
}

test_a_very_unsafe_system_is_toxic if {
	cs.is_toxic({"metrics": {"content_safety": {"score": 0.05}}}, 0.7)
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

# --- toxicity_below_threshold ------------------------------------------------
#
# Until 2.0.0 this derived toxicity as 1 - score while toxicity_score treated
# the same field as toxicity directly, so the two functions in this file
# disagreed about what the number meant. They now share one definition, and
# these tests pin the agreement.

test_toxicity_below_threshold_for_a_safe_system if {
	cs.toxicity_below_threshold({"metrics": {"content_safety": {"score": 0.95}}}, 0.7)
}

test_toxicity_not_below_threshold_for_a_toxic_system if {
	not cs.toxicity_below_threshold({"metrics": {"content_safety": {"score": 0.1}}}, 0.7)
}

test_the_two_functions_agree if {
	doc := {"metrics": {"toxicity": {"max_toxicity": 0.8}}}
	cs.is_toxic(doc, 0.7)
	not cs.toxicity_below_threshold(doc, 0.7)
}

# It is a partial rule with no fallback, so an absent score makes it undefined.
# Callers must supply their own default, and it must be the denying one.
test_toxicity_below_threshold_is_undefined_when_score_absent if {
	not cs.toxicity_below_threshold({}, 0.7)
	not cs.toxicity_below_threshold({"metrics": {"content_safety": {}}}, 0.7)
}
