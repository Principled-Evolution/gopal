package international.eu_ai_act.v1.obligations.provider_obligations_test

import data.international.eu_ai_act.v1.obligations.provider_obligations as policy
import rego.v1

compliant := {"system": {"high_risk": true}, "provider": {
	"identification_on_system_or_packaging": true,
	"quality_management_system": true,
	"technical_documentation_kept": true,
	"logs_kept": true,
	"conformity_assessment_completed": true,
	"declaration_of_conformity_drawn_up": true,
	"ce_marking_affixed": true,
	"registered_in_eu_database": true,
	"corrective_action_process": true,
	"accessibility_requirements_met": true,
}}

test_allow_when_every_obligation_met if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_when_risk_class_not_asserted if {
	not policy.allow with input as json.patch(compliant, [{"op": "remove", "path": "/system/high_risk"}])
}

# Any single outstanding limb is a breach, however good the model is.
test_deny_without_quality_management_system if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/provider/quality_management_system", "value": false}])
}

test_deny_without_conformity_assessment if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/provider/conformity_assessment_completed", "value": false}])
}

test_deny_without_ce_marking if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/provider/ce_marking_affixed", "value": false}])
}

test_deny_without_registration if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/provider/registered_in_eu_database", "value": false}])
}

test_deny_without_accessibility_requirements if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/provider/accessibility_requirements_met", "value": false}])
}

test_report_names_and_counts_the_outstanding_obligations if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/provider/ce_marking_affixed", "value": false},
		{"op": "replace", "path": "/provider/logs_kept", "value": false},
	])
	report.metrics.obligations_unmet_count.value == 2
	report.metrics.article_16_obligations_unmet.value == [
		"Article 16(e) / 19 automatically generated logs kept",
		"Article 16(h) / 48 CE marking affixed",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
