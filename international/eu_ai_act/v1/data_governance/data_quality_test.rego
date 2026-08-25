package international.eu_ai_act.v1.data_governance.data_quality_test

import data.international.eu_ai_act.v1.data_governance.data_quality as policy
import rego.v1

compliant := {
	"system": {"high_risk": true},
	"datasets": {
		"relevant": true,
		"sufficiently_representative": true,
		"errors_addressed": true,
		"complete_to_the_extent_possible": true,
		"contextual_characteristics_considered": true,
	},
}

test_allow_when_all_criteria_met if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_when_risk_class_not_asserted if {
	not policy.allow with input as json.patch(compliant, [{"op": "remove", "path": "/system/high_risk"}])
}

# The four Article 10(3) criteria are cumulative.
test_deny_when_not_representative if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/datasets/sufficiently_representative", "value": false}])
}

test_deny_when_errors_not_addressed if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/datasets/errors_addressed", "value": false}])
}

# Article 10(4): the criterion most often skipped when a dataset is reused
# across markets.
test_deny_when_deployment_setting_not_considered if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/datasets/contextual_characteristics_considered", "value": false}])
}

test_report_names_the_unmet_criteria if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/datasets/relevant", "value": false},
		{"op": "replace", "path": "/datasets/errors_addressed", "value": false},
	])
	report.metrics.article_10_3_criteria_unmet.value == [
		"errors addressed to the extent possible",
		"relevant",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
