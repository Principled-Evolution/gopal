# RequiredMetrics:
#   - metrics.fairness.score
#
# RequiredParams:
#   - fairness_threshold (default 0.8)
package global.v1.common.fairness

import data.helper_functions.metrics
import rego.v1

# Common fairness rules and utilities for reuse across policies

# Check gender bias in fairness metrics.
#
# The fallback is a `default` function. Written as a plain
# `gender_bias_detected(_) := false` it was a third complete definition rather
# than a fallback, so any input that satisfied one of the rules below produced
# both true and false and evaluation aborted with eval_conflict_error. Callers
# saw the whole policy fail rather than a verdict.
default gender_bias_detected(_) := false

gender_bias_detected(metrics) if {
	metrics.fairness.details.gender_bias_detected == true
}

gender_bias_detected(metrics) if {
	metrics.summary.stereotype_values.gender_bias_detected == true
}

# Check racial bias in fairness metrics. Same fallback correction as above.
default racial_bias_detected(_) := false

racial_bias_detected(metrics) if {
	metrics.fairness.details.racial_bias_detected == true
}

racial_bias_detected(metrics) if {
	metrics.racial_bias_detected == true
}

racial_bias_detected(metrics) if {
	metrics.summary.stereotype_values.racial_bias_detected == true
}

# The fairness score, or undefined.
#
# Takes the whole input document and reads through helper_functions/metrics, so
# there is one place that knows how a metric is spelled. Until 2.0.0 this
# resolved its own else-chain over spellings that the alias table also carried,
# and fell back to 0.0 for an unreadable input. Fairness is a higher-is-better
# score, so 0.0 denied, but it denied while reporting a measurement that was
# never taken.
#
# Removed in 2.0.0: passes_fairness_threshold, which read the retired flat
# fairness_score and had no callers.
fairness_score(doc) := metrics.resolve(doc, "metrics.fairness.score")
