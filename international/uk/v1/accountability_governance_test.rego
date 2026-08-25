package international.uk.v1.accountability_governance_test

import data.international.uk.v1.accountability_governance as policy
import rego.v1

first_party := {"governance": {
	"accountable_person_named": true,
	"lifecycle_roles_defined": true,
	"oversight_body_in_place": true,
	"third_party_model_in_use": false,
	"supply_chain_accountability_documented": false,
}}

test_allow_first_party_model if {
	policy.allow with input as first_party
}

# Bringing in a vendor model does not move accountability to the vendor: the
# supply relationship has to be documented.
test_deny_third_party_model_without_documented_supply_chain if {
	not policy.allow with input as json.patch(first_party, [{
		"op": "replace", "path": "/governance/third_party_model_in_use", "value": true,
	}])
}

test_allow_third_party_model_with_documented_supply_chain if {
	policy.allow with input as json.patch(first_party, [
		{"op": "replace", "path": "/governance/third_party_model_in_use", "value": true},
		{"op": "replace", "path": "/governance/supply_chain_accountability_documented", "value": true},
	])
}

test_deny_without_named_accountable_person if {
	not policy.allow with input as json.patch(first_party, [{
		"op": "replace", "path": "/governance/accountable_person_named", "value": false,
	}])
}

test_deny_without_lifecycle_roles if {
	not policy.allow with input as json.patch(first_party, [{
		"op": "replace", "path": "/governance/lifecycle_roles_defined", "value": false,
	}])
}

test_deny_without_oversight_body if {
	not policy.allow with input as json.patch(first_party, [{
		"op": "replace", "path": "/governance/oversight_body_in_place", "value": false,
	}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
