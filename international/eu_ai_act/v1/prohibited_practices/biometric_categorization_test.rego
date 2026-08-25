package international.eu_ai_act.v1.prohibited_practices.biometric_categorization_test

import data.international.eu_ai_act.v1.prohibited_practices.biometric_categorization as policy
import rego.v1

categorising := {"system": {
	"performs_biometric_categorisation": true,
	"inferred_attributes": ["sexual_orientation"],
	"dataset_labelling_only": false,
	"law_enforcement_use": false,
}}

test_deny_inferring_a_sensitive_attribute if {
	not policy.allow with input as categorising
}

test_deny_inferring_religious_belief if {
	not policy.allow with input as json.patch(categorising, [{"op": "replace", "path": "/system/inferred_attributes", "value": ["religious_or_philosophical_beliefs"]}])
}

test_deny_inferring_trade_union_membership if {
	not policy.allow with input as json.patch(categorising, [{"op": "replace", "path": "/system/inferred_attributes", "value": ["trade_union_membership"]}])
}

# Attributes outside the Article 5(1)(g) list are not caught by this rule.
test_allow_inferring_a_non_sensitive_attribute if {
	policy.allow with input as json.patch(categorising, [{"op": "replace", "path": "/system/inferred_attributes", "value": ["age_bracket"]}])
}

# Article 5(1)(g) exempts labelling or filtering of lawfully acquired datasets.
test_allow_under_dataset_labelling_exemption if {
	policy.allow with input as json.patch(categorising, [{"op": "replace", "path": "/system/dataset_labelling_only", "value": true}])
}

# And categorisation of biometric data in the area of law enforcement.
test_allow_under_law_enforcement_exemption if {
	policy.allow with input as json.patch(categorising, [{"op": "replace", "path": "/system/law_enforcement_use", "value": true}])
}

test_allow_when_no_biometric_categorisation_performed if {
	policy.allow with input as json.patch(categorising, [{"op": "replace", "path": "/system/performs_biometric_categorisation", "value": false}])
}

test_report_names_only_the_sensitive_attributes if {
	report := policy.report with input as json.patch(categorising, [{"op": "replace", "path": "/system/inferred_attributes", "value": ["race", "age_bracket", "sex_life"]}])
	report.metrics.sensitive_attributes_inferred.value == ["race", "sex_life"]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
