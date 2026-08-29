# RequiredMetrics:
#   - system.high_risk
#   - governance.design_choices_documented
#   - governance.collection_process_documented
#   - governance.preparation_documented
#   - governance.assumptions_documented
#   - governance.suitability_assessed
#   - governance.bias_examined
#   - governance.gaps_identified_and_addressed
#   - special_category.processed_for_bias_correction
#   - special_category.safeguards_in_place
#
# RequiredParams: none
package international.eu_ai_act.v1.data_governance.training_data

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Data Governance Practices (Article 10(2) and 10(5))",
	"description": "Evaluates the data governance and management practices behind a high-risk AI system's datasets, as required by Article 10(2): documented design choices, collection processes, preparation such as annotation and labelling, the assumptions made, a suitability assessment, examination for bias, and identification of gaps with measures to address them. Where special category personal data is processed to detect and correct bias, Article 10(5) permits it only with safeguards, so that is an explicit condition.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 10(2) of the EU AI Act, data governance and management practices",
		"Article 10(5) of the EU AI Act, processing special categories of personal data for bias detection",
		"Recital 67 of the EU AI Act",
	],
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "high_risk"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "high_risk"]))
}

# The Article 10(2) practices.
practices := {
	"design choices documented": "design_choices_documented",
	"collection process documented": "collection_process_documented",
	"data preparation documented": "preparation_documented",
	"assumptions documented": "assumptions_documented",
	"suitability assessed": "suitability_assessed",
	"examined for bias": "bias_examined",
	"gaps identified and addressed": "gaps_identified_and_addressed",
}

missing_practices contains label if {
	some label, field in practices
	object.get(input, ["governance", field], false) != true
}

default governance_practices_met := false

governance_practices_met if {
	count(missing_practices) == 0
}

# Article 10(5): the bias-correction basis for special category data is
# conditional on safeguards.
default special_category_processed := false

special_category_processed if {
	declarations.resolve(input, ["special_category", "processed_for_bias_correction"]) == true
}

default special_category_lawful := false

special_category_lawful if {
	not special_category_processed
}

special_category_lawful if {
	special_category_processed
	declarations.resolve(input, ["special_category", "safeguards_in_place"]) == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	governance_practices_met
	special_category_lawful
}

policy_metrics := {
	"article_10_2_practices_missing": {
		"name": "Article 10(2) Data Governance Practices Missing",
		"value": sort([p | some p in missing_practices]),
		"control_passed": governance_practices_met,
	},
	"special_category_safeguards": {
		"name": "Article 10(5) Safeguards Where Special Category Data Is Used for Bias Correction",
		"value": special_category_processed,
		"control_passed": special_category_lawful,
	},
}

report := reporting.compose_report("eu_ai_act.data_governance.training_data", allow, policy_metrics)
