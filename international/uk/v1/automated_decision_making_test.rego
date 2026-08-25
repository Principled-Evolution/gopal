package international.uk.v1.automated_decision_making_test

import data.international.uk.v1.automated_decision_making as policy
import rego.v1

all_safeguards := {
	"information_provided": true,
	"representations_enabled": true,
	"human_intervention_available": true,
	"decision_contestable": true,
}

solely_automated_ordinary := {
	"decision": {
		"significant": true,
		"meaningful_human_involvement": false,
		"special_category_data_involved": false,
	},
	"safeguards": all_safeguards,
}

# Article 22C satisfied for ordinary personal data. Under the pre-DUAA Article 22
# this decision would have been prohibited outright absent an exception.
test_allow_solely_automated_ordinary_data_with_safeguards if {
	policy.allow with input as solely_automated_ordinary
}

test_deny_when_a_safeguard_is_missing if {
	not policy.allow with input as json.patch(solely_automated_ordinary, [{
		"op": "replace", "path": "/safeguards/human_intervention_available", "value": false,
	}])
}

test_report_names_the_missing_safeguards if {
	report := policy.report with input as json.patch(solely_automated_ordinary, [
		{"op": "replace", "path": "/safeguards/human_intervention_available", "value": false},
		{"op": "replace", "path": "/safeguards/decision_contestable", "value": false},
	])
	report.metrics.article_22c_safeguards.value == [
		"ability to contest the decision",
		"ability to obtain human intervention",
	]
}

# Article 22A: meaningful human involvement takes the decision out of scope.
test_allow_when_a_human_is_meaningfully_involved if {
	policy.allow with input as json.patch(solely_automated_ordinary, [
		{"op": "replace", "path": "/decision/meaningful_human_involvement", "value": true},
		{"op": "replace", "path": "/safeguards/information_provided", "value": false},
		{"op": "replace", "path": "/safeguards/representations_enabled", "value": false},
		{"op": "replace", "path": "/safeguards/human_intervention_available", "value": false},
		{"op": "replace", "path": "/safeguards/decision_contestable", "value": false},
	])
}

# A decision with no legal or similarly significant effect is out of scope.
test_allow_when_decision_is_not_significant if {
	policy.allow with input as json.patch(solely_automated_ordinary, [
		{"op": "replace", "path": "/decision/significant", "value": false},
		{"op": "replace", "path": "/safeguards/decision_contestable", "value": false},
	])
}

# Article 22B: special category data stays restricted, so the Article 22C
# safeguards alone are not enough.
test_deny_special_category_with_safeguards_but_no_article_9_condition if {
	not policy.allow with input as json.patch(solely_automated_ordinary, [{
		"op": "replace", "path": "/decision/special_category_data_involved", "value": true,
	}])
}

test_allow_special_category_with_article_9_condition if {
	not_denied := json.patch(solely_automated_ordinary, [
		{"op": "replace", "path": "/decision/special_category_data_involved", "value": true},
		{"op": "add", "path": "/decision/article_9_condition", "value": "explicit_consent"},
	])
	policy.allow with input as not_denied
}

# An empty string is not a condition.
test_deny_special_category_with_empty_article_9_condition if {
	not policy.allow with input as json.patch(solely_automated_ordinary, [
		{"op": "replace", "path": "/decision/special_category_data_involved", "value": true},
		{"op": "add", "path": "/decision/article_9_condition", "value": ""},
	])
}

# Silence must not read as "out of scope". Both Article 22A facts have to be
# asserted before the policy will treat a decision as outside the regime.
test_deny_on_empty_input if {
	not policy.allow with input as {}
}

test_deny_when_significance_is_not_asserted if {
	not policy.allow with input as {
		"decision": {"meaningful_human_involvement": false},
		"safeguards": all_safeguards,
	}
}

test_deny_when_human_involvement_is_not_asserted if {
	not policy.allow with input as {
		"decision": {"significant": false},
		"safeguards": all_safeguards,
	}
}
