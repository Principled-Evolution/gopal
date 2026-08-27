package industry_specific.aviation.v1.data_management.privacy_protection_test

import data.industry_specific.aviation.v1.data_management.privacy_protection
import rego.v1

test_allow_when_minimized_and_lawful if {
	privacy_protection.allow with input as {"privacy": {"data_minimization_applied": true, "consent_or_legal_basis": true}}
}

test_deny_without_data_minimization if {
	not privacy_protection.allow with input as {"privacy": {"data_minimization_applied": false, "consent_or_legal_basis": true}}
}

test_deny_without_legal_basis if {
	not privacy_protection.allow with input as {"privacy": {"data_minimization_applied": true, "consent_or_legal_basis": false}}
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not privacy_protection.allow with input as {}
}
