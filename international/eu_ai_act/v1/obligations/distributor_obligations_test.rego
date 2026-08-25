package international.eu_ai_act.v1.obligations.distributor_obligations_test

import data.international.eu_ai_act.v1.obligations.distributor_obligations as policy
import rego.v1

compliant := {"system": {"high_risk": true}, "distributor": {
	"verified_ce_marking": true,
	"verified_declaration_and_instructions": true,
	"verified_provider_and_importer_compliance": true,
	"storage_and_transport_conditions_adequate": true,
	"non_conformity_discovered": false,
	"corrective_action_taken": false,
}}

test_allow_when_all_verifications_done if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_without_verifying_ce_marking if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/distributor/verified_ce_marking", "value": false}])
}

test_deny_without_verifying_upstream_compliance if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/distributor/verified_provider_and_importer_compliance", "value": false}])
}

# Article 24(4): once a non-conformity is known, corrective action is required
# rather than optional, even though the verifications all passed.
test_deny_when_non_conformity_found_and_no_corrective_action if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/distributor/non_conformity_discovered", "value": true}])
}

test_allow_when_non_conformity_found_and_corrected if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/distributor/non_conformity_discovered", "value": true},
		{"op": "replace", "path": "/distributor/corrective_action_taken", "value": true},
	])
}

test_deny_when_storage_conditions_jeopardise_compliance if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/distributor/storage_and_transport_conditions_adequate", "value": false}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
