# RequiredMetrics:
#   - system.high_risk
#   - logging.automatic_recording_enabled
#   - logging.covers_system_lifetime
#   - logging.identifies_risk_situations
#   - logging.supports_post_market_monitoring
#   - system.annex_iii_1_a_biometric
#   - logging.records_usage_period
#   - logging.records_reference_database
#   - logging.records_input_data
#   - logging.records_verifying_persons
#
# RequiredParams: none
package international.eu_ai_act.v1.documentation.automated_logs

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Automatic Logging Capability (Article 12)",
	"description": "Evaluates whether a high-risk AI system technically allows the automatic recording of events over its lifetime, as Article 12 requires, with logging capable of identifying situations that may present a risk or lead to a substantial modification. Article 12(3) adds four specific fields for the remote biometric identification systems in Annex III point 1(a), so those are required only for that class and required absolutely within it.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 12(1) and 12(2) of the EU AI Act, automatic recording of events",
		"Article 12(3) of the EU AI Act, additional logging for Annex III point 1(a) systems",
		"Annex III point 1(a), remote biometric identification systems",
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

# Article 12(1) and 12(2).
default baseline_logging := false

baseline_logging if {
	declarations.resolve(input, ["logging", "automatic_recording_enabled"]) == true
	declarations.resolve(input, ["logging", "covers_system_lifetime"]) == true
	declarations.resolve(input, ["logging", "identifies_risk_situations"]) == true
	declarations.resolve(input, ["logging", "supports_post_market_monitoring"]) == true
}

# Article 12(3) applies to Annex III point 1(a) biometric identification.
default annex_iii_1_a := false

annex_iii_1_a if {
	declarations.resolve(input, ["system", "annex_iii_1_a_biometric"]) == true
}

biometric_fields := {
	"period of each use": "records_usage_period",
	"reference database checked against": "records_reference_database",
	"input data for which the search led to a match": "records_input_data",
	"persons involved in verifying the results": "records_verifying_persons",
}

missing_biometric_fields contains label if {
	annex_iii_1_a
	some label, field in biometric_fields
	object.get(input, ["logging", field], false) != true
}

default biometric_logging_met := false

biometric_logging_met if {
	not annex_iii_1_a
}

biometric_logging_met if {
	annex_iii_1_a
	count(missing_biometric_fields) == 0
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	baseline_logging
	biometric_logging_met
}

policy_metrics := {
	"baseline_logging": {
		"name": "Article 12(1)-(2) Automatic Recording Over the System Lifetime",
		"value": baseline_logging,
		"control_passed": baseline_logging,
	},
	"annex_iii_1_a_fields_missing": {
		"name": "Article 12(3) Fields Missing for Annex III 1(a) Systems",
		"value": sort([f | some f in missing_biometric_fields]),
		"control_passed": biometric_logging_met,
	},
	"annex_iii_1_a_system": {
		"name": "Remote Biometric Identification System (Annex III 1(a))",
		"value": annex_iii_1_a,
		"control_passed": biometric_logging_met,
	},
}

report := reporting.compose_report("eu_ai_act.documentation.automated_logs", allow, policy_metrics)
