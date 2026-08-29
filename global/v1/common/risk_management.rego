# RequiredMetrics:
#   - metrics.risk_management.score
#
# RequiredParams:
#   - risk_management_threshold (default 0.7)
package global.v1.common.risk_management

import data.helper_functions.metrics
import rego.v1

# Common risk management rules and utilities for reuse across policies

# Check if risk score exceeds threshold (higher is better for risk management)
has_adequate_risk_management(metrics, threshold) if {
	risk_score(metrics) >= threshold
}

# The risk management score, or undefined.
#
# Same shape as global/v1/common/fairness: the whole input document, read
# through helper_functions/metrics, undefined rather than 0.0 when nothing was
# measured.
#
# Removed in 2.0.0: passes_risk_threshold, which read the retired flat
# risk_management_score and had no callers.
risk_score(doc) := metrics.resolve(doc, "metrics.risk_management.score")

# Check if risk documentation is present and adequate
has_adequate_documentation(contract) if {
	contract.context.risk_documentation != ""
}

# Check if risk documentation contains minimum required sections
has_required_documentation_sections(contract) if {
	doc := contract.context.risk_documentation
	contains(doc, "Risk Assessment")
	contains(doc, "Mitigation Measures")
} else := false
