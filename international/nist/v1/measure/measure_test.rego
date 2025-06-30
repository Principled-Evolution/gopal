package international.nist.v1.measure

import rego.v1

test_allow if {
	allow with input as {"measure": {
		"performance_metrics_defined": true,
		"performance_metrics_tracked": true,
		"bias_metrics_defined": true,
		"bias_metrics_tracked": true,
		"robustness_metrics_defined": true,
		"robustness_metrics_tracked": true,
	}}
}

test_deny_performance_metrics if {
	not allow with input as {"measure": {
		"performance_metrics_defined": false,
		"performance_metrics_tracked": true,
		"bias_metrics_defined": true,
		"bias_metrics_tracked": true,
		"robustness_metrics_defined": true,
		"robustness_metrics_tracked": true,
	}}
}
