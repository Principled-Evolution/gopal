package operational.cost.v1.resource_efficiency_test

import data.operational.cost.v1.resource_efficiency as policy
import rego.v1

compliant := {
	"budget": {"defined": true, "utilisation_ratio": 0.6},
	"monitoring": {"spend_tracked": true, "alerting_configured": true, "unit_cost_attributable": true},
	"efficiency": {"right_sizing_reviewed_days_ago": 45},
}

test_allow_when_all_controls_present if {
	policy.allow with input as compliant
}

test_deny_without_defined_budget if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/budget/defined", "value": false}])
}

# Utilisation at 1.0 means the budget is already spent, not that it is met.
test_deny_at_full_utilisation if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/budget/utilisation_ratio", "value": 1.0}])
}

test_deny_over_budget if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/budget/utilisation_ratio", "value": 1.4}])
}

# An absent utilisation figure must not read as inside budget, which is the
# whole failure mode for usage-priced inference.
test_deny_when_utilisation_absent if {
	not policy.allow with input as json.patch(compliant, [{"op": "remove", "path": "/budget/utilisation_ratio"}])
}

test_deny_without_alerting if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/monitoring/alerting_configured", "value": false}])
}

test_deny_without_spend_tracking if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/monitoring/spend_tracked", "value": false}])
}

# Without unit cost attribution an efficiency regression is indistinguishable
# from growth in usage.
test_deny_without_unit_cost_attribution if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/monitoring/unit_cost_attributable", "value": false}])
}

test_deny_when_right_sizing_stale if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/efficiency/right_sizing_reviewed_days_ago", "value": 400}])
}

test_allow_at_review_boundary if {
	policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/efficiency/right_sizing_reviewed_days_ago", "value": 180}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
