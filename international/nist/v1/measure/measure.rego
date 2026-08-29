package international.nist.v1.measure

import data.helper_functions.declarations
import rego.v1

metadata := {
	"title": "NIST AI RMF - Measure",
	"description": "Policies for the Measure function of the NIST AI Risk Management Framework.",
	"version": "1.0.0",
	"category": "NIST AI RMF",
	"references": ["NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework"],
}

# Default deny
default allow := false

# Allow if all measure dimensions are compliant
allow if {
	performance_metrics.allow
	bias_metrics.allow
	robustness_metrics.allow
}

# Performance Metrics: Check for regular measurement of system performance
default performance_metrics := {"allow": false, "msg": "Performance metrics requirements not met."}

performance_metrics := {"allow": true, "msg": "Performance metrics requirements met."} if {
	# Check for defined performance metrics
	declarations.resolve(input, ["measure", "performance_metrics_defined"])

	# Check for regular tracking of performance metrics
	declarations.resolve(input, ["measure", "performance_metrics_tracked"])
}

# Bias Metrics: Check for regular measurement of bias
default bias_metrics := {"allow": false, "msg": "Bias metrics requirements not met."}

bias_metrics := {"allow": true, "msg": "Bias metrics requirements met."} if {
	# Check for defined bias metrics
	declarations.resolve(input, ["measure", "bias_metrics_defined"])

	# Check for regular tracking of bias metrics
	declarations.resolve(input, ["measure", "bias_metrics_tracked"])
}

# Robustness Metrics: Check for regular measurement of system robustness
default robustness_metrics := {"allow": false, "msg": "Robustness metrics requirements not met."}

robustness_metrics := {"allow": true, "msg": "Robustness metrics requirements met."} if {
	# Check for defined robustness metrics
	declarations.resolve(input, ["measure", "robustness_metrics_defined"])

	# Check for regular tracking of robustness metrics
	declarations.resolve(input, ["measure", "robustness_metrics_tracked"])
}
