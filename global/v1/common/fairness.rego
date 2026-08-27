# RequiredMetrics:
#   - fairness_score
#
# RequiredParams:
#   - fairness_threshold (default 0.8)
package global.v1.common.fairness

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

# Get fairness score with reasonable default
fairness_score(metrics) := score if {
	score = metrics.fairness.score
} else := score if {
	score = metrics.evaluation.fairness.score
} else := 0.0

# Check if fairness score passes threshold
passes_fairness_threshold(eval, threshold) if {
	eval.fairness_score >= threshold
}
