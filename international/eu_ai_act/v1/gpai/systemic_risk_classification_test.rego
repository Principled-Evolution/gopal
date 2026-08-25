package international.eu_ai_act.v1.gpai.systemic_risk_classification_test

import data.international.eu_ai_act.v1.gpai.systemic_risk_classification as policy
import rego.v1

below_threshold := {
	"model": {"general_purpose": true, "cumulative_training_compute_flops": 1e24, "commission_designated_systemic_risk": false},
	"notification": {"commission_notified": false},
	"systemic_risk": {},
}

compliant_systemic := {
	"model": {"general_purpose": true, "cumulative_training_compute_flops": 5e25, "commission_designated_systemic_risk": false},
	"notification": {"commission_notified": true},
	"systemic_risk": {
		"model_evaluation_with_adversarial_testing": true,
		"risks_assessed_and_mitigated": true,
		"serious_incidents_reported_to_ai_office": true,
		"cybersecurity_protection_adequate": true,
	},
}

test_allow_gpai_below_the_compute_threshold if {
	policy.allow with input as below_threshold
}

test_allow_when_model_is_not_general_purpose if {
	policy.allow with input as {"model": {"general_purpose": false}}
}

# Article 51(2): the presumption bites above 10^25 FLOPs.
test_deny_above_threshold_without_notification_or_controls if {
	not policy.allow with input as json.patch(below_threshold, [{"op": "replace", "path": "/model/cumulative_training_compute_flops", "value": 5e25}])
}

test_allow_systemic_risk_model_meeting_every_obligation if {
	policy.allow with input as compliant_systemic
}

# Article 52(1): notification is a separate duty from the Article 55 controls.
test_deny_systemic_risk_model_without_commission_notification if {
	not policy.allow with input as json.patch(compliant_systemic, [{"op": "replace", "path": "/notification/commission_notified", "value": false}])
}

test_deny_without_adversarial_testing if {
	not policy.allow with input as json.patch(compliant_systemic, [{"op": "replace", "path": "/systemic_risk/model_evaluation_with_adversarial_testing", "value": false}])
}

test_deny_without_incident_reporting_to_the_ai_office if {
	not policy.allow with input as json.patch(compliant_systemic, [{"op": "replace", "path": "/systemic_risk/serious_incidents_reported_to_ai_office", "value": false}])
}

# Article 51(1)(b): a Commission decision designates a model regardless of its
# training compute.
test_commission_designation_applies_below_the_threshold if {
	not policy.allow with input as json.patch(below_threshold, [{"op": "replace", "path": "/model/commission_designated_systemic_risk", "value": true}])
}

test_report_names_the_unmet_article_55_obligations if {
	report := policy.report with input as json.patch(compliant_systemic, [
		{"op": "replace", "path": "/systemic_risk/cybersecurity_protection_adequate", "value": false},
		{"op": "replace", "path": "/systemic_risk/risks_assessed_and_mitigated", "value": false},
	])
	report.metrics.article_55_obligations_unmet.value == [
		"Article 55(1)(b) systemic risks assessed and mitigated",
		"Article 55(1)(d) adequate cybersecurity protection",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
