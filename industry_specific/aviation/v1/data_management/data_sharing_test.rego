package industry_specific.aviation.v1.data_management.data_sharing_test

import data.industry_specific.aviation.v1.data_management.data_sharing
import rego.v1

test_allow_when_agreement_and_authorization_present if {
	data_sharing.allow with input as {"data_sharing": {"agreement_in_place": true, "recipient_authorized": true}}
}

test_deny_without_agreement if {
	not data_sharing.allow with input as {"data_sharing": {"agreement_in_place": false, "recipient_authorized": true}}
}

test_deny_without_authorized_recipient if {
	not data_sharing.allow with input as {"data_sharing": {"agreement_in_place": true, "recipient_authorized": false}}
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not data_sharing.allow with input as {}
}
