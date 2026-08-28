package helper_functions.metrics_test

import data.helper_functions.metrics
import rego.v1

# The canonical spelling resolves.
test_canonical_path_resolves if {
	metrics.resolve({"metrics": {"content_safety": {"score": 0.77}}}, "metrics.content_safety.score") == 0.77
}

# Every legacy spelling that exists in the library still resolves, so migrating
# a policy to the canonical name cannot break an input written for the old one.
test_legacy_dotted_evaluation_path_resolves if {
	metrics.resolve({"evaluation": {"content_safety": {"score": 0.42}}}, "metrics.content_safety.score") == 0.42
}

test_legacy_underscored_evaluation_path_resolves if {
	metrics.resolve({"evaluation": {"content_safety_score": 0.31}}, "metrics.content_safety.score") == 0.31
}

test_legacy_bare_score_resolves if {
	metrics.resolve({"content_safety_score": 0.11}, "metrics.content_safety.score") == 0.11
}

test_legacy_fairness_spellings_resolve if {
	metrics.resolve({"evaluation": {"fairness": {"score": 0.5}}}, "metrics.fairness.score") == 0.5
	metrics.resolve({"evaluation": {"fairness_score": 0.6}}, "metrics.fairness.score") == 0.6
	metrics.resolve({"fairness_score": 0.7}, "metrics.fairness.score") == 0.7
}

test_legacy_risk_management_spellings_resolve if {
	metrics.resolve({"evaluation": {"risk_management": {"score": 0.5}}}, "metrics.risk_management.score") == 0.5
	metrics.resolve({"evaluation": {"risk_management_score": 0.6}}, "metrics.risk_management.score") == 0.6
	metrics.resolve({"risk_management_score": 0.7}, "metrics.risk_management.score") == 0.7
}

test_legacy_toxicity_spellings_resolve if {
	metrics.resolve({"metrics": {"toxicity": {"max_toxicity": 0.8}}}, "metrics.toxicity.score") == 0.8
	metrics.resolve({"evaluation": {"toxicity_score": 0.9}}, "metrics.toxicity.score") == 0.9
}

test_legacy_model_card_spelling_resolves if {
	metrics.resolve(
		{"documentation": {"model_card": {"completeness_score": 0.65}}},
		"metrics.model_card.completeness",
	) == 0.65
}

# Order matters and must be deterministic. An input carrying both the canonical
# name and a legacy one resolves to the canonical value every time; an
# unordered search over matching paths would let OPA return either.
test_canonical_wins_over_legacy if {
	doc := {
		"metrics": {"content_safety": {"score": 0.9}},
		"evaluation": {"content_safety_score": 0.1},
		"content_safety_score": 0.2,
	}
	metrics.resolve(doc, "metrics.content_safety.score") == 0.9
}

test_earlier_legacy_wins_over_later_legacy if {
	doc := {"evaluation": {"content_safety": {"score": 0.4}}, "content_safety_score": 0.2}
	metrics.resolve(doc, "metrics.content_safety.score") == 0.4
}

# Absent means undefined, not zero. A policy that reads an unsupplied toxicity
# score as 0.0 reports an unmeasured system as safe, which is the failure this
# library exists to prevent.
test_absent_metric_is_undefined_not_zero if {
	not metrics.resolve({}, "metrics.content_safety.score")
	not metrics.resolve({"metrics": {}}, "metrics.content_safety.score")
	not metrics.resolve({"unrelated": 1}, "metrics.fairness.score")
}

test_unknown_canonical_name_is_undefined if {
	not metrics.resolve({"metrics": {"anything": {"score": 1}}}, "metrics.not_a_real_metric.score")
}

test_a_false_value_still_resolves if {
	# Guards against a null-check that also swallows legitimate false values.
	metrics.resolve({"metrics": {"fairness": {"score": false}}}, "metrics.fairness.score") == false
}

test_a_zero_value_still_resolves if {
	metrics.resolve({"metrics": {"fairness": {"score": 0}}}, "metrics.fairness.score") == 0
}

# supplied() is total, so it answers false rather than going undefined.
test_supplied_is_false_not_undefined if {
	metrics.supplied({}, "metrics.content_safety.score") == false
	metrics.supplied({"metrics": {"content_safety": {"score": 0.5}}}, "metrics.content_safety.score") == true
}

# Every canonical key names itself as its own first candidate, so the table
# cannot drift into a state where the canonical spelling is not accepted.
test_every_canonical_name_is_its_own_first_candidate if {
	every name, paths in metrics.aliases {
		concat(".", paths[0]) == name
	}
}

# resolve_or keeps a caller's sentinel. Several policies read a score with a -1
# default so that an absent metric compares below every threshold and is
# counted as a failure; losing that would turn a fail-closed check fail-open.
test_resolve_or_returns_the_value_when_present if {
	metrics.resolve_or({"evaluation": {"fairness_score": 0.6}}, "metrics.fairness.score", -1) == 0.6
}

test_resolve_or_returns_the_sentinel_when_absent if {
	metrics.resolve_or({}, "metrics.fairness.score", -1) == -1
}

test_resolve_or_does_not_swallow_a_legitimate_zero if {
	metrics.resolve_or({"metrics": {"fairness": {"score": 0}}}, "metrics.fairness.score", -1) == 0
}

test_resolve_or_does_not_swallow_a_legitimate_false if {
	metrics.resolve_or({"metrics": {"fairness": {"score": false}}}, "metrics.fairness.score", -1) == false
}
