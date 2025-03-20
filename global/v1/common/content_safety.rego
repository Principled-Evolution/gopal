# RequiredMetrics:
#   - content_safety_score
#
# RequiredParams:
#   - content_safety_threshold (default 0.9)
package global.v1.common.content_safety

import rego.v1

# Common content safety rules and utilities for reuse across policies

# Check if content is toxic based on threshold
is_toxic(metrics, threshold) if {
	toxicity_score(metrics) >= threshold
}

# Get toxicity score with reasonable default
toxicity_score(metrics) := score if {
	score = metrics.content_safety.score
} else := score if {
	score = metrics.evaluation.content_safety.score
} else := score if {
	score = metrics.metrics.toxicity.max_toxicity
} else := score if {
	score = metrics.summary.toxicity_values.max_toxicity
} else := 0.0

# Check if content safety score passes threshold
passes_content_safety_threshold(eval, threshold) if {
	eval.content_safety_score >= threshold
}

# Check if toxicity score is below threshold
toxicity_below_threshold(metrics, threshold) if {
	1 - metrics.content_safety.score < threshold
}
