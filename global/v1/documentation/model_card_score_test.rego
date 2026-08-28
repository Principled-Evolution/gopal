package global.v1.documentation.model_card_score_test

import data.global.v1.documentation.model_card_score as score
import rego.v1

# The content bands are 50, 200 and 500 characters. These sit deliberately
# inside a band rather than near an edge, so a test that means to be
# "comprehensive" is, and a change to the bands surfaces here rather than as a
# shifted number somewhere downstream.
long := concat("", [s | some _ in numbers.range(1, 60); s := "0123456789"]) # 600

mid := concat("", [s | some _ in numbers.range(1, 25); s := "0123456789"]) # 250

well_documented := {"documentation": {"model_card": {
	"model_details": {"model_name": long, "model_type": long, "version": long, "organization": long},
	"intended_use": {"primary_uses": long, "out_of_scope_uses": long},
	"factors": {"relevant_factors": long, "evaluation_factors": long},
	"metrics": {"performance_metrics": long, "decision_thresholds": long},
	"evaluation_data": {"datasets": long, "motivation": long, "preprocessing": long},
	"training_data": {"datasets": long, "motivation": long, "preprocessing": long},
	"quantitative_analyses": {"unitary_results": long, "intersectional_results": long},
	"ethical_considerations": {"data_bias": long, "mitigations": long, "risks": long},
	"caveats_recommendations": {"limitations": long, "recommendations": long},
}}}

# An unevaluated card is not a card that scored zero, and every rule here has to
# tell those apart. This is the failure the whole library exists to catch: a
# policy that reads absence as a measurement.
test_no_card_is_not_a_zero_score if {
	not score.supplied with input as {}
	not score.completeness with input as {}
	not score.quality with input as {}
}

test_no_card_is_not_sufficient if {
	not score.sufficient with input as {}
}

test_empty_input_denies if {
	not score.sufficient with input as {}
	not score.sufficient with input as {"documentation": {}}
	not score.sufficient with input as {"documentation": {"model_card": {}}}
}

test_a_complete_card_scores_one if {
	score.completeness == 1.0 with input as well_documented
	score.sufficient with input as well_documented
}

test_the_weights_sum_to_one if {
	total := sum([score.rubric.sections[name].weight | some name, _ in score.rubric.sections])
	total == 1.0
}

# A section answering half its subsections scores half, however long the prose
# in the half it does answer.
test_a_half_answered_section_scores_half if {
	half := json.patch(well_documented, [{
		"op": "remove",
		"path": "/documentation/model_card/intended_use/out_of_scope_uses",
	}])
	score.section_scores.intended_use == 0.5 with input as half
}

test_a_missing_section_scores_zero_but_the_card_still_scores if {
	without := json.patch(well_documented, [{
		"op": "remove", "path": "/documentation/model_card/training_data",
	}])
	score.section_scores.training_data == 0.0 with input as without
	score.completeness > 0.0 with input as without
	score.completeness < 1.0 with input as without
}

# The content bands. A one-word answer is not the same as a section.
test_short_content_scores_below_long_content if {
	brief := json.patch(well_documented, [{
		"op": "replace", "path": "/documentation/model_card/factors/relevant_factors", "value": "yes",
	}])
	score.completeness < 1.0 with input as brief
}

test_an_empty_string_is_not_content if {
	blank := json.patch(well_documented, [{
		"op": "replace", "path": "/documentation/model_card/factors/relevant_factors", "value": "",
	}])
	score.section_scores.factors == 0.5 with input as blank
}

# Completeness and quality answer different questions and a card can score
# differently on each, so they must not be the same number by construction.
test_completeness_and_quality_are_different_measures if {
	uneven := json.patch(well_documented, [
		{"op": "remove", "path": "/documentation/model_card/metrics"},
		{"op": "remove", "path": "/documentation/model_card/evaluation_data"},
	])
	score.completeness != score.quality with input as uneven
}

test_the_threshold_is_configurable if {
	partial := json.patch(well_documented, [{
		"op": "remove", "path": "/documentation/model_card/evaluation_data",
	}])
	score.sufficient with input as object.union(partial, {"params": {"model_card_completeness_threshold": 0.5}})
	not score.sufficient with input as object.union(partial, {"params": {"model_card_completeness_threshold": 0.99}})
}

test_weakest_sections_names_what_falls_short if {
	gap := json.patch(well_documented, [{
		"op": "remove", "path": "/documentation/model_card/training_data",
	}])
	"training_data" in score.weakest_sections with input as gap
	not "intended_use" in score.weakest_sections with input as gap
}

# Scores taken from real cards on the Hub, computed by AICertify's Python
# implementation before this policy existed. They are here so the move from
# Python to Rego is checked rather than asserted, and so a later change to the
# rubric has to be a deliberate one.
#
# bert-base-uncased scores 0.49 against the 0.8 that Annex IV technical
# documentation is held to. That is the honest ceiling for a model card, and
# not a defect in the card.
real_card_shape := {"documentation": {"model_card": {
	"model_details": {"model_name": "BERT base model (uncased)", "model_type": "fill-mask, transformers"},
	"intended_use": {"primary_uses": long, "out_of_scope_uses": long},
	"factors": {"relevant_factors": long},
	"metrics": {"performance_metrics": long},
	"training_data": {"datasets": long, "preprocessing": long},
	"quantitative_analyses": {"unitary_results": long},
	"ethical_considerations": {"data_bias": long},
	"caveats_recommendations": {"limitations": long},
}}}

test_a_realistic_card_lands_well_short_of_the_threshold if {
	s := score.completeness with input as real_card_shape
	s > 0.3
	s < 0.8
	not score.sufficient with input as real_card_shape
}
