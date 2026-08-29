# RequiredInputs:
#   - documentation.model_card.<section>.<subsection> (text)
#
# RequiredParams:
#   - model_card_completeness_threshold (default 0.8)
#
# ProvidedMetrics:
#   - metrics.model_card.completeness
#   - metrics.model_card.quality
#   - metrics.model_card.section_scores
#
# Metrics this policy computes from declared input rather than needing an
# evaluator to measure. A metric listed here is not a gap in anybody's tooling:
# supplying the documentation is enough, and the library derives the number.
# Tooling that reports which metrics still need an evaluator should read this
# alongside RequiredMetrics, or it will ask for work already done.
#
package global.v1.documentation.model_card_score

import rego.v1

metadata := {
	"title": "Model Card Documentation Completeness",
	"description": "Scores a structured model card against the nine sections of Mitchell et al., Model Cards for Model Reporting, weighted towards the sections EU AI Act Annex IV technical documentation depends on. This is a documentation-completeness measure and not a compliance verdict: a model card answers part of what Annex IV asks and then stops. The rubric lives here rather than in an evaluator because which sections a card must carry, what each is worth, and how much text counts as content are normative judgements, which is what this library is for. Keeping them here also means one implementation: the same rules run through opa eval on a command line and through WASM in a browser, instead of being written once per runtime and kept in step by hand.",
	"version": "1.0.0",
	"category": "Global",
	"references": [
		"Mitchell et al., Model Cards for Model Reporting, FAT* 2019",
		"EU AI Act, Annex IV Technical Documentation",
		"Hugging Face model card specification: https://huggingface.co/docs/hub/model-cards",
	],
}

# The rubric, as data rather than as code, so it can be read and argued with
# without following control flow.
rubric := {
	"sections": {
		"caveats_recommendations": {
			"name": "Caveats and Recommendations",
			"weight": 0.1,
			"subsections": [
				"limitations",
				"recommendations",
			],
		},
		"ethical_considerations": {
			"name": "Ethical Considerations",
			"weight": 0.15,
			"subsections": [
				"data_bias",
				"mitigations",
				"risks",
			],
		},
		"evaluation_data": {
			"name": "Evaluation Data",
			"weight": 0.1,
			"subsections": [
				"datasets",
				"motivation",
				"preprocessing",
			],
		},
		"factors": {
			"name": "Factors",
			"weight": 0.1,
			"subsections": [
				"relevant_factors",
				"evaluation_factors",
			],
		},
		"intended_use": {
			"name": "Intended Use",
			"weight": 0.15,
			"subsections": [
				"primary_uses",
				"out_of_scope_uses",
			],
		},
		"metrics": {
			"name": "Metrics",
			"weight": 0.1,
			"subsections": [
				"performance_metrics",
				"decision_thresholds",
			],
		},
		"model_details": {
			"name": "Model Details",
			"weight": 0.15,
			"subsections": [
				"model_name",
				"model_type",
				"version",
				"organization",
			],
		},
		"quantitative_analyses": {
			"name": "Quantitative Analyses",
			"weight": 0.05,
			"subsections": [
				"unitary_results",
				"intersectional_results",
			],
		},
		"training_data": {
			"name": "Training Data",
			"weight": 0.1,
			"subsections": [
				"datasets",
				"motivation",
				"preprocessing",
			],
		},
	},
	"bands": {
		"comprehensive": 500,
		"minimal": 50,
		"partial": 200,
	},
	"levels": {
		"comprehensive": 1.0,
		"minimal": 0.3,
		"missing": 0.0,
		"partial": 0.7,
	},
}

# Which headings in a published model card establish which subsection.
#
# Cards do not use the nine section names from the paper. They use the current
# Hugging Face template, or the older convention most high-download
# repositories still carry, or whatever their author wrote. Matching only one
# of those scores bert-base-uncased and gpt2 as almost undocumented, which is a
# fact about the matcher rather than the cards.
#
# This lives here rather than in whichever parser happens to be running,
# because a second copy of it drifts exactly the way a second copy of the
# scoring did. A parser reads it from the policy, turns markdown into the
# structured card below, and scores nothing itself.
heading_sources := {
	"caveats_recommendations": {
		"limitations": [
			"limitations",
			"known limitations",
			"limitations and bias",
			"caveats",
		],
		"recommendations": [
			"recommendations",
			"caveats and recommendations",
		],
	},
	"ethical_considerations": {
		"data_bias": [
			"bias, risks, and limitations",
			"risks, limitations and biases",
			"limitations and bias",
			"bias",
		],
		"mitigations": [
			"recommendations",
			"mitigations",
			"mitigation",
		],
		"risks": [
			"risks",
			"bias, risks, and limitations",
			"risks, limitations and biases",
			"ethical considerations",
		],
	},
	"evaluation_data": {
		"datasets": [
			"evaluation data",
			"testing data",
			"test data",
			"evaluation dataset",
		],
	},
	"factors": {
		"evaluation_factors": [
			"evaluation factors",
			"testing data, factors & metrics",
		],
		"relevant_factors": [
			"factors",
			"relevant factors",
			"bias, risks, and limitations",
			"risks, limitations and biases",
			"limitations and bias",
		],
	},
	"intended_use": {
		"out_of_scope_uses": [
			"out-of-scope use",
			"out of scope use",
			"misuse",
			"limitations and bias",
			"known limitations",
		],
		"primary_uses": [
			"direct use",
			"intended use",
			"intended uses",
			"intended uses & limitations",
			"intended uses and limitations",
			"uses",
			"downstream use",
			"usage",
		],
	},
	"metrics": {
		"performance_metrics": [
			"metrics",
			"evaluation",
			"evaluation results",
			"results",
		],
	},
	"model_details": {
		"model_type": [
			"model details",
			"model description",
			"model summary",
			"model overview",
			"model architecture",
		],
	},
	"quantitative_analyses": {
		"unitary_results": [
			"evaluation results",
			"results",
			"benchmark results",
			"performance",
		],
	},
	"training_data": {
		"datasets": [
			"training data",
			"training dataset",
			"training details",
			"training",
		],
		"preprocessing": [
			"preprocessing",
			"data preprocessing",
			"training procedure",
		],
	},
}

card := object.get(input, ["documentation", "model_card"], {})

# How much content a subsection carries. Length is a crude proxy for substance
# and is not defended as more than that; it distinguishes a filled section from
# an empty one and a sentence from a section, which is what the score needs.
band(text) := 0.0 if {
	count(text) == 0
} else := 0.3 if {
	count(text) < rubric.bands.minimal
} else := 0.7 if {
	count(text) < rubric.bands.partial
} else := 1.0

subsection_score(section, name) := score if {
	text := object.get(card, [section, name], "")
	is_string(text)
	score := band(text)
} else := 0.0

# A section scores the mean of its required subsections, so a section that
# answers two of four questions scores half however long its prose is.
section_scores[section] := score if {
	some section, spec in rubric.sections
	count(object.get(card, section, {})) > 0
	score := sum([subsection_score(section, name) | some name in spec.subsections]) / count(spec.subsections)
}

section_scores[section] := 0.0 if {
	some section, _ in rubric.sections
	count(object.get(card, section, {})) == 0
}

# Absent, not zero, when no card was supplied at all. A card nobody provided is
# not a card that scored badly, and a policy comparing against a threshold must
# be able to tell those apart.
default supplied := false

supplied if count(card) > 0

completeness := sum([weighted |
	some section, spec in rubric.sections
	weighted := object.get(section_scores, section, 0.0) * spec.weight
]) if {
	supplied
}

# Quality bands each section by its own score and averages those, which asks
# how good the content that is there is. Completeness asks how much of it
# exists. They are different questions and a card can score very differently on
# each.
quality := sum([rubric.levels[level] |
	some section, _ in rubric.sections
	level := section_band(object.get(section_scores, section, 0.0))
]) / count(rubric.sections) if {
	supplied
}

section_band(score) := "missing" if {
	score == 0.0
} else := "minimal" if {
	score < 0.3
} else := "partial" if {
	score < 0.7
} else := "comprehensive"

default sufficient := false

sufficient if {
	completeness >= object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
}

# Sections worth improving first, heaviest shortfall first is left to the
# caller; this reports which fall short of the same bar the whole card is held
# to.
weakest_sections := [section |
	some section, _ in rubric.sections
	object.get(section_scores, section, 0.0) < object.get(input, ["params", "model_card_completeness_threshold"], 0.8)
]
