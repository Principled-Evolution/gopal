package international.uk.v1.fairness_test

import data.international.uk.v1.fairness as policy
import rego.v1

all_nine := [
	"age",
	"disability",
	"gender_reassignment",
	"marriage_and_civil_partnership",
	"pregnancy_and_maternity",
	"race",
	"religion_or_belief",
	"sex",
	"sexual_orientation",
]

compliant_input := {"fairness": {
	"bias_assessment_completed": true,
	"legal_rights_review_completed": true,
	"protected_characteristics_tested": all_nine,
	"max_disparity": 0.05,
}}

test_allow_with_full_equality_act_coverage if {
	policy.allow with input as compliant_input
}

# Testing the four characteristics a US-style protected-class list would cover
# leaves five Equality Act characteristics untested.
test_deny_on_partial_coverage if {
	not policy.allow with input as json.patch(compliant_input, [{
		"op": "replace",
		"path": "/fairness/protected_characteristics_tested",
		"value": ["age", "race", "sex", "disability"],
	}])
}

test_untested_characteristics_are_named_in_the_report if {
	report := policy.report with input as json.patch(compliant_input, [{
		"op": "replace",
		"path": "/fairness/protected_characteristics_tested",
		"value": ["age", "race", "sex", "disability"],
	}])
	report.metrics.equality_act_coverage.value == [
		"gender_reassignment",
		"marriage_and_civil_partnership",
		"pregnancy_and_maternity",
		"religion_or_belief",
		"sexual_orientation",
	]
}

test_deny_when_disparity_above_threshold if {
	not policy.allow with input as json.patch(compliant_input, [{
		"op": "replace", "path": "/fairness/max_disparity", "value": 0.25,
	}])
}

test_allow_at_threshold_boundary if {
	policy.allow with input as json.patch(compliant_input, [{
		"op": "replace", "path": "/fairness/max_disparity", "value": 0.1,
	}])
}

test_deny_without_legal_rights_review if {
	not policy.allow with input as json.patch(compliant_input, [{
		"op": "replace", "path": "/fairness/legal_rights_review_completed", "value": false,
	}])
}

# A missing disparity figure must not read as a passing one.
test_deny_when_disparity_absent if {
	not policy.allow with input as {"fairness": {
		"bias_assessment_completed": true,
		"legal_rights_review_completed": true,
		"protected_characteristics_tested": all_nine,
	}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
