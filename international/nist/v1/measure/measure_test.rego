package international.nist.v1.measure_test

import data.international.nist.v1.measure
import rego.v1

test_allow if {
	measure.allow with input as {"measure": {
		"performance_metrics_defined": true,
		"performance_metrics_tracked": true,
		"bias_metrics_defined": true,
		"bias_metrics_tracked": true,
		"robustness_metrics_defined": true,
		"robustness_metrics_tracked": true,
	}}
}

test_deny_performance_metrics if {
	not measure.allow with input as {"measure": {
		"performance_metrics_defined": false,
		"performance_metrics_tracked": true,
		"bias_metrics_defined": true,
		"bias_metrics_tracked": true,
		"robustness_metrics_defined": true,
		"robustness_metrics_tracked": true,
	}}
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not measure.allow with input as {}
}
