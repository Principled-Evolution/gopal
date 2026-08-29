package helper_functions.metrics_test

import data.helper_functions.metrics
import rego.v1

# The canonical spelling resolves.
test_canonical_path_resolves if {
	metrics.resolve({"metrics": {"content_safety": {"score": 0.77}}}, "metrics.content_safety.score") == 0.77
}

test_max_toxicity_resolves if {
	metrics.resolve({"metrics": {"toxicity": {"max_toxicity": 0.8}}}, "metrics.toxicity.max_toxicity") == 0.8
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
	metrics.resolve_or({"metrics": {"fairness": {"score": 0.6}}}, "metrics.fairness.score", -1) == 0.6
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

# An aggregate and a worst-case maximum are different statistics, compared
# against different thresholds: 0.1 for the aggregate throughout global/, 0.7
# for the maximum in the EU transparency policy. Merging them would feed a
# worst case into a threshold meant for an average, failing almost any real
# system. An earlier version of the table did merge them.
test_toxicity_score_and_max_toxicity_are_separate_metrics if {
	doc := {"metrics": {"toxicity": {"max_toxicity": 0.8}}}
	not metrics.resolve(doc, "metrics.toxicity.score")
	metrics.resolve(doc, "metrics.toxicity.max_toxicity") == 0.8
}

test_an_aggregate_does_not_answer_a_worst_case_question if {
	doc := {"metrics": {"toxicity": {"score": 0.05}}}
	metrics.resolve(doc, "metrics.toxicity.score") == 0.05
	not metrics.resolve(doc, "metrics.toxicity.max_toxicity")
}

# A safety score must never resolve as toxicity. They point in opposite
# directions, and conflating them inverted a verdict in
# global/v1/common/content_safety once already.
test_a_safety_score_never_resolves_as_toxicity if {
	doc := {"metrics": {"content_safety": {"score": 0.95}}}
	not metrics.resolve(doc, "metrics.toxicity.score")
	not metrics.resolve(doc, "metrics.toxicity.max_toxicity")
	metrics.resolve(doc, "metrics.content_safety.score") == 0.95
}

# The table carries no legacy spellings after 2.0.0, so the deprecation
# machinery is exercised against a table supplied by the test rather than
# against the real one. It has to keep working: it is how the next spelling
# gets retired, and COMPATIBILITY.md promises it.
sample_aliases := {"metrics.fairness.score": [
	["metrics", "fairness", "score"],
	["evaluation", "fairness_score"],
	["fairness_score"],
]}

test_deprecated_names_what_was_sent_and_what_to_send if {
	used := metrics.deprecated({
		"fairness_score": 0.9,
		"evaluation": {"fairness_score": 0.8},
	}) with metrics.aliases as sample_aliases

	used.fairness_score == "metrics.fairness.score"
	used["evaluation.fairness_score"] == "metrics.fairness.score"
}

# The state this is trying to reach. An input using only canonical names has
# nothing to report, so an empty result is the success condition rather than a
# missing check.
test_canonical_input_reports_nothing if {
	metrics.deprecated({"metrics": {"toxicity": {"score": 0.01}}}) == {}
	metrics.deprecated({}) == {}
}

# The canonical path is the first entry in every alias list, so a naive
# implementation reports it as a legacy spelling of itself.
test_the_canonical_spelling_is_not_reported_as_legacy if {
	used := metrics.deprecated({"metrics": {"content_safety": {"score": 0.9}}})
	not "metrics.content_safety.score" in object.keys(used)
}

test_both_spellings_present_reports_only_the_legacy_one if {
	used := metrics.deprecated({
		"metrics": {"fairness": {"score": 0.01}},
		"evaluation": {"fairness_score": 0.02},
	}) with metrics.aliases as sample_aliases

	used == {"evaluation.fairness_score": "metrics.fairness.score"}
}

# The 2.0.0 contract, stated as a test rather than only in the changelog. These
# twenty spellings resolved in 1.x and must not resolve now; a well-meaning
# re-addition to the alias table would revive an input format the library no
# longer claims to read, and nothing else in the suite would notice.
test_retired_spellings_no_longer_resolve if {
	every doc, canonical in {
		{"evaluation": {"content_safety": {"score": 0.4}}}: "metrics.content_safety.score",
		{"evaluation": {"content_safety_score": 0.4}}: "metrics.content_safety.score",
		{"content_safety": {"score": 0.4}}: "metrics.content_safety.score",
		{"content_safety_score": 0.4}: "metrics.content_safety.score",
		{"evaluation": {"fairness": {"score": 0.4}}}: "metrics.fairness.score",
		{"evaluation": {"fairness_score": 0.4}}: "metrics.fairness.score",
		{"fairness_score": 0.4}: "metrics.fairness.score",
		{"evaluation": {"risk_management": {"score": 0.4}}}: "metrics.risk_management.score",
		{"evaluation": {"risk_management_score": 0.4}}: "metrics.risk_management.score",
		{"risk_management_score": 0.4}: "metrics.risk_management.score",
		{"evaluation": {"toxicity_score": 0.4}}: "metrics.toxicity.score",
		{"content_safety": {"toxicity_score": 0.4}}: "metrics.toxicity.score",
		{"summary": {"toxicity_values": {"max_toxicity": 0.4}}}: "metrics.toxicity.max_toxicity",
		{"content_safety": {"max_toxicity": 0.4}}: "metrics.toxicity.max_toxicity",
		{"documentation": {"model_card": {"completeness_score": 0.4}}}: "metrics.model_card.completeness",
		{"documentation": {"model_card": {"completeness": 0.4}}}: "metrics.model_card.completeness",
		{"evaluation": {"patient_safety": {"score": 0.4}}}: "metrics.patient_safety.score",
		{"evaluation": {"clinical_validation": {"score": 0.4}}}: "metrics.clinical_validation.score",
		{"evaluation": {"risk_assessment": {"score": 0.4}}}: "metrics.risk_assessment.score",
		{"governance": {"audit_logging": {"completeness_score": 0.4}}}: "metrics.audit_logging.completeness",
	} {
		not metrics.resolve(doc, canonical)
	}
}

# And the table itself carries nothing but canonical names, so a spelling cannot
# creep back in without this failing.
test_the_table_has_no_legacy_spellings if {
	every name, paths in metrics.aliases {
		count(paths) == 1
		concat(".", paths[0]) == name
	}
}
