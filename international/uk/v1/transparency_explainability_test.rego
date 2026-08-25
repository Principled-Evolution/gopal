package international.uk.v1.transparency_explainability_test

import data.international.uk.v1.transparency_explainability as policy
import rego.v1

baseline := {
	"system": {"impact_level": "low"},
	"transparency": {"ai_use_disclosed": true, "system_purpose_documented": true},
	"explainability": {"decision_rationale_available": true, "method_documented": false},
}

test_allow_low_impact_without_documented_method if {
	policy.allow with input as baseline
}

# "Appropriate" transparency is proportionate: a high-impact system has to go
# further than a low-impact one on the same underlying facts.
test_deny_high_impact_without_documented_method if {
	not policy.allow with input as json.patch(baseline, [{
		"op": "replace", "path": "/system/impact_level", "value": "high",
	}])
}

test_allow_high_impact_with_documented_method if {
	policy.allow with input as json.patch(baseline, [
		{"op": "replace", "path": "/system/impact_level", "value": "high"},
		{"op": "replace", "path": "/explainability/method_documented", "value": true},
	])
}

test_deny_when_ai_use_not_disclosed if {
	not policy.allow with input as json.patch(baseline, [{
		"op": "replace", "path": "/transparency/ai_use_disclosed", "value": false,
	}])
}

test_deny_without_decision_rationale if {
	not policy.allow with input as json.patch(baseline, [{
		"op": "replace", "path": "/explainability/decision_rationale_available", "value": false,
	}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
