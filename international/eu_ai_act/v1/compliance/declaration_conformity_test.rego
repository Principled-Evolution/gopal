package international.eu_ai_act.v1.compliance.declaration_conformity_test

import data.international.eu_ai_act.v1.compliance.declaration_conformity as policy
import rego.v1

compliant := {"system": {"high_risk": true}, "declaration": {
	"drawn_up": true,
	"machine_readable": true,
	"annex_v_content_complete": true,
	"retained_ten_years": true,
	"translated_for_market": true,
}}

test_allow_when_all_requirements_met if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

# The document existing is not enough; Article 47 requires it to be machine
# readable.
test_deny_when_not_machine_readable if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/declaration/machine_readable", "value": false}])
}

test_deny_without_annex_v_content if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/declaration/annex_v_content_complete", "value": false}])
}

test_deny_without_ten_year_retention if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/declaration/retained_ten_years", "value": false}])
}

test_deny_without_translation_for_the_market if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/declaration/translated_for_market", "value": false}])
}

test_report_names_the_unmet_requirements if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/declaration/machine_readable", "value": false},
		{"op": "replace", "path": "/declaration/translated_for_market", "value": false},
	])
	report.metrics.article_47_requirements_unmet.value == [
		"Article 47(1) machine readable",
		"Article 47(2) translated for the market",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
