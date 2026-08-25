package industry_specific.bfs.v1.uk_fca_consumer_duty_test

import data.industry_specific.bfs.v1.uk_fca_consumer_duty as policy
import rego.v1

compliant := {
	"firm": {"retail_customers_affected": true},
	"cross_cutting": {
		"good_faith_assessment_completed": true,
		"foreseeable_harm_assessment_completed": true,
		"supports_customer_objectives": true,
	},
	"outcomes": {
		"target_market_defined": true,
		"fair_value_assessment_completed": true,
		"communications_tested_for_understanding": true,
		"support_channels_free_of_unreasonable_barriers": true,
	},
	"ai": {
		"customer_facing": true,
		"decision_explainable_in_plain_language": true,
		"vulnerable_customer_handling_documented": true,
		"outcomes_monitoring_data_collected": true,
	},
	"accountability": {"smf_owner_assigned": true},
}

test_allow_when_duty_satisfied if {
	policy.allow with input as compliant
}

# The Duty is about retail customers. A wholesale-only system is out of scope
# rather than non-compliant.
test_allow_when_no_retail_customers_affected if {
	policy.allow with input as {"firm": {"retail_customers_affected": false}}
}

# But scope has to be stated.
test_deny_when_scope_not_asserted if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "remove", "path": "/firm/retail_customers_affected",
	}])
}

# The point the FCA has been clearest about: a customer-facing decision the firm
# cannot explain in plain language cannot evidence consumer understanding.
test_deny_customer_facing_ai_that_cannot_be_explained if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/ai/decision_explainable_in_plain_language", "value": false,
	}])
}

# A back-office model carries no plain-language explainability duty to a
# customer, so the same missing field is not a failure there.
test_allow_non_customer_facing_ai_without_plain_language_explanation if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/ai/customer_facing", "value": false},
		{"op": "replace", "path": "/ai/decision_explainable_in_plain_language", "value": false},
	])
}

test_deny_without_vulnerable_customer_handling if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/ai/vulnerable_customer_handling_documented", "value": false,
	}])
}

test_deny_without_foreseeable_harm_assessment if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/cross_cutting/foreseeable_harm_assessment_completed", "value": false,
	}])
}

test_deny_without_fair_value_assessment if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/outcomes/fair_value_assessment_completed", "value": false,
	}])
}

# SM&CR: accountability for the system has to land on a named person.
test_deny_without_named_senior_manager if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/accountability/smf_owner_assigned", "value": false,
	}])
}

test_report_names_the_failed_requirements if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/accountability/smf_owner_assigned", "value": false},
		{"op": "replace", "path": "/outcomes/target_market_defined", "value": false},
	])
	report.metrics.consumer_duty_requirements_failed.value == [
		"PRIN 2A.3-2A.6 retail customer outcomes",
		"SM&CR named senior manager accountability",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
