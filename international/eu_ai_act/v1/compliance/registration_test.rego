package international.eu_ai_act.v1.compliance.registration_test

import data.international.eu_ai_act.v1.compliance.registration as policy
import rego.v1

compliant := {
	"system": {"high_risk": true, "annex_iii_exempt_under_article_6_3": false},
	"registration": {
		"provider_registered": true,
		"system_registered": true,
		"registered_before_placing_on_market": true,
		"annex_viii_information_complete": true,
		"exemption_assessment_registered": false,
	},
}

test_allow_when_fully_registered if {
	policy.allow with input as compliant
}

test_deny_when_provider_not_registered if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/registration/provider_registered", "value": false}])
}

# Registering after the fact does not satisfy Article 49(1).
test_deny_when_registered_after_placing_on_market if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/registration/registered_before_placing_on_market", "value": false}])
}

test_deny_without_annex_viii_information if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/registration/annex_viii_information_complete", "value": false}])
}

# Article 49(2): a provider claiming its Annex III system is not high-risk
# under Article 6(3) still has to register that assessment. This is the case
# most likely to be overlooked entirely.
test_deny_article_6_3_exemption_without_registering_the_assessment if {
	not policy.allow with input as {
		"system": {"high_risk": false, "annex_iii_exempt_under_article_6_3": true},
		"registration": {"exemption_assessment_registered": false},
	}
}

test_allow_article_6_3_exemption_with_registered_assessment if {
	policy.allow with input as {
		"system": {"high_risk": false, "annex_iii_exempt_under_article_6_3": true},
		"registration": {"exemption_assessment_registered": true},
	}
}

# A system that is neither high-risk nor claiming the exemption is out of scope.
test_allow_when_out_of_scope_entirely if {
	policy.allow with input as {"system": {"high_risk": false, "annex_iii_exempt_under_article_6_3": false}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
