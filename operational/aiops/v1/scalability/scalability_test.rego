package operational.aiops.v1.scalability_test

import data.operational.aiops.v1.scalability as policy
import rego.v1

compliant := {
	"capacity": {"plan_documented": true, "peak_load_tested": true, "headroom_ratio": 1.5},
	"latency": {"slo_defined": true, "p99_within_slo": true},
	"resilience": {"autoscaling_configured": true, "graceful_degradation_documented": true},
}

test_allow_when_all_controls_present if {
	policy.allow with input as compliant
}

test_deny_without_peak_load_test if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/capacity/peak_load_tested", "value": false}])
}

test_deny_on_insufficient_headroom if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/capacity/headroom_ratio", "value": 1.05}])
}

test_allow_at_headroom_boundary if {
	policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/capacity/headroom_ratio", "value": 1.2}])
}

test_deny_when_headroom_absent if {
	not policy.allow with input as json.patch(compliant, [{"op": "remove", "path": "/capacity/headroom_ratio"}])
}

test_deny_without_latency_slo if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/latency/slo_defined", "value": false}])
}

test_deny_when_p99_outside_slo if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/latency/p99_within_slo", "value": false}])
}

test_deny_without_autoscaling if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/resilience/autoscaling_configured", "value": false}])
}

# Autoscaling cannot help when the bound is a rate-limited model provider, so
# the degradation path is required even with autoscaling configured.
test_deny_without_degradation_path_despite_autoscaling if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/resilience/graceful_degradation_documented", "value": false}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
