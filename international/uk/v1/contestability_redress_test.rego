package international.uk.v1.contestability_redress_test

import data.international.uk.v1.contestability_redress as policy
import rego.v1

engaged := {
	"system": {"affects_individuals": true, "material_harm_potential": false},
	"redress": {
		"route_to_contest_available": true,
		"route_communicated": true,
		"human_review_available": true,
		"response_timeframe_days": 30,
	},
}

test_allow_when_route_is_available_and_communicated if {
	policy.allow with input as engaged
}

# The principle is qualified by "where appropriate". A system that affects no
# individuals and carries no material harm potential is not a finding.
test_allow_when_principle_does_not_engage if {
	policy.allow with input as {"system": {
		"affects_individuals": false,
		"material_harm_potential": false,
	}}
}

test_engages_on_material_harm_potential_alone if {
	not policy.allow with input as {"system": {
		"affects_individuals": false,
		"material_harm_potential": true,
	}}
}

# A route that exists but is never told to anyone is not contestability.
test_deny_when_route_exists_but_is_not_communicated if {
	not policy.allow with input as json.patch(engaged, [{
		"op": "replace", "path": "/redress/route_communicated", "value": false,
	}])
}

test_deny_without_human_review if {
	not policy.allow with input as json.patch(engaged, [{
		"op": "replace", "path": "/redress/human_review_available", "value": false,
	}])
}

# An open-ended route is not a route.
test_deny_without_response_timeframe if {
	not policy.allow with input as json.patch(engaged, [{
		"op": "replace", "path": "/redress/response_timeframe_days", "value": 0,
	}])
}

test_deny_when_engaged_with_no_redress_block if {
	not policy.allow with input as {"system": {"affects_individuals": true}}
}

# Silence is not "the principle does not engage": without the scope fact the
# policy has nothing to conclude from and denies.
test_deny_on_empty_input if {
	not policy.allow with input as {}
}

test_allow_requires_the_scope_fact_to_be_asserted if {
	not policy.allow with input as {"redress": {
		"route_to_contest_available": true,
		"route_communicated": true,
		"human_review_available": true,
		"response_timeframe_days": 30,
	}}
}
