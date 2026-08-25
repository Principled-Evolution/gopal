package international.eu_ai_act.v1.obligations.importer_obligations_test

import data.international.eu_ai_act.v1.obligations.importer_obligations as policy
import rego.v1

compliant := {"system": {"high_risk": true}, "importer": {
	"verified_conformity_assessment": true,
	"verified_technical_documentation": true,
	"verified_ce_marking_and_declaration": true,
	"verified_authorised_representative": true,
	"identification_provided": true,
	"storage_and_transport_conditions_adequate": true,
	"documentation_retained_ten_years": true,
}}

test_allow_when_all_verifications_done if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

# The importer's role is verification before placing on the market.
test_deny_without_verifying_conformity_assessment if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/importer/verified_conformity_assessment", "value": false}])
}

test_deny_without_verifying_authorised_representative if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/importer/verified_authorised_representative", "value": false}])
}

test_deny_without_verifying_ce_marking_and_declaration if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/importer/verified_ce_marking_and_declaration", "value": false}])
}

# Article 23(5): the ten-year retention duty is part of the obligation, not an
# afterthought.
test_deny_without_ten_year_retention if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/importer/documentation_retained_ten_years", "value": false}])
}

test_deny_when_storage_conditions_jeopardise_compliance if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/importer/storage_and_transport_conditions_adequate", "value": false}])
}

test_report_names_the_unmet_obligations if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/importer/identification_provided", "value": false},
		{"op": "replace", "path": "/importer/documentation_retained_ten_years", "value": false},
	])
	report.metrics.article_23_obligations_unmet.value == [
		"Article 23(3) importer identification provided",
		"Article 23(5) documentation retained for ten years",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
