package international.eu_ai_act.v1.gpai.downstream_transparency_test

import data.international.eu_ai_act.v1.gpai.downstream_transparency as policy
import rego.v1

compliant := {
	"model": {"general_purpose": true, "free_and_open_source": false, "parameters_publicly_available": false, "systemic_risk": false},
	"downstream": {"annex_xii_information_provided": true, "enables_downstream_compliance": true},
	"copyright": {"policy_in_place": true, "respects_article_4_3_reservations": true},
	"training_content": {"public_summary_available": true, "summary_sufficiently_detailed": true},
}

test_allow_when_all_three_obligations_met if {
	policy.allow with input as compliant
}

test_allow_when_not_general_purpose if {
	policy.allow with input as {"model": {"general_purpose": false}}
}

test_deny_without_downstream_information if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/downstream/annex_xii_information_provided", "value": false}])
}

# Article 53(1)(c): a copyright policy that ignores the Article 4(3) DSM
# reservations is not a policy to comply with Union copyright law.
test_deny_when_article_4_3_reservations_not_respected if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/copyright/respects_article_4_3_reservations", "value": false}])
}

# Article 53(1)(d): a summary exists but is not sufficiently detailed.
test_deny_when_training_summary_not_sufficiently_detailed if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/training_content/summary_sufficiently_detailed", "value": false}])
}

test_deny_without_public_training_summary if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/training_content/public_summary_available", "value": false}])
}

# The Article 53(2) exemption reaches the downstream duty only. An open-source
# model still owes the copyright policy and the training content summary.
test_open_source_exemption_covers_downstream_information_only if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/free_and_open_source", "value": true},
		{"op": "replace", "path": "/model/parameters_publicly_available", "value": true},
		{"op": "replace", "path": "/downstream/annex_xii_information_provided", "value": false},
	])
}

test_open_source_model_still_owes_the_copyright_policy if {
	not policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/free_and_open_source", "value": true},
		{"op": "replace", "path": "/model/parameters_publicly_available", "value": true},
		{"op": "replace", "path": "/copyright/policy_in_place", "value": false},
	])
}

test_open_source_model_still_owes_the_training_summary if {
	not policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/free_and_open_source", "value": true},
		{"op": "replace", "path": "/model/parameters_publicly_available", "value": true},
		{"op": "replace", "path": "/training_content/public_summary_available", "value": false},
	])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
