package international.eu_ai_act.v1.data_governance.training_data_test

import data.international.eu_ai_act.v1.data_governance.training_data as policy
import rego.v1

compliant := {
	"system": {"high_risk": true},
	"governance": {
		"design_choices_documented": true,
		"collection_process_documented": true,
		"preparation_documented": true,
		"assumptions_documented": true,
		"suitability_assessed": true,
		"bias_examined": true,
		"gaps_identified_and_addressed": true,
	},
	"special_category": {"processed_for_bias_correction": false, "safeguards_in_place": false},
}

test_allow_when_all_practices_documented if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_without_bias_examination if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/bias_examined", "value": false}])
}

test_deny_without_documented_assumptions if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/assumptions_documented", "value": false}])
}

# Identifying a gap is not the same as addressing it.
test_deny_when_gaps_not_addressed if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/gaps_identified_and_addressed", "value": false}])
}

# Article 10(5): the bias-correction basis for special category data is
# conditional on safeguards, not automatic.
test_deny_special_category_use_without_safeguards if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/special_category/processed_for_bias_correction", "value": true}])
}

test_allow_special_category_use_with_safeguards if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/special_category/processed_for_bias_correction", "value": true},
		{"op": "replace", "path": "/special_category/safeguards_in_place", "value": true},
	])
}

test_report_names_the_missing_practices if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/governance/bias_examined", "value": false},
		{"op": "replace", "path": "/governance/suitability_assessed", "value": false},
	])
	report.metrics.article_10_2_practices_missing.value == [
		"examined for bias",
		"suitability assessed",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
