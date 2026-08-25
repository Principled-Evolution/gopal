package international.eu_ai_act.v1.documentation.automated_logs_test

import data.international.eu_ai_act.v1.documentation.automated_logs as policy
import rego.v1

compliant := {
	"system": {"high_risk": true, "annex_iii_1_a_biometric": false},
	"logging": {
		"automatic_recording_enabled": true,
		"covers_system_lifetime": true,
		"identifies_risk_situations": true,
		"supports_post_market_monitoring": true,
	},
}

biometric := json.patch(compliant, [
	{"op": "replace", "path": "/system/annex_iii_1_a_biometric", "value": true},
	{"op": "add", "path": "/logging/records_usage_period", "value": true},
	{"op": "add", "path": "/logging/records_reference_database", "value": true},
	{"op": "add", "path": "/logging/records_input_data", "value": true},
	{"op": "add", "path": "/logging/records_verifying_persons", "value": true},
])

test_allow_baseline_logging if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_without_automatic_recording if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/logging/automatic_recording_enabled", "value": false}])
}

# Article 12(2): logging has to be capable of surfacing risk situations, not
# merely of recording activity.
test_deny_when_logging_cannot_identify_risk_situations if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/logging/identifies_risk_situations", "value": false}])
}

test_deny_when_logging_does_not_cover_the_lifetime if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/logging/covers_system_lifetime", "value": false}])
}

# Article 12(3) engages only for Annex III point 1(a) systems, and then all
# four fields are required.
test_allow_biometric_system_with_all_four_fields if {
	policy.allow with input as biometric
}

test_deny_biometric_system_missing_a_field if {
	not policy.allow with input as json.patch(biometric, [{"op": "replace", "path": "/logging/records_reference_database", "value": false}])
}

test_report_names_the_missing_biometric_fields if {
	report := policy.report with input as json.patch(biometric, [
		{"op": "replace", "path": "/logging/records_input_data", "value": false},
		{"op": "replace", "path": "/logging/records_verifying_persons", "value": false},
	])
	report.metrics.annex_iii_1_a_fields_missing.value == [
		"input data for which the search led to a match",
		"persons involved in verifying the results",
	]
}

# A non-biometric high-risk system is not held to Article 12(3).
test_non_biometric_system_not_held_to_article_12_3 if {
	policy.allow with input as compliant
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
