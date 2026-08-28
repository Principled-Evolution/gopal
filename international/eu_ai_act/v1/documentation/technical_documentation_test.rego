package international.eu_ai_act.v1.documentation.technical_documentation_test

import data.international.eu_ai_act.v1.documentation.technical_documentation as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_allow_denies_on_empty_input if {
	not policy.allow with input as {}
}

# A threshold's documented default must apply when the caller sends no params
# at all. This policy read `object.get(input.params, "completeness_threshold",
# 0.8)`, and when the input carried no `params` key `input.params` was
# undefined, so object.get was undefined, so the rule body failed and the
# `default := false` denied. A well-documented 0.8 default that never applied,
# across 47 call sites in 10 files. The safe form is
# `object.get(input, ["params", ...], default)`, which handles the absent key.
no_params := {"metrics": {"model_card": {
	"completeness": 0.86,
	"quality": 0.81,
	"compliance_level": 0.9,
	"section_scores": {"intended_use": 0.9},
}}}

test_documented_defaults_apply_when_no_params_are_sent if {
	policy.completeness_sufficient with input as no_params
	policy.quality_sufficient with input as no_params
}

test_an_explicit_param_still_overrides_the_default if {
	stricter := object.union(no_params, {"params": {"completeness_threshold": 0.95}})
	not policy.completeness_sufficient with input as stricter
}

# Supplying the card itself is now enough: the score is computed by
# global/v1/documentation/model_card_score rather than having to be produced by
# an evaluator first. One rubric, in Rego, so the same rules run here and in the
# browser through WASM.
raw_card := {"documentation": {"model_card": {
	"model_details": {"model_name": "demo", "model_type": "text-classification"},
	"intended_use": {"primary_uses": concat("", [s | some _ in numbers.range(1, 60); s := "0123456789"])},
	"training_data": {"datasets": concat("", [s | some _ in numbers.range(1, 60); s := "0123456789"])},
}}}

test_a_card_with_no_supplied_metrics_is_still_scored if {
	policy.model_card_completeness > 0.0 with input as raw_card
	not policy.completeness_sufficient with input as raw_card
}

# Zero regression. An input carrying the metric behaves exactly as before, and
# where both are present the supplied number wins, so nothing that used to pass
# starts failing because a card happens to be attached.
test_a_supplied_metric_still_works if {
	policy.completeness_sufficient with input as {"metrics": {"model_card": {"completeness": 0.95}}}
}

test_a_supplied_metric_wins_over_the_computed_one if {
	both := object.union(raw_card, {"metrics": {"model_card": {"completeness": 0.95}}})
	policy.model_card_completeness == 0.95 with input as both
	policy.completeness_sufficient with input as both
}

# Neither route supplied is not a zero score. The rule stays undefined and the
# default denies, rather than reporting an undocumented system as measured.
test_neither_route_denies_rather_than_scoring_zero if {
	not policy.completeness_sufficient with input as {}
	not policy.model_card_completeness with input as {}
}
